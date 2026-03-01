-- Script para depurar si el evento o el trigger se están disparando 
-- Ejecutar en el SQL Editor de Supabase

-- Vamos a crear una pequeña tabla de logs para capturar qué se dispara
CREATE TABLE IF NOT EXISTS debug_logs (
  id SERIAL PRIMARY KEY,
  message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Actualizar el trigger para dejar un registro y saber si al menos entra a la función
CREATE OR REPLACE FUNCTION handle_stock_return()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_item RECORD;
BEGIN
    INSERT INTO debug_logs (message) VALUES ('Trigger lanzado. Old Estado: ' || COALESCE(OLD.estado, 'null') || ', New Estado: ' || NEW.estado);

    IF NEW.estado = 'Reembolsada' AND (OLD.estado IS NULL OR OLD.estado != 'Reembolsada') THEN
        INSERT INTO debug_logs (message) VALUES ('Condición de Reembolsada cumplida para orden: ' || NEW.orden_id);
        
        FOR v_item IN 
            SELECT producto_id, variant_id, cantidad 
            FROM items_orden 
            WHERE orden_id = NEW.orden_id
        LOOP
            INSERT INTO debug_logs (message) VALUES ('Procesando item. Producto: ' || v_item.producto_id || ', Cantidad: ' || v_item.cantidad);
            
            IF v_item.producto_id IS NOT NULL AND v_item.cantidad > 0 THEN
                
                -- Reponer Variante (si existe)
                IF v_item.variant_id IS NOT NULL THEN
                    UPDATE variantes_producto 
                    SET stock = stock + v_item.cantidad 
                    WHERE id = v_item.variant_id;
                    
                    INSERT INTO debug_logs (message) VALUES ('Variante actualizada: ' || v_item.variant_id);
                END IF;

                -- Reponer Producto Base
                UPDATE productos 
                SET stock_total = stock_total + v_item.cantidad 
                WHERE id = v_item.producto_id;
                
                INSERT INTO debug_logs (message) VALUES ('Producto base actualizado: ' || v_item.producto_id);
            END IF;
        END LOOP;
    ELSE
        INSERT INTO debug_logs (message) VALUES ('Condición de reembolso no cumplida o estado no cambió.');
    END IF;

    RETURN NEW;
END;
$$;
