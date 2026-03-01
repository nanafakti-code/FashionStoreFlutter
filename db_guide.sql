-- GUÍA DE LA BASE DE DATOS (Supabase)
-- Usa estos comandos en el Editor SQL de tu panel de Supabase para entender la estructura.

-- 1. Usuarios y Credenciales de Administrador
SELECT * FROM usuarios LIMIT 5;
SELECT * FROM admin_credentials LIMIT 5;

-- 2. Estructura de Productos y Categorías
SELECT * FROM productos LIMIT 5;
SELECT * FROM categorias LIMIT 5;
-- Relación: productos.categoria_id -> categorias.id

-- 3. Pedidos e Items (Gestión Económica)
SELECT * FROM ordenes LIMIT 5;
SELECT * FROM items_orden LIMIT 5;
-- Relación: items_orden.orden_id -> ordenes.id

-- 4. Interacción: Reseñas y Favoritos
SELECT * FROM reseñas LIMIT 5;
-- Relación: reseñas.producto_id -> productos.id, reseñas.usuario_id -> usuarios.id

-- 5. Marketing y Post-Venta
SELECT * FROM cupones LIMIT 5;
SELECT * FROM devoluciones LIMIT 5;
SELECT * FROM newsletter LIMIT 5;
SELECT * FROM campañas LIMIT 5;

-- 6. Ver todas las tablas y sus columnas
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public'
ORDER BY table_name;
