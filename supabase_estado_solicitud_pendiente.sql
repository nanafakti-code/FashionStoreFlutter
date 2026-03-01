-- -----------------------------------------------------------------------------
-- SCRIPT PARA ACTUALIZAR ESTADO DEL PEDIDO AL SOLICITAR DEVOLUCIÓN
-- Ejecutar en el "SQL Editor" de Supabase
-- -----------------------------------------------------------------------------

-- 1. Función para actualizar el estado del pedido
CREATE OR REPLACE FUNCTION handle_return_request()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Al insertar una nueva devolución (Pendiente), actualizamos el estado del pedido
    UPDATE ordenes 
    SET estado = 'Solicitud Pendiente' 
    WHERE id = NEW.orden_id;

    RETURN NEW;
END;
$$;

-- 2. Trigger al insertar en devoluciones
DROP TRIGGER IF EXISTS tr_update_order_status_on_return ON devoluciones;
CREATE TRIGGER tr_update_order_status_on_return
AFTER INSERT ON devoluciones
FOR EACH ROW
EXECUTE FUNCTION handle_return_request();

-- COMENTARIOS DE DOCUMENTACIÓN
COMMENT ON FUNCTION handle_return_request() IS 'Cambia el estado del pedido a Solicitud Pendiente cuando se registra una nueva devolución';
