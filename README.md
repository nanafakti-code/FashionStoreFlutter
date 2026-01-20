# Fashion Store Flutter 🛍️

Una aplicación de tienda de moda moderna y completamente responsive construida con Flutter. Ofrece una experiencia de compra fluida en dispositivos móviles, tablets y desktops con un diseño Material 3 elegante y funcionalidades de e-commerce completas.

## ✨ Características Principales

### 🎨 Diseño y UI/UX
- **Material 3 Design System** - Implementación completa del nuevo lenguaje de diseño de Google
- **Paleta de Colores Moderna**
  - Primario: Azul elegante (#2563EB)
  - Secundario: Esmeralda fresca (#10B981)
  - Terciario: Ámbar cálido (#F59E0B)
- **Tipografía Professional** - Fuentes optimizadas para legibilidad
- **Animaciones Fluidas** - Transiciones y efectos visuales suaves

### 📱 Responsividad Total
- **Sistema de Breakpoints Inteligente**
  - Mobile: < 600px
  - Tablet: 600px - 1200px
  - Desktop: > 1200px
- **Layouts Adaptativos**
  - Home Screen: Hero flexible + Grid dinámico
  - Product Detail: Móvil (vertical) / Tablet (lado a lado)
  - Cart Screen: Lista (móvil) / Dual-layout (tablet)
  - Categories: Lista (móvil) / Grid 2-col (tablet) / Grid 3-col (desktop)
- **Optimización de Imágenes** - Carga eficiente con caché

### 🛒 Funcionalidades E-commerce
- **Catálogo de Productos**
  - Browse productos por categorías
  - Búsqueda y filtrado avanzado
  - Detalles completos del producto con galerías de imágenes
  - Stock en tiempo real

- **Carrito de Compras**
  - Agregar/remover productos
  - Selector de cantidad
  - Cálculo automático de totales
  - Persistencia local

- **Pedidos**
  - Historial de compras
  - Seguimiento de estado
  - Detalles de envío

- **Pago Seguro**
  - Integración Stripe
  - Múltiples métodos de pago
  - Validación segura de tarjetas

### 🔐 Autenticación y Seguridad
- **Sistema de Login/Registro**
  - Autenticación con Supabase
  - Almacenamiento seguro de credenciales
  - Recuperación de contraseña
- **JWT Tokens** - Sesiones seguras
- **Validación de Datos** - Entrada sanitizada

### 📦 Backend Integration
- **Supabase** - Base de datos PostgreSQL en tiempo real
- **Stripe** - Procesamiento de pagos seguro
- **Variables de Entorno** - Configuración segura con `flutter_dotenv`

## 🏗️ Arquitectura

```
lib/
├── config/              # Configuración global
│   ├── app_theme.dart   # Tema Material 3 + ResponsiveHelper
│   ├── routes.dart      # Rutas de navegación
│   ├── constants.dart   # Constantes de la app
│   └── env_config.dart  # Variables de entorno
├── models/              # Modelos de datos
│   ├── producto.dart
│   ├── carrito.dart
│   ├── pedido.dart
│   ├── usuario.dart
│   ├── cupon.dart
│   └── models.dart
├── screens/             # Pantallas de la aplicación
│   ├── home_screen.dart
│   ├── product_list_screen.dart
│   ├── product_detail_screen.dart
│   ├── categories_screen.dart
│   ├── cart_screen.dart
│   ├── login_screen.dart
│   └── screens.dart
├── services/            # Servicios de negocio
│   ├── product_service.dart
│   ├── cart_service.dart
│   ├── auth_service.dart
│   ├── order_service.dart
│   ├── stripe_service.dart
│   ├── supabase_service.dart
│   └── services.dart
├── widgets/             # Componentes reutilizables
│   ├── product_card.dart
│   ├── common_widgets.dart
│   ├── cart_widgets.dart
│   └── widgets.dart
└── main.dart            # Punto de entrada
```

### Patrón Responsivo
```dart
// ResponsiveHelper - Utility class centralizado
static int getGridCrossAxisCount(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return 2;          // Mobile
  if (width < 1200) return 3;         // Tablet
  return 4;                           // Desktop
}

// Uso en widgets
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
  ),
  // ...
)
```

## 🚀 Instalación y Setup

### Requisitos Previos
- Flutter SDK ≥ 3.0
- Dart ≥ 3.0
- Git

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/nanafakti-code/FashionStoreFlutter.git
cd FashionStoreFlutter
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar variables de entorno**
Crear archivo `.env` en la raíz del proyecto:
```env
SUPABASE_URL=tu_supabase_url
SUPABASE_ANON_KEY=tu_supabase_key
STRIPE_PUBLIC_KEY=tu_stripe_key
```

4. **Ejecutar la aplicación**
```bash
# Web
flutter run -d chrome

# Android (requiere emulador/dispositivo)
flutter run

# iOS (requiere macOS)
flutter run -d ios
```

## 📦 Dependencias Principales

```yaml
flutter:
  sdk: flutter

# Estado y Routing
riverpod: ^2.4.0          # State management
go_router: ^13.2.0        # Navegación declarativa

# Backend
supabase_flutter: ^1.10.0 # Database & Auth
flutter_stripe: ^10.2.0   # Pagos

# UI/UX
cached_network_image: ^3.3.0  # Imágenes con caché
shimmer: ^3.0.0               # Efectos de carga
flutter_svg: ^2.0.0           # SVG support

# Utilidades
flutter_dotenv: ^5.1.0        # Variables de entorno
intl: ^0.18.0                 # Localización
flutter_secure_storage: ^9.0.0 # Almacenamiento seguro
```

## 🎯 Características Responsive Implementadas

### Home Screen
- ✅ Hero section adaptativa (200px móvil, 250px tablet)
- ✅ Promo bar vertical (móvil) / horizontal (tablet)
- ✅ Grid de categorías dinámico
- ✅ Grid de productos con columnas adaptativas (2/3/4-5)

### Product Detail
- ✅ Galería de imágenes responsive
- ✅ Layout móvil: Scrollable vertical con SliverAppBar
- ✅ Layout tablet: Imagen + detalles lado a lado
- ✅ Selector de cantidad y carrito

### Cart Screen
- ✅ Lista scrollable (móvil)
- ✅ Dual-layout: Productos + resumen (tablet)
- ✅ Tarjeta flotante de resumen
- ✅ Elementos interactivos responsive

### Categories Screen
- ✅ Lista completa (móvil)
- ✅ Grid 2-columnas (tablet)
- ✅ Grid 3-columnas (desktop)

## 🔧 Configuración Avanzada

### Personalizar Tema
Editar `lib/config/app_theme.dart`:
```dart
class AppColors {
  static const Color primary = Color(0xFF2563EB);      // Azul
  static const Color secondary = Color(0xFF10B981);    // Esmeralda
  static const Color tertiary = Color(0xFFF59E0B);     // Ámbar
  // ...
}
```

### Breakpoints Personalizados
En `ResponsiveHelper`:
```dart
static const double mobileBreakpoint = 600;
static const double tabletBreakpoint = 1200;
```

### Supabase Configuration
En `lib/services/supabase_service.dart`:
- Cambiar URL de Supabase
- Configurar tablas de base de datos
- Ajustar políticas de acceso (RLS)

## 📊 Estructura de Base de Datos

### Tablas Principales
- **productos** - Catálogo de productos
- **categorias** - Categorías de productos
- **usuarios** - Datos de usuarios
- **carritos** - Carrito de compras
- **pedidos** - Historial de pedidos
- **items_pedido** - Detalles de cada pedido

## 🧪 Testing

```bash
# Ejecutar tests
flutter test

# Tests con cobertura
flutter test --coverage
```

## 📈 Rendimiento

- **Lazy Loading** - Imágenes y datos cargados bajo demanda
- **State Management** - Riverpod minimiza rebuilds innecesarios
- **Caché de Imágenes** - `cached_network_image` con persistencia
- **Code Splitting** - Rutas lazy con go_router

## 🐛 Debugging

```bash
# Análisis de código
flutter analyze

# Problemas frecuentes
flutter doctor

# Modo debug con DevTools
flutter run -d chrome --web-launch-url=http://localhost:8080
```

## 📚 Recursos Útiles

- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io/)
- [Supabase Docs](https://supabase.com/docs)
- [Stripe Flutter](https://pub.dev/packages/flutter_stripe)

## 📝 Notas de Desarrollo

### Mejoras Implementadas (v1.0.0)
- ✅ Implementación completa de responsive design
- ✅ Modernización del tema con Material 3
- ✅ Sistema centralizado de breakpoints
- ✅ Layouts adaptativos en todas las pantallas
- ✅ Validación y corrección de errores de compilación

### Próximas Mejoras Futuras
- 🔄 Sistema de cupones y descuentos
- 🔄 Búsqueda avanzada y filtros
- 🔄 Reseñas y calificaciones de productos
- 🔄 Wishlist/Favoritos
- 🔄 Notificaciones push
- 🔄 Soporte multiidioma (i18n)

## ⚖️ Licencia

Este proyecto está bajo licencia MIT. Ver archivo `LICENSE` para más detalles.

## 👨‍💼 Autor

Desarrollado como proyecto de Desarrollo de Interfaces - DAM 2º

## 🤝 Contribuciones

Las contribuciones son bienvenidas! Por favor:
1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📞 Soporte

Si encuentras problemas:
1. Verifica que cumples con todos los requisitos previos
2. Ejecuta `flutter pub get` nuevamente
3. Limpia la build: `flutter clean`
4. Abre un issue en GitHub

---

**Made with ❤️ using Flutter**
