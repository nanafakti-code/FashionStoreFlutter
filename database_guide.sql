-- GUÍA COMPLETA DE LA BASE DE DATOS (FASHION STORE)
-- Copia y pega estos bloques en el SQL Editor de Supabase para explorar tu base de datos.

-- ==========================================
-- 1. CATÁLOGO DE PRODUCTOS
-- ==========================================

-- Estructura de productos y sus categorías
SELECT p.*, c.nombre as nombre_categoria 
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id
LIMIT 10;

-- Variantes (Tallas y Colores) de los productos
SELECT * FROM variantes_producto LIMIT 20;

-- Imágenes adicionales de productos
SELECT * FROM imagenes_producto LIMIT 20;

-- Categorías disponibles
SELECT * FROM categorias;


-- ==========================================
-- 2. CLIENTES Y SEGURIDAD
-- ==========================================

-- Perfiles de usuario (tabla 'usuarios')
-- Nota: La autenticación real está en auth.users, pero aquí guardas los metadatos.
SELECT * FROM usuarios LIMIT 10;


-- ==========================================
-- 3. PEDIDOS Y VENTAS
-- ==========================================

-- Resumen de órdenes
SELECT * FROM ordenes ORDER BY fecha_creacion DESC LIMIT 10;

-- Detalle de productos dentro de cada orden (items_orden)
SELECT * FROM items_orden LIMIT 20;

-- Cupones de descuento
SELECT * FROM cupones;


-- ==========================================
-- 4. INTERACCIÓN Y MARKETING
-- ==========================================

-- Reseñas de productos
SELECT * FROM resenas LIMIT 10;

-- Suscriptores al Newsletter
-- SELECT * FROM newsletter_subscribers; -- Verifica si el nombre es este o similar

-- Devoluciones (si existe la tabla)
-- SELECT * FROM devoluciones;


-- ==========================================
-- 5. TRUCO: VER TODAS LAS TABLAS Y COLUMNAS
-- ==========================================
SELECT 
    table_name, 
    column_name, 
    data_type 
FROM 
    information_schema.columns 
WHERE 
    table_schema = 'public'
ORDER BY 
    table_name, 
    ordinal_position;
