-- Ejecuta este comando en el editor SQL de tu panel de Supabase
-- Servirá para ver exactamente cómo se llaman las columnas de tus tablas y qué datos contienen.

-- 1. Ver estructura de la tabla de productos
SELECT * FROM productos LIMIT 5;

-- 2. Ver estructura de la tabla de categorías
SELECT * FROM categorias LIMIT 5;

-- 3. Ver estructura de la tabla de imágenes (si existe una separada)
SELECT * FROM imagenes_producto LIMIT 5;
