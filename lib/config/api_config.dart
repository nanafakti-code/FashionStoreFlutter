class ApiConfig {
  static String get baseUrl {
    // URL DE PRODUCCIÓN (Coolify) con sufijo /api como ha solicitado el backend
    return 'https://fashionstorerbv3.victoriafp.online/api';
  }

  // --- Endpoints Públicos ---

  // Productos
  static String get productos => '$baseUrl/productos';

  // Carrito (Gestión Híbrida)
  static String get cartGet => '$baseUrl/cart/get';
  static String get cartAdd => '$baseUrl/cart/add';
  static String get cartUpdate => '$baseUrl/cart/update';
  static String get cartRemove => '$baseUrl/cart/remove';
  static String get cartClear => '$baseUrl/cart/clear';

  // Checkout & Pagos
  static String get createCheckoutSession => '$baseUrl/stripe/create-session';
  static String get orderByGuest => '$baseUrl/order/by-guest';

  // --- Cupones ---
  static String get validateCoupon => '$baseUrl/coupons/validate';

  // --- Endpoints Admin (Privados) ---
  static String get adminLogin => '$baseUrl/admin/login';
  static String get adminDashboard => '$baseUrl/admin/dashboard';
  static String get adminProductos => '$baseUrl/admin/productos';
  static String get adminCategorias => '$baseUrl/admin/categorias';
  static String get adminUsuarios => '$baseUrl/admin/usuarios';
  static String get adminOrdenes => '$baseUrl/admin/ordenes-api';
  static String get adminResenas => '$baseUrl/admin/resenas';
  static String get adminCupones => '$baseUrl/admin/cupones';
  static String get adminDevoluciones => '$baseUrl/admin/devoluciones';
  static String get adminCampanas => '$baseUrl/admin/campanas';
  static String get adminNewsletter => '$baseUrl/admin/newsletter';
}
