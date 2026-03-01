class AdminCategory {
  final String id;
  final String nombre;
  final String slug;
  final String? descripcion;
  final String? icono;
  final String? imagenPortada; // For future use
  final String? padreId; // For nested categories
  final int orden;
  final bool active; // 'activa' in DB
  final String creadoEn;

  const AdminCategory({
    required this.id,
    required this.nombre,
    required this.slug,
    this.descripcion,
    this.icono,
    this.imagenPortada,
    this.padreId,
    this.orden = 0,
    required this.active,
    required this.creadoEn,
  });

  factory AdminCategory.fromJson(Map<String, dynamic> json) {
    return AdminCategory(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      slug: json['slug'] ?? '',
      descripcion: json['descripcion'],
      icono: json['icono'],
      imagenPortada: json['imagen_portada'] ??
          json['imagen_url'], // Handle both potentially
      padreId: json['padre_id'],
      orden: json['orden'] ?? 0,
      active: json['activa'] ??
          json['activo'] ??
          true, // Handle potential naming variations
      creadoEn: json['creada_en'] ?? json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'slug': slug,
        'descripcion': descripcion,
        'icono': icono,
        'imagen_portada': imagenPortada,
        'padre_id': padreId,
        'orden': orden,
        'activa': active,
      };
}
