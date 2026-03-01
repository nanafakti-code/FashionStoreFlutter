# 📊 Análisis Técnico del Panel de Administración (para Replicación en Flutter)

Este documento detalla la arquitectura, flujos de datos y lógica del panel de administración actual de FashionStore, diseñado para ser replicado fielmente en una aplicación Flutter utilizando la misma base de datos Supabase.

> **Nota para el desarrollo en Flutter**: El panel actual utiliza una arquitectura "Frontend (React) -> API Intermedia (Astro) -> Base de Datos (Supabase)". En tu app Flutter, conectarás **directamente** a Supabase usando el SDK `supabase_flutter`, simplificando la capa intermedia pero manteniendo la misma lógica de negocio.

---

## 1. 🔐 Autenticación de Administrador

El sistema NO usa el sistema de usuarios estándar de Supabase para el admin, sino un sistema personalizado simple.

### Lógica de Autenticación
- **Tabla en BD**: `admin_credentials` (opcional, tiene fallback hardcoded).
- **Email Fijo**: `admin@fashionstore.com` (Definido en código).
- **Contraseña**: Se busca en la tabla `admin_credentials`. Si la tabla no existe o falla, usa `1234`.
- **Sesión**: En web usa una cookie httpOnly con un JSON base64. En Flutter deberás usar `SharedPreferences` o `FlutterSecureStorage` para persistir el estado de sesión.

### Query para Login (Flutter)
```dart
// 1. Verificar si es el email de admin
if (email != 'admin@fashionstore.com') return "Email no autorizado";

// 2. Obtener contraseña real
final response = await supabase
    .from('admin_credentials')
    .select('password')
    .eq('email', 'admin@fashionstore.com')
    .single();

// 3. Comparar contraseña (texto plano en la versión actual, considerar hash para producción)
if (response['password'] == passwordInput) {
  // Login exitoso
}
```

---

## 2. 📦 Gestión de Productos (CRUD)

Esta es la funcionalidad central. Interactúa con tres tablas principales: `productos`, `variantes_producto` e `imagenes_producto`.

### A. Listar Productos (Leer)
**Base de datos**:
- **Tabla**: `productos`
- **Campos solicitados**: `*` (todos)
- **Orden**: Alfabético por `nombre`.
```sql
SELECT * FROM productos ORDER BY nombre ASC;
```

### B. Crear Producto
El flujo de creación es transaccional (primero producto, luego variantes).

1. **Insertar Producto Base**:
   - **Tabla**: `productos`
   - **Datos**: `nombre`, `precio_venta`, `descripcion`, `slug` (generado from nombre), `sku`, `categoria_id`, `marca_id`.
   - **Nota**: `stock_total` se actualiza automáticamente vís trigger o lógica posterior, no se suele insertar directo si hay variantes.

2. **Insertar Variantes (Si aplica)**:
   - **Tabla**: `variantes_producto`
   - **Iterar** sobre la lista de variantes ingresadas en UI.
   - **Campos**:
     - `producto_id`: (ID del producto recién creado)
     - `talla`: (ej: "M", "42")
     - `color`: (ej: "Rojo")
     - `stock`: Cantidad inicial.
     - `sku_variante`: Generado único (ej: `VAR-{timestamp}-{random}`).
     - `precio_adicional` / `precio_venta`: Delta o precio final.

### C. Editar Producto
Requiere manejar la actualización del padre y la sincronización de los hijos (variantes).

1. **Actualizar Datos Base**:
   - `UPDATE productos SET ... WHERE id = ?`

2. **Sincronizar Variantes**:
   - **Nuevas Variantes**: Si no tiene ID, hacer `INSERT`.
   - **Variantes Existentes**: Si tiene ID, hacer `UPDATE` (especialmente `stock` y `precio`).
   - **Eliminar Variantes**: La web actual envía un array `variantsToDelete`. En Flutter, puedes identificar las que ya no están en la lista y hacer `DELETE FROM variantes_producto WHERE id IN (...)`.

### D. Eliminar Producto
- **Acción**: `DELETE FROM productos WHERE id = ?`
- **Cascada**: La base de datos está configurada con `ON DELETE CASCADE`, por lo que eliminar el producto borra automáticamente sus imágenes y variantes.

---

## 3. 🎟️ Cupones de Descuento

Panel para crear códigos promocionales.

- **Tabla**: `coupons`
- **Campos Clave**:
  - `code`: Código (ej: "VERANO2026").
  - `discount_type`: 'percentage' o 'fixed'.
  - `value`: Valor del descuento.
  - `min_order_value`: Mínimo de compra.
  - `expiration_date`: Fecha fin.
  - `is_active`: Booleano.
  - `assigned_user_id`: Opcional (cupón personal).

**Cálculo de Estadísticas (Visualización)**:
Para mostrar cuántas veces se ha usado un cupón, el panel consulta la tabla `coupon_usages`:
```sql
SELECT count(*) FROM coupon_usages WHERE coupon_id = ?
```

---

## 4. 👥 Gestión de Usuarios

Visualización simple de usuarios registrados.

- **Tabla**: `usuarios`
- **Datos mostrados**: `id`, `email`, `nombre`, `activo`.
- **Uso**: Principalmente para asignar cupones personalizados (seleccionando un usuario de la lista).

---

## 5. 📸 Gestión de Imágenes

Las imágenes se suben al Storage de Supabase y se vinculan en la tabla SQL.

1. **Subida de Archivo**:
   - **Bucket**: `products-images`
   - **Ruta**: `/{producto_slug}/{timestamp}-{filename}`.
   - **Retorno**: URL pública de la imagen.

2. **Vinculación en BD**:
   - **Tabla**: `imagenes_producto`
   - **Datos**: `producto_id`, `url`.
   - **Lógica**: Si el producto ya tiene imagen principal, las siguientes son secundarias (o actualizar la existente).

---

## 6. 📊 Resumen de Estructura de Datos (Modelos Flutter Sugeridos)

### Modelo `Product`
```dart
class Product {
  final String id;
  final String nombre;
  final String slug;
  final double precioVenta;
  final String? descripcion;
  final int stockTotal;
  final bool activo;
  // ... otros campos
}
```

### Modelo `ProductVariant`
```dart
class ProductVariant {
  final String id;
  final String productId;
  final String talla;
  final String? color;
  final int stock;
  final double precioAdicional;
}
```

### Modelo `Coupon`
```dart
class Coupon {
  final String id;
  final String code;
  final String discountType; // 'percentage', 'fixed'
  final double value;
  final bool isActive;
  final DateTime expirationDate;
}
```

---

## 7. 📈 Dashboard Principal

El panel de inicio no es estático, carga estadísticas en tiempo real calculadas desde la base de datos.

### Métricas Clave (Cálculos)
1.  **Total Productos**: `count(*)` de tabla `productos` (activos).
2.  **Stock Total**: `sum(stock_total)` de tabla `productos`.
3.  **Valor Inventario**: `sum(precio_venta * stock_total)`.
4.  **Ventas Hoy**: Suma de `total_precio` de pedidos creados hoy.
5.  **Ventas Mes**: Suma de `total_precio` de pedidos del mes actual.
6.  **Pedidos en Proceso**: Conteo de pedidos con estado "en_proceso".
7.  **Devoluciones Activas**: Conteo de devoluciones con estado "pendiente".

---

## 8. 📂 Categorías y Marcas

Gestión completa (CRUD) para organizar los productos.

### A. Categorías
- **Tabla**: `categorias`
- **Campos**: `nombre`, `slug`, `imagen`, `padre_id` (para subcategorías).
- **Lógica**: Crear categoría genera un slug automático.

### B. Marcas
- **Tabla**: `marcas`
- **Campos**: `nombre`, `logo_url`, `web`.

---

## 9. ⭐ Gestión de Reseñas

El administrador modera las valoraciones de los usuarios.

- **Tabla**: `resenas`
- **Acciones**:
  - **Aprobar**: `UPDATE resenas SET estado = 'Aprobada' WHERE id = ?`
  - **Rechazar**: `UPDATE resenas SET estado = 'Rechazada' WHERE id = ?`
  - **Verificar Compra**: Toggle manual booleano `verificada_compra`.
  - **Eliminar**: `DELETE FROM resenas WHERE id = ?`

---

## 10. 📧 Sistema de Campañas (Newsletter)

Un módulo completo de Email Marketing integrado.

### Tablas Involucradas
1.  `campanas_email`: Almacena la campaña (asunto, nombre, contenido HTML, estado, tipo_segmento, etc.).
2.  `newsletter_subscriptions` / `marketing_subscribers`: Lista de emails suscritos (usuarios que han aceptado recibir correos).
3.  `campana_email_logs`: Registro detallado de cada email enviado durante una campaña (quién, cuándo, estado).

### Funcionalidades
- **Editor**: Permite escribir HTML personalizado o texto para el correo.
- **Sanitización**: Limpia scripts maliciosos antes de guardar.
- **Envío**:
  - Obtiene todos los suscriptores activos (`activo = true`).
  - Envía en lotes (Batching) para no saturar el servidor de correo.
  - Guarda un log por cada envío (exitoso o fallido).
  - Marca la campaña como `Enviada` al finalizar.
- **Duplicar**: Permite clonar una campaña existente para reutilizar el diseño o contenido.

---

## 11. 🏢 Configuración de Empresa

Datos globales que se muestran en facturas, pie de página y correos automáticos.

- **Tabla**: `company_settings` (Se asume que solo existe 1 registro único).
- **Campos**: `nombre`, `nif`, `email`, `telefono`, `direccion`, `ciudad`, `pais`, `codigo_postal`.
- **Lógica**: 
  - Al cargar: `SELECT * FROM company_settings LIMIT 1`.
  - Al guardar: Si existe registro, `UPDATE`; si no, `INSERT`.

---

## 12. 🔔 Preferencias y Notificaciones

Configuración personalizada de qué alertas recibe el administrador por correo o en la app.

- **Tabla**: `admin_preferences` (o gestión similar).
- **Toggles Disponibles**:
  - `new_order`: Notificar al recibir un nuevo pedido.
  - `low_stock`: Notificar cuando el stock de un producto baja de cierto umbral.
  - `returns`: Notificar cuando un cliente solicita una devolución.
  - `daily_summary`: Enviar un resumen diario de ventas.
  - `new_user`: Notificar nuevo registro de usuario.

---

## 📋 Resumen de Tablas Adicionales para Flutter

Para replicar el admin COMPLETO en Flutter, necesitas mapear estas tablas adicionales a modelos Dart:

- `categorias`
- `marcas`
- `resenas`
- `campanas_email`
- `newsletter_subscriptions`
- `campana_email_logs`
- `company_settings`
- `pedidos` (Gestión de estado: Pendiente -> Enviado -> Entregado -> Completado -> Cancelado)
- `devoluciones`

### Ejemplo de Modelo `Campaign` (Flutter)
```dart
class EmailCampaign {
  final String id;
  final String nombre;
  final String asunto;
  final String contenidoHtml; // HTML raw
  final String estado; // 'Borrador', 'Enviada'
  final int totalDestinatarios;
  final int totalEnviados;
  final DateTime? fechaEnvio;
  final DateTime? creadaEn;
  // ... constructores y métodos fromJson
}
```
