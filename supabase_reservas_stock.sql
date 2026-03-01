-- =========================================================================
-- CREACIÓN DE TABLA: reservas_stock
-- Propósito: Mantener un registro temporal del stock que los usuarios
--            tienen en su carrito para evitar sobreventas, antes 
--            del checkout definitivo.
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.reservas_stock (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    producto_id UUID NOT NULL REFERENCES public.productos(id) ON DELETE CASCADE,
    variant_id UUID REFERENCES public.variantes_producto(id) ON DELETE CASCADE, -- Puede ser nulo si el producto no tiene variantes
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para búsquedas rápidas (por usuario o producto)
CREATE INDEX IF NOT EXISTS idx_reservas_usuario ON public.reservas_stock(usuario_id);
CREATE INDEX IF NOT EXISTS idx_reservas_producto ON public.reservas_stock(producto_id);

-- Restricción de unicidad: Un usuario solo puede tener una fila de reserva por combinación (producto + variante)
-- Esto previene duplicados y obliga a usar UPSERT (actualizar cantidad si ya existe)
CREATE UNIQUE INDEX IF NOT EXISTS unq_reserva_user_prod_var 
ON public.reservas_stock(usuario_id, producto_id, COALESCE(variant_id, '00000000-0000-0000-0000-000000000000'::uuid));


-- =========================================================================
-- POLÍTICAS DE SEGURIDAD (RLS - Row Level Security)
-- =========================================================================
ALTER TABLE public.reservas_stock ENABLE ROW LEVEL SECURITY;

-- 1. Los usuarios pueden ver solo SUS PROPIAS reservas
CREATE POLICY "Usuarios ven sus propias reservas" 
ON public.reservas_stock FOR SELECT 
TO authenticated 
USING (auth.uid() = usuario_id);

-- 2. Los usuarios pueden crear reservas a su nombre
CREATE POLICY "Usuarios insertan sus propias reservas" 
ON public.reservas_stock FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = usuario_id);

-- 3. Los usuarios pueden actualizar sus reservas
CREATE POLICY "Usuarios actualizan sus propias reservas" 
ON public.reservas_stock FOR UPDATE 
TO authenticated 
USING (auth.uid() = usuario_id)
WITH CHECK (auth.uid() = usuario_id);

-- 4. Los usuarios pueden borrar sus reservas (ej: al vaciar carrito o expirar timer)
CREATE POLICY "Usuarios borran sus propias reservas" 
ON public.reservas_stock FOR DELETE 
TO authenticated 
USING (auth.uid() = usuario_id);

-- Opcional para vista global: 
-- Para calcular el stock REAL disponible sumando reservas de todos, las funciones SECURITY DEFINER 
-- en la BD lo hacen saltándose RLS. Por lo que esto es suficiente para el frontend.
