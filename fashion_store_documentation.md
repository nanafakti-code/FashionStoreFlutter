<div align="center">
  <img src="c:/Users/rafae/Desktop/2DAM/Desarollo de Interfaces/fashion_store_flutter/assets/images/app_icon.png" width="200" alt="Fashion Store Logo">
</div>

# Documentación Técnica: Fashion Store

---

## 1. Introducción

### Objetivo del proyecto
El objetivo de **Fashion Store** es proporcionar una plataforma de comercio electrónico móvil, ágil y moderna, enfocada en la venta de productos electrónicos reacondicionados (smatphones, portátiles, tablets, accesorios, etc.). La aplicación busca ofrecer una experiencia de usuario (UX) premium y nativa, facilitando la búsqueda, selección y compra de dispositivos de alta tecnología con garantías, al mismo tiempo que promueve la economía circular.

### Alcance de la aplicación
La aplicación cubre el ciclo de vida completo del comercio electrónico desde la perspectiva del usuario final y del administrador:
- **Cliente:** Exploración del catálogo, gestión de carrito, procesos de *checkout* (pasarela de pago), seguimiento del historial de pedidos, gestión de perfiles/direcciones, sistema de reseñas y programas de fidelización (cupones y newsletter).
- **Administrador:** Un *Dashboard* completo integrado en la misma app (accesible mediante validación de rol/credenciales) para la gestión visual de estadísticas, inventario (productos, marcas, categorías), control de pedidos, procesamiento de devoluciones, validación de reseñas y automatización de marketing (campañas de correo y cupones).

### Público objetivo
El público primario está compuesto por consumidores de tecnología conscientes del medio ambiente y del presupuesto, que buscan dispositivos electrónicos de gama alta a precios reducidos, pero sin sacrificar la seguridad de una garantía comercial. El público secundario incluye entusiastas de la tecnología ("techies") que compran hardware secundario para pruebas o reparaciones.

### Contexto del mercado de productos reacondicionados
El mercado de la electrónica reacondicionada está en auge debido a la inflación de los dispositivos nuevos y a una creciente conciencia ecológica sobre la basura electrónica (e-waste). **Fashion Store** aterriza en este nicho ofreciendo no solo productos, sino una experiencia de compra móvil que iguala o supera a las de aplicaciones de dispositivos nuevos, generando confianza mediante reseñas transparentes, facturación clara y un sistema de devoluciones estructurado.

---

## 2. Descripción general del sistema

### Problema que resuelve la aplicación
La compra de tecnología de segunda mano a menudo genera desconfianza por la falta de garantías, descripciones inexactas de los productos o procesos de compra inseguros. **Fashion Store** centraliza este ecosistema en un entorno profesional B2C (Business to Consumer), garantizando la procedencia, el estado del dispositivo y proporcionando la seguridad de transacciones bajo plataformas globales (como Stripe).

### Visión general de la solución
Una aplicación móvil construida en **Flutter** para lograr rendimiento nativo en múltiples plataformas (iOS y Android) y respaldada por **Supabase** como Backend as a Service (BaaS). Esto permite tener sincronismo en tiempo real (por ejemplo, en sistemas de reservas de stock al añadir al carrito), autenticación segura y almacenamiento robusto de datos e imágenes.

### Propuesta de valor
- **Inventario garantizado:** Filtros detallados por estado físico del dispositivo (Como nuevo, Muy bueno, Correcto).
- **Seguridad en la transacción:** Checkout robusto con sistema de reservas para evitar el exceso de ventas (*overselling*).
- **Transparencia:** Emisión de facturas automatizadas en PDF y gestión nativa de reseñas por artículo.
- **Fidelización integrada:** Suscripciones a newsletters y generador de cupones auto-asignables en la base de datos.
- **Micro-gestión Admin:** Tablero de métricas en tiempo real embebido, que permite gestionar campañas de remarketing sin salir de la plataforma.

### Características principales
1. **Catálogo dinámico:** Filtros, categorías, marcas e historial de búsqueda.
2. **Sistema de Cart y Checkout:** Sincronización de stock en tiempo real mediante `Supabase Realtime`.
3. **Roles de usuario:** Experiencia diferenciada entre Cliente y Administrador.
4. **CRM de Administración embebido:** Panel estadístico con gráficos y sección de *Marketing*.
5. **Comunicación automatizada:** Integración de servidor SMTP para correos transaccionales (facturas, newsletters, notificaciones de pedidos).

---

## 3. Arquitectura del sistema

### Explicación detallada de la arquitectura cliente-servidor
La aplicación sigue un enfoque estricto de **Cliente Pesado / Backend Serverless**:
- **Cliente (Flutter):** Maneja toda la lógica de presentación, el enrutamiento (`go_router`), la gestión de estado (`flutter_riverpod`) y la validación de formularios.
- **Servidor (Supabase):** Actúa como base de datos PostgreSQL, proveedor de autenticación y gestor de almacenamiento de objetos (Storage para avatares y fotos de productos). Se encarga también de las políticas de seguridad a nivel de base de datos (RLS - Row Level Security).
- **Servicios externos:** SMTP para envíos (Mailer) y *Stripe* para orquestación de pagos.

### Uso del Patrón MVC (Adaptado a Flutter)
Aunque estrictamente es una arquitectura impulsada por Notifiers (StateNotifier / AsyncNotifier), se mapea funcionalmente a un MVC (Model-View-Controller) tradicional distribuido por características (*Feature-based folder structure*):
- **Model (Datos):** Ubicado en `lib/app/data/models`. Las clases se generan utilizando `Freezed` y `json_serializable` para garantizar inmutabilidad y parseo seguro tipo-fuerte.
- **View (Interfaz):** Ubicadas en `lib/app/modules/[feature]`. Construidas declarativamente con widgets de Flutter. Escuchan pasivamente a los Providers.
- **Controller (Proveedores / StateNotifiers):** Ubicados en `lib/app/providers`. Contienen la lógica de negocio, consumen los _Services_ y emiten nuevos estados (cargando, éxito, error) a la UI.
- **Services (Capa de abstracción):** Ubicados en `lib/app/data/services`. Actúan como repositorios concretos que ejecutan las llamadas HTTP o consultas a la constante de Supabase.

### Flujo de datos entre frontend y backend
1. **Acción UI:** Un usuario pulsa "Añadir al carrito".
2. **Provider (Controller):** El `CartNotifier` intercepta la acción.
3. **Service:** El Notifier llama a `CartService.addToCart(productId)`.
4. **Backend:** El `CartService` ejecuta una mutación asíncrona hacia Supabase (reserva de stock global).
5. **State Mutation:** Supabase devuelve éxito, el `CartNotifier` actualiza su estado inmutable con el nuevo total de artículos.
6. **Re-render UI:** Cualquier Widget que esté observando (`ref.watch`) al `CartNotifier` se redibuja atómicamente mostrando el ícono del carrito con el nuevo número.

### Justificación de la arquitectura elegida
- **Riverpod** soluciona el problema de inyección de dependencias cíclicas y fugas de memoria típicas de arquitecturas obsoletas como `Provider` puro o `MVC Vanilla`. Al ser inmutable "por diseño", previene bugs de estado compartidos y condiciones de carrera.
- **Supabase** (basado en Postgres) proporciona la robustez transaccional requerida para un E-Commerce financiero (Foreign Keys, Constraints), lo que sería inmensamente complejo de mantener íntegro en bases de datos NoSQL como Firebase.

---

## 4. Tecnologías utilizadas

### Flutter y Dart
- **Flutter SDK (`>=3.3.4`):** Framework UI multiplataforma de Google, elegido por su capacidad de construir UIs hermosas y a 60/120 fps de manera unificada.
- **Dart:** Lenguaje de tipado estricto (*null-safety*) escalable que permite la precompilación *AOT* (Ahead of Time) logrando rendimiento casi nativo.

### Backend utilizado: Supabase
Plataforma de código abierto alternativa a Firebase construida sobre **PostgreSQL**. Se justifica su uso por:
- Soporte nativo y relacional (crucial para un e-commerce: relaciones *User -> Orders -> OrderItems*).
- Capacidad de *Realtime Sync* (vía WebSockets).
- Row Level Security (RLS) que blinda los esquemas a nivel de motor.

### Bases de Datos (PostgreSQL vía Supabase)
Base principal relacional. Todas las mutaciones de stock, lectura de inventarios, credenciales y cupones residen en un esquema normalizado de alto rendimiento.

### Librerías principales (Dependencias Core)
- **`flutter_riverpod` & `riverpod_annotation`:** Manejo de estado escalable.
- **`go_router`:** Manejo de rutas declarativas estandarizadas, útil para *Deep Linking*.
- **`freezed_annotation` / `json_serializable`:** Generación de clases de datos (Modelos) con soporte integral para copiado profundo (`copyWith`) e inmutabilidad, esenciales para comparar estados de Riverpod.
- **`flutter_stripe`:** SDK oficial para procesamiento seguro de pagos cumpliendo el estándar PCI.
- **`pdf` & `path_provider`:** Para la generación procedural y exportación en disco de facturas PDF.
- **`fl_chart`:** Utilizada extensamente en el Panel de Administración para graficar métricas de ventas.
- **`mailer`:** Servicio en cliente acoplado a un SMTP configurado por entorno para despachar automatizaciones de bienvenida y tickets.

### Herramientas de desarrollo
- **`build_runner`:** Para generar código automáticamente de Freezed y serializadores.
- **`flutter_lints` / `riverpod_lint`:** Reglas estáticas de código para forzar directivas limpias.

---

## 5. Estructura del proyecto

El proyecto utiliza una carpeta estructural orientada a *Características (Feature-based)* pero respetando principios limpios:

```text
lib/
├── app/
│   ├── data/
│   │   ├── models/           # Clases Freezed de datos (Usuario, Pedido, Producto)
│   │   └── services/         # APIs y repositorios (AuthService, CartService, DatabaseService)
│   ├── modules/              # Funciones/Vistas (UI)
│   │   ├── admin/            # Dashboard Administrativo y todos sus sub-módulos (marketing, reseñas)
│   │   ├── auth/             # Login, Registro, Recuperación
│   │   ├── cart/             # Carrito y Checkout
│   │   ├── home/             # Main Feed, Newsletter Section
│   │   ├── orders/           # Historial y Detalles de pedidos
│   │   └── profile/          # Gestión de usuario y direcciones
│   └── providers/            # Riverpod Notifiers (AdminProvider, AuthProvider, CartProvider)
├── config/
│   ├── theme/                # Sistema de Diseño, colores, tipografías (AppColors, AppTypography)
│   ├── router/               # Rutas centralizadas de GoRouter
│   └── constants/            # Variables estáticas
├── core/
│   ├── utils/                # Utilidades puras, formateadores de fechas, manejadores de errores
├── main.dart                 # Punto de entrada y configuraciones asíncronas
```

### Roles de las capas:
- **Models:** Sólo definen propiedades. Nunca ejecutan lógica interactiva.
- **Views (Modules):** Archivos `.dart` orientados a componentes. Se nutren exclusivamente de `ref.watch`. Contienen submódulos `widgets/` locales para evitar UI puré.
- **Providers:** Reglas de negocio. P. ej: Comprobar que un cupón introducido no esté expirado, aplicar un descuento al estado del cart en memoria, y solicitar el cobro.
- **Services:** I/O Exclusivo (Internet, Bases de Datos o Archivos Locales).

### Buenas prácticas aplicadas
- **Single Source of Truth:** El estado de la aplicación siempre proviene desde Riverpod, nunca de `StatefulWidget` variables disueltas, a menos que sean animaciones o Controladores de Texto *ephemerales*.
- **Variables de Entorno:** Credenciales SMTP, llaves públicas de Stripe y URL's de la API se inyectan a través de `flutter_dotenv` y no viajan en el control de versiones.

---

## 6. Base de Datos (PostgreSQL / Supabase)

### Modelo de Datos (Esquema simplificado)
El modelo relacional está distribuido en esquemas públicos con RLS rígido.

#### Tablas Principales:
1.  **`usuarios`**: Vinculada transversalmente a Supabase Auth (`auth.users`).
    - Campos: `id` (UUID - PK), `nombre`, `apellidos`, `telefono`, `admin` (boolean).
2.  **`productos`**: Catálogo base.
    - Campos: `id`, `nombre`, `descripcion`, `precio_base`, `imagen_url`, `categoria_id`, `id_marca`.
3.  **`variantes`**: Diferentes versiones de un producto (ej. iPhone negro 64GB / blanco 128GB).
    - Campos: `id`, `producto_id` (FK), `color`, `almacenamiento`, `estado` (Como nuevo, etc.), `stock_disponible`, `precio_ajuste`.
4.  **`ordenes` / `orden_items`**: Transaccionalidad de compras.
    - Campos Orden: `id`, `usuario_id`, `total`, `estado` (Pendiente, Enviada), `direccion_envio`, `numero_orden`.
5.  **`coupons`**: Sistema de descuentos.
    - Campos: `codigo`, `discount_type`, `value`, `assigned_user_id` (opcional exclusivo).
6.  **`newsletter_subscriptions` & `campanas_email`**: Marketing CRM.
    - Campos Subs: `email`, `codigo_descuento`, `activo`, `created_at`.
7.  **`resenas`**: Valoraciones sociales de artículos.
    - Campos: `producto_id`, `usuario_id`, `calificacion`, `comentario`, `estado` (Pendiente/Aprobada).

### Relaciones entre entidades
- `Usuarios` 1:N `Ordenes`
- `Ordenes` 1:N `Orden_Items`
- `Productos` 1:N `Variantes`
- `Productos` 1:N `Resenas`
- `Usuarios` 1:N `Coupons` (Si el cupón es instanciado como premio por newsletter).

### Consideraciones de Integridad Referencial
- Hay eliminación en cascada (`ON DELETE CASCADE`) configurada desde Variantes a Productos para prevenir stocks fantasmas.
- El sistema utiliza Restricciones (*Constraints*) como `stock_disponible >= 0` a nivel DB para proteger contra transacciones paralelas de compra masiva.

---

## 7. Funcionalidades Principales y Lógica de Negocio

### Registro e Inicio de sesión
Utiliza los métodos de `Supabase Auth`. Los JWT generados se mantienen en la sesión del dispositivo. Tras el registro (`signUp`), se lanza un "Trigger" en la base de datos de PostgreSQL que clona parte de la data del perfil a la tabla pública `usuarios` para posibilitar relaciones extranjeras y RLS. 

### Catálogo de Productos Reacondicionados
El módulo de la tienda hace consultas complejas (Joins) trayéndose `productos` con sus respectivas `variantes`. Esto permite mostrar tarjetas de producto dinámicas con etiquetas visuales sobre el estado de reacondicionamiento y sus diferentes puntos de precio, en caso de variaciones de almacenamiento.

### Carrito y Sincronismo Global
- El carrito es reactivo localmente, pero cada mutación (Añadir / Eliminar) lanza una petición silenciosa al `CartService` para apartar inventario restando al campo `stock_disponible` y creando un bloqueo temporal si fuese necesario, evitando conflictos de "stock cero" durante temporadas pico.

### Proceso de Checkout
1. El `CartProvider` compila los subtotales locales, aplicando cupones mediante el `CouponService` y calculando recargos de impuestos/envío.
2. Genera un objeto estructurado para el servicio de Stripe.
3. Stripe retorna el intento de pago (*Payment Intent*).
4. El UI levanta el SDK Bottomsheet (`flutter_stripe`) de pago.
5. Al aprobarse, se llama a Supabase para la creación atómica del insert `ordenes` y `orden_items`, y se envía automáticamente el mail confirmando la orden gracias a la lógica implementada en `InvoiceService`.

### Gestión del Panel Administrativo (Admin Dashboard)
Un módulo altamente complejo en el que los usuarios marcados con el flag `admin: true` ven una serie de utilidades en su cajón de navegación:
- **Resumen Financiero:** Un gráfico de líneas cargado con Data de Ventas (`fl_chart`).
- **Reseñas:** Interfaz asimétrica de moderación (Aceptar / Rechazar comentarios) que impacta en lo que otros usuarios pueden leer.
- **Marketing:** Pestaña bidimensional para lectura de Suscriptores y ejecución visual de Campañas en Masa. Funciona inyectando códigos dinámicos generados en la tabla temporal.

---

## 8. Flujo de la Aplicación

### Recorrido completo de Usuario Estándar (Paso a Paso)
1. **Onboarding / Splash:** Carga caché estática de tipografías.
2. **Autenticación (Opcional en exploración):** El usuario puede navegar el catálogo sin login. Un _Auth Guard_ en `go_router` bloquea la ruta hacia `/checkout` temporalizando la acción hasta que haga login o se cree la cuenta rápida.
3. **Inicio (Home Screen):** Banners modulares promocionales, sección horizontal de marcas destacadas y abajo la captura tipo Newsletter.
4. **Detalle Producto:** Visita el detalle, escoge el grado del dispositivo ("Excelente") y Storage ("256GB"), y presiona "Comprar".
5. **Checkout:** Selecciona una de sus tarjetas de dirección en la `Profile Screen`, introduce el cupón `NEWS-XXXX` que le llegó a su correo. Paga en 2 toques.
6. **Post-Venta:** Entra al perfil -> "Mis pedidos", descarga la factura de PDF nativa, y eventualmente aprieta el botón de "Devolver artículo", generando un ticket `DevolucionModel` que el Admin recibirá en su panel.

### Manejo de estados y errores
Riverpod se utiliza para el manejo nativo del patrón `AsyncValue` (Loading, Data, Error).
Casi todas las pantallas construyen sus UIs usando `state.when(data: ..., loading: ..., error: ...)` lo cual garantiza que, frente a fallas de Red o en la validación de Supabase, la UI pinte un mensaje amable *"Error al contactar con el proveedor de datos"* en vez de pantallas rojas del error nativo de Flutter.

---

## 9. Instalación y Configuración

### Requisitos previos
- Emulador de Android / iOS actualizado.
- Entorno de Flutter 3.3.4+ configurado (`flutter doctor` en verde).
- Cuenta activa en Supabase (Proyecto creado).

### Configuración del backend (Supabase)
1. En SQL Editor, ejecutar todos los scripts de inicialización de esquemas (`schema.sql`).
2. Desactivar *Email Confirmations* en los ajustes de Supabase Auth si se requiere desarrollo sin interrupciones o, en caso contrario, habilitar los hooks del SMTP.
3. Obtener el `Project URL` y `Anon Key`.

### Variables entorno (`.env`)
Crear en la raíz de la ruta un archivo `.env` (declarado en `pubspec.yaml`):

```env
SUPABASE_URL=https://[TU_PROYECTO].supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1...
SMTP_USER=no-reply@tudominio.com
SMTP_PASS=tu_password_smtp
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

### Ejecutar el proyecto
```bash
# Refresca las dependencias
flutter pub get
# Re-crea las clases inmutables (Obligatorio en cada pull que contenga cambios de modelo!)
flutter pub run build_runner build --delete-conflicting-outputs
# Ejecuta al dispositivo por defecto
flutter run
```

---

## 10. Pruebas y Estrategia de Testing

- **Filosofía Base:** Al separar estrictamente el código en `Providers` y `Services`, las pruebas pueden realizarse en aislamiento haciendo uso del patrón de inyección de Mockups en el *Provider Container*.
- **Unitarias (Logic Testing):** Testean el comportamiento de las clases Model (ej. Validar que la función `calcularDescuento` del `CuponModel` funcione si se le aplican combinaciones negativas).
- **Widgets (Integration UI):** Aserción de elementos gráficos. Se construyen pantallas proporcionando *MockProviders* que retornan estados controlados de error o superposición, validando las respuestas visuales (`expect(find.byType(CircularProgressIndicator), findsOneWidget)`).

---

## 11. Seguridad y Cifrado

### Autenticación y Autorización (Backend RLS)
En Supabase, las Row Level Security Policies prohíben, a nivel de base de datos, que se realicen acciones maliciosas (ej. un Usuario A intentando sobreescribir la orden de un Usuario B enviando comandos cUrl forjados).
Para acceder o modificar ciertos segmentos exclusivos (ej. `resenas` estado Aprobado y la tabla de `campanas_email`), la RLS exige que en la cabecera JWT del usuario, el campo asociado coincida con el status `admin = true`.

### Protección Interna (Client-side)
- Los tokens sensibles de administradores (si fuesen requeridos persistir más allá del JWT) como API Keys intermedias usan `flutter_secure_storage` bajo `AES` cifrado por la llave del contenedor de hardware (Keychain/Keystore).

---

## 12. Rendimiento y Escalabilidad

- **Imágenes:** Renderizado estricto vía `cached_network_image`, minimizando las recargas en listas al inyectar directamente archivos locales descargados previamente del CDN de Supabase.
- **Lazy Loading (UI):** Uso agresivo de `ListView.builder` / `ListView.separated` para crear listas virtuales y de scroll con memoria preasignada. Las tablas administrativas solo renderizan los elementos visibles con paginaciones conceptuales.
- **Provider Scoping:** Los `StateNotifier` que se vuelven demasiado inmensos rompen la escalabilidad. La aplicación está debidamente fragmentada (`DashboardProvider` no interactúa con `CartProvider`).

---

## 13. Posibles mejoras futuras

1. **Multilenguaje y Localización (i18n):** Actualmente el sistema carga variables estáticas en strings españolas. Utilizando bibliotecas como `easy_localization` + un generador se pueden extraer todos los literales a archivos `json`, logrando que la app escale internacionalmente.
2. **Push Notifications:** Reemplazar parte del flujo de correo directo manual, en favor del aprovisionamiento en Firebase Cloud Messaging o integrándolo al *Supabase Realtime* en el Device. Resultaría en mayor tasa asertiva para carritos abandonados.
3. **Escalabilidad del panel Administrador:** Dado el inmenso volumen visual de la sección administrativa, una bifurcación a Flutter Web (App paralela exclusiva para Admins) permitirá mayores controles visuales orientados al Data Logging, aligerando la carga compilatoria y nativa de la app B2C al usuario común.

---

## 14. Conclusión

**Fashion Store** no es simplemente un prototipo E-commerce, representa un núcleo de arquitectura mantenible y probada. Mediante el uso de herramientas modernas, escalables (como Freezed o GoRouter) y de paradigmas de protección backend en Supabase y Stripe, la plataforma cuenta tanto con garantías de experiencia de usuario responsivas de primer nivel, como con las robustas capacidades para gerenciar dinámicas empresariales complejas (facturación, marketing y devoluciones) todas integradas sinérgicamente.
