# 🚀 Fashion Store: E-Commerce de Electrónica Reacondicionada

---

<div align="center">
  <img src="assets/images/app_icon.png" width="150" alt="Fashion Store Logo">
  <p align="center">
    <strong>Una experiencia premium para dar una segunda vida a la tecnología.</strong>
  </p>

  [![Flutter](https://img.shields.io/badge/Flutter-3.3.4%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-2.18%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
  [![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
  [![Stripe](https://img.shields.io/badge/Payments-Stripe-635BFF?logo=stripe&logoColor=white)](https://stripe.com)
  [![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

---

## 🚀 Descripción del Proyecto

**Fashion Store** es una plataforma de comercio electrónico móvil moderna y ágil, diseñada específicamente para el mercado de **productos electrónicos reacondicionados** (smartphones, portátiles, tablets y accesorios).

### El Problema
La compra de tecnología de segunda mano a menudo genera desconfianza debido a la falta de garantías, descripciones imprecisas y procesos de compra poco seguros. Muchos usuarios quieren ahorrar y ayudar al medio ambiente, pero temen recibir un producto defectuoso.

### Nuestra Solución
Fashion Store resuelve esto mediante un entorno **B2C (Business to Consumer)** profesional. Ofrecemos una experiencia de usuario premium que iguala a la de las grandes tiendas de productos nuevos, garantizando:
- **Transparencia total** en el estado físico del dispositivo (Como nuevo, Muy bueno, Correcto).
- **Seguridad** en los pagos a través de Stripe.
- **Confianza** mediante un sistema nativo de reseñas verificadas y soporte de devoluciones.
- **Economía Circular**: Reducción de la basura electrónica (e-waste) facilitando el acceso a hardware de alta gama a precios reducidos.

---

## ✨ Características Principales

### 👤 Experiencia del Cliente
- **Catálogo Dinámico**: Filtros avanzados por marca, categoría y estado estético.
- **Gestión de Stock en Tiempo Real**: Sistema de reservas automáticas al añadir al carrito para evitar el *overselling*.
- **Checkout Seguro**: Pasarela de pago integrada con Stripe cumpliendo estándares PCI.
- **Post-Venta Proactiva**: Historial de pedidos, descarga de facturas en PDF y sistema de tickets de devolución.
- **Fidelización**: Sistema de cupones de descuento y suscripción a Newsletter con recompensas automáticas.
- **Reseñas Verificadas**: Valoraciones reales asociadas a pedidos entregados para garantizar la veracidad.

### 👑 Panel de Administración (CRM Embebido)
- **Dashboard Estadístico**: Gráficos de ventas y métricas de rendimiento en tiempo real (`fl_chart`).
- **Gestión de Inventario**: Control total sobre productos, marcas y variantes (almacenamiento, colores, stock).
- **Moderación**: Sistema de aprobación/rechazo de reseñas y gestión de solicitudes de devolución.
- **Marketing Automation**: Generación de cupones masivos y envío de campañas de correo electrónico (SMTP).
- **Reportería**: Generación de resúmenes diarios, mensuales y anuales de ventas y devoluciones en PDF.

---

## 🧱 Arquitectura y Stack Tecnológico

La aplicación sigue el patrón de **Arquitectura por Características (Feature-based)** con una separación clara de responsabilidades (Model-View-Controller adaptado), asegurando escalabilidad y mantenibilidad.

### Stack Técnico
- **Framework:** [Flutter](https://flutter.dev) (Rendimiento nativo multiplataforma).
- **Lenguaje:** [Dart](https://dart.dev) (Tipado fuerte y Null-safety).
- **Gestión de Estado:** [Riverpod](https://riverpod.dev) (Inmutable, testable y reactivo).
- **Navegación:** [GoRouter](https://pub.dev/packages/go_router) (Rutas declarativas y Deep Linking).
- **Backend:** [Supabase](https://supabase.com) (PostgreSQL, Auth, Storage y Realtime).
- **Pasarela de Pagos:** [Stripe](https://stripe.com) (Seguridad bancaria internacional).
- **Generación de Modelos:** [Freezed](https://pub.dev/packages/freezed) & [JSON Serializable](https://pub.dev/packages/json_serializable).

---

## 📱 Capturas de Pantalla (Placeholders)

| Home Screen | Product Detail | Admin Dashboard |
| :---: | :---: | :---: |
| ![Home](https://via.placeholder.com/200x400?text=Home+Feed) | ![Detail](https://via.placeholder.com/200x400?text=Product+Details) | ![Admin](https://via.placeholder.com/200x400?text=Admin+Panel) |

---

## ⚙️ Instalación y Puesta en Marcha

### Requisitos Previos
- Flutter SDK `>= 3.3.4`
- Dart SDK `>= 2.18.0`
- Un proyecto activo en [Supabase](https://app.supabase.com/)

### Pasos
1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/fashion_store_flutter.git
   cd fashion_store_flutter
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Generar código (Modelos y Providers)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configurar variables de entorno**
   Crea un archivo `.env` en la raíz (ver sección de Variables de Entorno).

5. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

---

## 🔐 Variables de Entorno

Crea un archivo llamado `.env` en la raíz del proyecto con el siguiente formato:

```env
# Supabase Configuration
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key-aqui

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_test_...

# SMTP Configuration (para envío de facturas y marketing)
SMTP_USER=no-reply@tudominio.com
SMTP_PASS=tu-password-smtp
```

---

## 🧪 Testing

Para ejecutar la suite de pruebas unitarias y de widgets:

```bash
flutter test
```

*Nota: Utilizamos `Mocktail` para el mockeo de servicios y `ProviderContainer` para pruebas aisladas de lógica de negocio.*

---

## 📦 Estructura del Proyecto

```text
lib/
├── app/
│   ├── data/           # Modelos (Freezed) y Servicios (Repositorios API)
│   ├── modules/        # UI por características (auth, cart, home, admin, etc.)
│   └── providers/      # Lógica de negocio y gestión de estado (Riverpod)
├── config/             # Temas, Rutas centralizadas y Constantes
├── core/               # Utilidades, formateadores y helpers transversales
└── main.dart           # Inicialización de Supabase y punto de entrada
```

---

## 🚧 Roadmap / Mejoras Futuras

- [ ] **Multilenguaje (i18n)**: Soporte completo para Inglés y otros mercados europeos.
- [ ] **Notificaciones Push**: Integrar Firebase Cloud Messaging para avisos de pedidos y carritos abandonados.
- [ ] **Buscador con IA**: Implementar búsqueda semántica para encontrar productos por lenguaje natural.
- [ ] **Admin Web Panel**: Versión de escritorio exclusiva para la gestión masiva de inventario.

---

## 🤝 Contribución

¡Las contribuciones son lo que hacen a la comunidad de código abierto un lugar increíble!
1. Haz un **Fork** del proyecto.
2. Crea una nueva **Rama** (`git checkout -b feature/AmazingFeature`).
3. Haz **Commit** de tus cambios (`git commit -m 'Add AmazingFeature'`).
4. Haz **Push** a la rama (`git push origin feature/AmazingFeature`).
5. Abre un **Pull Request**.

---

## 📄 Licencia

Este proyecto está bajo la Licencia **MIT**. Consulta el archivo `LICENSE` para más detalles.

---

<div align="center">
  <p>Desarrollado con ❤️ para transformar el comercio de electrónica reacondicionada.</p>
</div>
