/// Constantes de la aplicación
class AppConstants {
  // API Base URL (para llamar a los endpoints de Astro)
  static const String apiBaseUrl = 'http://localhost:4321/api';

  // Límites
  static const int maxCartItems = 99;
  static const int productsPerPage = 20;

  // Envío gratis desde (en céntimos)
  static const int freeShippingThreshold = 5000; // 50€

  // Costes de envío (en céntimos)
  static const int standardShippingCost = 499; // 4.99€

  // IVA (España)
  static const double taxRate = 0.21; // 21%

  // Timeouts
  static const int connectionTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000;

  // Nombres de tablas Supabase
  static const String tableUsuarios = 'usuarios';
  static const String tableProductos = 'productos';
  static const String tableCategorias = 'categorias';
  static const String tableMarcas = 'marcas';
  static const String tablePedidos = 'pedidos';
  static const String tableDetallesPedido = 'detalles_pedido';
  static const String tableCarrito = 'carrito';
  static const String tableCarritoItems = 'carrito_items';
  static const String tableDirecciones = 'direcciones';
  static const String tableCupones = 'cupones_descuento';
  static const String tableResenas = 'resenas';
  static const String tableListaDeseos = 'lista_deseos';
  static const String tableOrdenes = 'ordenes';
  static const String tableItemsOrden = 'items_orden';
  static const String tableImagenes = 'imagenes_producto';
  static const String tableVariantes = 'variantes_producto';

  // Claves de almacenamiento local
  static const String guestCartKey = 'fashionstore_guest_cart';
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_complete';
}

/// Estados de pedido
enum EstadoPedido {
  pendiente('Pendiente'),
  confirmado('Confirmado'),
  pagado('Pagado'),
  enviado('Enviado'),
  entregado('Entregado'),
  cancelado('Cancelado'),
  devuelto('Devuelto');

  final String value;
  const EstadoPedido(this.value);

  static EstadoPedido fromString(String value) {
    return EstadoPedido.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => EstadoPedido.pendiente,
    );
  }
}

/// Géneros de producto
enum GeneroProducto {
  masculino('Masculino'),
  femenino('Femenino'),
  unisex('Unisex');

  final String value;
  const GeneroProducto(this.value);

  static GeneroProducto fromString(String value) {
    return GeneroProducto.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => GeneroProducto.unisex,
    );
  }
}
