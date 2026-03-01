-- -----------------------------------------------------------------------------
-- SCRIPT PARA RESTAURAR STOCK EN DEVOLUCIONES REEMBOLSADAS
-- Ejecutar en el "SQL Editor" de Supabase
-- -----------------------------------------------------------------------------

-- 1. Función para manejar la reposición de stock
CREATE OR REPLACE FUNCTION handle_stock_return()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_item RECORD;
BEGIN
    -- Solo actuar cuando el estado cambia a 'Reembolsada'
    IF NEW.estado = 'Reembolsada' AND (OLD.estado IS NULL OR OLD.estado != 'Reembolsada') THEN
        
        -- Iterar por todos los productos del pedido asociado a la devolución
        FOR v_item IN 
            SELECT producto_id, variant_id, cantidad 
            FROM items_orden 
            WHERE orden_id = NEW.orden_id
        LOOP
            -- A. Reponer Stock en la Variante (si aplica)
            IF v_item.variant_id IS NOT NULL THEN
                UPDATE variantes_producto 
                SET stock = stock + v_item.cantidad 
                WHERE id = v_item.variant_id;
            END IF;

            -- B. Reponer Stock Global del Producto
            UPDATE productos 
            SET stock_total = stock_total + v_item.cantidad 
            WHERE id = v_item.producto_id;
            
        END LOOP;

        RAISE NOTICE 'Stock restaurado para el pedido % debido a reembolso de la devolución %', NEW.orden_id, NEW.id;
    END IF;

    RETURN NEW;
END;
$$;

-- 2. Crear el Trigger en la tabla devoluciones
-- Eliminamos el trigger si ya existe para evitar duplicados
DROP TRIGGER IF EXISTS tr_restore_stock_on_refund ON devoluciones;

CREATE TRIGGER tr_restore_stock_on_refund
AFTER UPDATE ON devoluciones
FOR EACH ROW
EXECUTE FUNCTION handle_stock_return();

-- COMENTARIOS DE DOCUMENTACIÓN
COMMENT ON FUNCTION handle_stock_return() IS 'Repone automáticamente el stock de productos cuando una devolución pasa a estado Reembolsada';
