-- IMPORTANTE: Ejecuta este script temporal en el SQL Editor de Supabase
-- Esto permitirá que el sistema relacione una única reseña a un único producto dentro de un único pedido específico.

-- 1. Añadimos la columna orden_id a resenas
ALTER TABLE public.resenas 
ADD COLUMN IF NOT EXISTS orden_id UUID REFERENCES public.ordenes(id) ON DELETE SET NULL;

-- 2. Eliminar constraint antigua si existe (ej. unq_resena_user_prod)
-- NOTA: Si en tu base de datos la restriccion tiene otro nombre, cambialo aqui
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'resenas_usuario_id_producto_id_key') THEN
    ALTER TABLE public.resenas DROP CONSTRAINT resenas_usuario_id_producto_id_key;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unq_resena_user_prod') THEN
    ALTER TABLE public.resenas DROP CONSTRAINT unq_resena_user_prod;
  END IF;
END $$;

-- 3. Crear nueva constraint para asegurar: 1 reseña por usuario, por producto, POR ORDEN.
ALTER TABLE public.resenas
ADD CONSTRAINT unq_resena_user_prod_orden UNIQUE (usuario_id, producto_id, orden_id);
