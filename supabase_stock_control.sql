-- -----------------------------------------------------------------------------
-- SCRIPT DE CONTROL DE STOCK EN TIEMPO REAL PARA SUPABASE
-- Ejecutar en el "SQL Editor" de Supabase
-- -----------------------------------------------------------------------------

-- 1. Función para verificar stock disponible (Útil para revalidar en "Añadir al carrito")
CREATE OR REPLACE FUNCTION check_stock_available(p_producto_id UUID, p_variant_id UUID, p_cantidad INT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_stock INT;
BEGIN
    IF p_variant_id IS NOT NULL THEN
        SELECT stock INTO v_stock FROM variantes_producto WHERE id = p_variant_id;
    ELSE
        SELECT stock_total INTO v_stock FROM productos WHERE id = p_producto_id;
    END IF;

    RETURN COALESCE(v_stock, 0) >= p_cantidad;
END;
$$;


-- 2. Función transaccional para realizar el checkout de forma atómica
-- Utiliza "SELECT ... FOR UPDATE" para bloquear la fila durante la transacción.
CREATE OR REPLACE FUNCTION checkout_atomic(
    p_usuario_id UUID,
    p_subtotal INT,
    p_total INT,
    p_impuestos INT DEFAULT 0,
    p_descuento INT DEFAULT 0,
    p_coste_envio INT DEFAULT 0,
    p_cupon_id BIGINT DEFAULT NULL,
    p_email_cliente TEXT DEFAULT NULL,
    p_nombre_cliente TEXT DEFAULT NULL,
    p_telefono_cliente TEXT DEFAULT NULL,
    p_direccion_envio JSONB DEFAULT NULL,
    p_notas TEXT DEFAULT NULL,
    p_items JSONB DEFAULT '[]'::JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER -- Se ejecuta con privilegios del creador (bypass RLS necesario para checkouts confiables)
AS $$
DECLARE
    v_orden_id UUID;
    v_numero_orden TEXT;
    v_item JSONB;
    v_producto_id UUID;
    v_variant_id UUID;
    v_cantidad INT;
    v_stock_actual INT;
    v_nombre_producto TEXT;
BEGIN
    -- Generar un número de orden único FS-YYYYMMDD-XXXX
    v_numero_orden := 'FS-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(TRUNC(RANDOM() * 9999)::TEXT, 4, '0');

    -- Iterar sobre los items solicitados
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_producto_id := (v_item->>'producto_id')::UUID;
        v_variant_id := NULLIF(v_item->>'variant_id', '')::UUID;
        v_cantidad := (v_item->>'cantidad')::INT;
        v_nombre_producto := v_item->>'nombre';

        -- A. Gestión de Variante (Si el item es de una variante específica)
        IF v_variant_id IS NOT NULL THEN
            -- Bloqueo de fila
            SELECT stock INTO v_stock_actual 
            FROM variantes_producto 
            WHERE id = v_variant_id 
            FOR UPDATE;

            IF v_stock_actual IS NULL THEN
                RAISE EXCEPTION 'VARIANTE_NO_ENCONTRADA:%:%', v_variant_id, v_nombre_producto USING ERRCODE = 'P0002';
            END IF;

            IF v_stock_actual < v_cantidad THEN
                -- Lanzamiento de error manejable. El prefijo es usado en Flutter.
                RAISE EXCEPTION 'STOCK_INSUFFICIENTE:%:%:%', v_producto_id, v_nombre_producto, v_stock_actual USING ERRCODE = 'P0001';
            END IF;

            -- Descontar el stock de la variante
            UPDATE variantes_producto 
            SET stock = stock - v_cantidad 
            WHERE id = v_variant_id;
        END IF;

        -- B. Restar del total del producto (Stock Global del producto) siempre.
        -- Bloqueo de fila del producto base
        SELECT stock_total INTO v_stock_actual 
        FROM productos 
        WHERE id = v_producto_id 
        FOR UPDATE;

        IF v_stock_actual IS NULL THEN
            RAISE EXCEPTION 'PRODUCTO_NO_ENCONTRADO:%:%', v_producto_id, v_nombre_producto USING ERRCODE = 'P0002';
        END IF;

        IF v_stock_actual < v_cantidad THEN
            RAISE EXCEPTION 'STOCK_INSUFFICIENTE:%:%:%', v_producto_id, v_nombre_producto, v_stock_actual USING ERRCODE = 'P0001';
        END IF;

        -- Descontar el stock global
        UPDATE productos 
        SET stock_total = stock_total - v_cantidad 
        WHERE id = v_producto_id;
        
    END LOOP;

    -- Si llegamos aquí, entonces NADA falló, todo el stock fue modificado en memoria.
    -- Procedemos a insertar en la base de datos la compra.

    INSERT INTO ordenes (
        numero_orden, usuario_id, estado, subtotal, impuestos, descuento, 
        coste_envio, total, cupon_id, email_cliente, nombre_cliente, 
        telefono_cliente, direccion_envio
    ) VALUES (
        v_numero_orden, p_usuario_id, 'Pendiente_Pago', p_subtotal, p_impuestos, p_descuento,
        p_coste_envio, p_total, p_cupon_id, p_email_cliente, p_nombre_cliente,
        p_telefono_cliente, p_direccion_envio
    ) RETURNING id INTO v_orden_id;

    -- Insertar los items de la orden asociada
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        INSERT INTO items_orden (
            orden_id, producto_id, producto_nombre, producto_imagen, 
            cantidad, precio_unitario, subtotal, talla, color
        ) VALUES (
            v_orden_id, 
            (v_item->>'producto_id')::UUID, 
            v_item->>'nombre', 
            v_item->>'imagen', 
            (v_item->>'cantidad')::INT, 
            (v_item->>'precio_unitario')::INT, 
            ((v_item->>'precio_unitario')::INT * (v_item->>'cantidad')::INT), 
            v_item->>'talla', 
            v_item->>'color'
        );
    END LOOP;

    -- Retorna el JSON de la orden recién creada (todo esto bajo una única transacción PostgreSQL)
    RETURN (
        SELECT row_to_json(o)
        FROM ordenes o
        WHERE o.id = v_orden_id
    )::JSONB;
END;
$$;
