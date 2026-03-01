-- -----------------------------------------------------------------------------
-- SCRIPT DE CORRECIÓN: SOPORTE PARA VARIANTES EN ITEMS DE ORDEN
-- Ejecutar en el "SQL Editor" de Supabase
-- -----------------------------------------------------------------------------

-- 1. Añadir la columna variant_id a items_orden si no existe
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='items_orden' AND column_name='variant_id') THEN
        ALTER TABLE items_orden ADD COLUMN variant_id UUID REFERENCES variantes_producto(id);
    END IF;
END $$;

-- 2. Actualizar la función checkout_atomic para guardar el variant_id
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
SECURITY DEFINER
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

    -- Iterar sobre los items solicitados para DESCONTAR STOCK
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_producto_id := (v_item->>'producto_id')::UUID;
        v_variant_id := NULLIF(v_item->>'variant_id', '')::UUID;
        v_cantidad := (v_item->>'cantidad')::INT;
        v_nombre_producto := v_item->>'nombre';

        -- A. Gestión de Variante
        IF v_variant_id IS NOT NULL THEN
            SELECT stock INTO v_stock_actual FROM variantes_producto WHERE id = v_variant_id FOR UPDATE;
            IF v_stock_actual IS NULL THEN
                RAISE EXCEPTION 'VARIANTE_NO_ENCONTRADA:%:%', v_variant_id, v_nombre_producto USING ERRCODE = 'P0002';
            END IF;
            IF v_stock_actual < v_cantidad THEN
                RAISE EXCEPTION 'STOCK_INSUFFICIENTE:%:%:%', v_producto_id, v_nombre_producto, v_stock_actual USING ERRCODE = 'P0001';
            END IF;
            UPDATE variantes_producto SET stock = stock - v_cantidad WHERE id = v_variant_id;
        END IF;

        -- B. Gestión de Producto Base
        SELECT stock_total INTO v_stock_actual FROM productos WHERE id = v_producto_id FOR UPDATE;
        IF v_stock_actual IS NULL THEN
            RAISE EXCEPTION 'PRODUCTO_NO_ENCONTRADO:%:%', v_producto_id, v_nombre_producto USING ERRCODE = 'P0002';
        END IF;
        IF v_stock_actual < v_cantidad THEN
            RAISE EXCEPTION 'STOCK_INSUFFICIENTE:%:%:%', v_producto_id, v_nombre_producto, v_stock_actual USING ERRCODE = 'P0001';
        END IF;
        UPDATE productos SET stock_total = stock_total - v_cantidad WHERE id = v_producto_id;
    END LOOP;

    -- Procedemos a insertar la orden
    INSERT INTO ordenes (
        numero_orden, usuario_id, estado, subtotal, impuestos, descuento, 
        coste_envio, total, cupon_id, email_cliente, nombre_cliente, 
        telefono_cliente, direccion_envio
    ) VALUES (
        v_numero_orden, p_usuario_id, 'Pendiente_Pago', p_subtotal, p_impuestos, p_descuento,
        p_coste_envio, p_total, p_cupon_id, p_email_cliente, p_nombre_cliente,
        p_telefono_cliente, p_direccion_envio
    ) RETURNING id INTO v_orden_id;

    -- Insertar los items de la orden asociada (AHORA INCLUYE variant_id)
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        INSERT INTO items_orden (
            orden_id, producto_id, variant_id, producto_nombre, producto_imagen, 
            cantidad, precio_unitario, subtotal, talla, color
        ) VALUES (
            v_orden_id, 
            (v_item->>'producto_id')::UUID, 
            NULLIF(v_item->>'variant_id', '')::UUID,
            v_item->>'nombre', 
            v_item->>'imagen', 
            (v_item->>'cantidad')::INT, 
            (v_item->>'precio_unitario')::INT, 
            ((v_item->>'precio_unitario')::INT * (v_item->>'cantidad')::INT), 
            v_item->>'talla', 
            v_item->>'color'
        );
    END LOOP;

    RETURN (SELECT row_to_json(o) FROM ordenes o WHERE o.id = v_orden_id)::JSONB;
END;
$$;


-- 3. Actualizar el trigger handle_stock_return para que no falle si variant_id es nulo o faltan datos
CREATE OR REPLACE FUNCTION handle_stock_return()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_item RECORD;
BEGIN
    IF NEW.estado = 'Reembolsada' AND (OLD.estado IS NULL OR OLD.estado != 'Reembolsada') THEN
        
        FOR v_item IN 
            SELECT producto_id, variant_id, cantidad 
            FROM items_orden 
            WHERE orden_id = NEW.orden_id
        LOOP
            -- Solo reponer si tenemos los datos necesarios
            IF v_item.producto_id IS NOT NULL AND v_item.cantidad > 0 THEN
                
                -- Reponer Variante (si existe)
                IF v_item.variant_id IS NOT NULL THEN
                    UPDATE variantes_producto 
                    SET stock = stock + v_item.cantidad 
                    WHERE id = v_item.variant_id;
                END IF;

                -- Reponer Producto Base
                UPDATE productos 
                SET stock_total = stock_total + v_item.cantidad 
                WHERE id = v_item.producto_id;
                
            END IF;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$;

-- Volver a crear el trigger por si acaso
DROP TRIGGER IF EXISTS tr_restore_stock_on_refund ON devoluciones;
CREATE TRIGGER tr_restore_stock_on_refund
AFTER UPDATE ON devoluciones
FOR EACH ROW
EXECUTE FUNCTION handle_stock_return();
