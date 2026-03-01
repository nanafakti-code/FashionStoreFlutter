-- Script para añadir los campos de información personal a la tabla usuarios
ALTER TABLE public.usuarios 
ADD COLUMN IF NOT EXISTS genero text,
ADD COLUMN IF NOT EXISTS fecha_nacimiento timestamp with time zone;

-- Comentario informativo
COMMENT ON COLUMN public.usuarios.genero IS 'Género del usuario (Masculino, Femenino, Otro)';
COMMENT ON COLUMN public.usuarios.fecha_nacimiento IS 'Fecha de nacimiento del usuario';



