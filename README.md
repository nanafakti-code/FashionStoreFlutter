# FashionStore Flutter

Aplicación de e-commerce de moda migrada desde Astro a Flutter, manteniendo la misma base de datos (Supabase), lógica de negocio, diseño visual y funcionalidades.

## Arquitectura

- **Framework**: Flutter 3.x + Dart >=3.3.4
- **State Management**: GetX (MVVM)
- **Backend**: Supabase (Auth + PostgreSQL + Storage)
- **Pagos**: Stripe
- **Estructura**: Controllers → Services → Supabase

```
lib/
├── main.dart                    # Entry point + registro global de servicios
├── config/
│   ├── theme/
│   │   ├── app_colors.dart      # Paleta FashionStore (Navy, Cream, Gold, Green)
│   │   └── app_theme.dart       # Material 3 theme con Poppins
│   ├── constants.dart           # Constantes (envío, IVA, timeouts)
│   └── env_config.dart          # Variables de entorno (.env)
└── app/
    ├── routes/
    │   ├── app_routes.dart      # Definición de rutas (15 rutas)
    │   └── app_pages.dart       # Registro de páginas con bindings
    ├── bindings/
    │   └── app_binding.dart     # 10 binding classes (DI por pantalla)
    ├── controllers/             # 11 controllers GetX
    ├── data/
    │   ├── models/              # ProductoModel, CarritoModel, PedidoModel, etc.
    │   ├── services/            # 7 servicios (Auth, Cart, Order, Admin, etc.)
    │   └── repositories/        # ProductoRepository, CategoriaRepository
    ├── modules/                 # Pantallas organizadas por feature
    │   ├── home/
    │   ├── product_detail/
    │   ├── auth/ (login, register)
    │   ├── checkout/
    │   ├── profile/
    │   ├── orders/
    │   ├── wishlist/
    │   ├── search/
    │   └── admin/ (login, dashboard con 8 tabs)
    ├── widgets/                 # ProductCard, CommonWidgets
    └── utils/                   # ResponsiveHelper
```

## Funcionalidades

### Usuario
- Catálogo de productos con filtros por categoría y búsqueda
- Detalle de producto con galería de imágenes y reseñas
- Carrito de compra (offline-first con SharedPreferences)
- Checkout con dirección de envío, cupones de descuento y resumen
- Gestión de pedidos (historial, detalle, cancelación)
- Lista de deseos (favoritos)
- Perfil de usuario con direcciones guardadas
- Autenticación (login, registro, recuperación de contraseña)

### Administrador
- Dashboard con estadísticas (productos, pedidos, usuarios, ingresos)
- CRUD de productos
- Gestión de pedidos (cambio de estado)
- Gestión de usuarios (roles)
- Moderación de reseñas
- Cupones de descuento (crear, validar, eliminar)
- Devoluciones
- Campañas de email / Newsletter

## Requisitos

- Flutter SDK >=3.3.4
- Dart SDK >=3.3.4
- Cuenta de Supabase con base de datos configurada
- Cuenta de Stripe (clave publicable)

## Instalación

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Configurar variables de entorno

Crear archivo `.env` en la raíz del proyecto:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
STRIPE_PUBLISHABLE_KEY=pk_test_tu-stripe-key
APP_URL=http://localhost:4321
```

### 3. Tablas requeridas en Supabase

| Tabla | Descripción |
|-------|-------------|
| `usuarios` | Perfiles de usuario (nombre, email, rol, teléfono, avatar) |
| `productos` | Catálogo de productos (nombre, precio, stock, descripción) |
| `categorias` | Categorías de productos |
| `marcas` | Marcas de productos |
| `imagenes_producto` | Imágenes asociadas a productos |
| `ordenes` | Pedidos realizados |
| `orden_items` | Items de cada pedido |
| `cart_items` | Carrito persistente en servidor |
| `resenas` | Reseñas de productos |
| `lista_deseos` | Favoritos del usuario |
| `direcciones` | Direcciones de envío guardadas |
| `cupones_descuento` | Cupones de descuento |
| `devoluciones` | Solicitudes de devolución |
| `newsletter_subscriptions` | Suscripciones al newsletter |
| `campanas_email` | Campañas de email marketing |

### 4. Ejecutar

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## Paleta de Colores

| Color | Hex | Uso |
|-------|-----|-----|
| Navy | `#102A43` | Color primario, headers |
| Charcoal | `#1A1A1A` | Textos principales |
| Cream | `#F1ECE3` | Fondos, backgrounds |
| Gold | `#D4A574` | Acentos, categorías, detalles |
| Green | `#00AA45` | CTAs, botones de acción, precios |

## Dependencias principales

| Paquete | Versión | Uso |
|---------|---------|-----|
| `get` | ^4.6.6 | State management, DI, routing |
| `supabase_flutter` | ^2.3.0 | Backend, auth, database |
| `flutter_stripe` | ^10.1.0 | Pagos con Stripe |
| `cached_network_image` | ^3.3.0 | Caché de imágenes |
| `flutter_dotenv` | ^5.1.0 | Variables de entorno |
| `flutter_secure_storage` | ^9.0.0 | Almacenamiento seguro |
| `shared_preferences` | ^2.5.3 | Persistencia local (carrito) |
| `shimmer` | ^3.0.0 | Efectos de carga |
| `flutter_svg` | ^2.2.0 | Iconos SVG |
| `intl` | ^0.20.0 | Formateo de fechas/números |

## Credenciales de Admin

Email: `admin@fashionstore.com`
(La contraseña se configura en Supabase Auth)

## Pantallas

| Ruta | Pantalla | Descripción |
|------|----------|-------------|
| `/` | Home | Productos destacados, categorías |
| `/products` | Productos | Catálogo completo con filtros |
| `/product-detail` | Detalle | Imágenes, info, reseñas, añadir al carrito |
| `/cart` | Carrito | Items, cantidades, total |
| `/checkout` | Checkout | Envío, cupón, resumen, pagar |
| `/login` | Login | Inicio de sesión |
| `/register` | Registro | Crear cuenta |
| `/profile` | Perfil | Datos del usuario, menú |
| `/orders` | Pedidos | Historial de pedidos |
| `/order-detail` | Detalle pedido | Items, totales, estado |
| `/wishlist` | Favoritos | Lista de deseos |
| `/search` | Búsqueda | Buscar productos con filtros |
| `/admin-login` | Admin Login | Acceso al panel admin |
| `/admin` | Admin Dashboard | 8 tabs de gestión |
