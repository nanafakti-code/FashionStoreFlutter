/// Modelo de Cupón de Descuento
class Cupon {
  final String id;
  final String codigo;
  final String? descripcion;
  final String tipo; // 'Porcentaje' o 'Cantidad Fija'
  final double valor;
  final int minimoCompra;
  final int? maximoUsos;
  final int usosActuales;
  final String? categoriaId;
  final bool activo;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final DateTime? creadoEn;

  Cupon({
    required this.id,
    required this.codigo,
    this.descripcion,
    required this.tipo,
    required this.valor,
    this.minimoCompra = 0,
    this.maximoUsos,
    this.usosActuales = 0,
    this.categoriaId,
    this.activo = true,
    this.fechaInicio,
    this.fechaFin,
    this.creadoEn,
  });

  /// Es de tipo porcentaje
  bool get esPorcentaje => tipo == 'Porcentaje';

  /// Está vigente (dentro de fechas y con usos disponibles)
  bool get estaVigente {
    if (!activo) return false;

    final ahora = DateTime.now();
    if (fechaInicio != null && ahora.isBefore(fechaInicio!)) return false;
    if (fechaFin != null && ahora.isAfter(fechaFin!)) return false;
    if (maximoUsos != null && usosActuales >= maximoUsos!) return false;

    return true;
  }

  /// Calcular descuento para un subtotal
  int calcularDescuento(int subtotal) {
    if (!estaVigente) return 0;
    if (subtotal < minimoCompra) return 0;

    if (esPorcentaje) {
      return (subtotal * valor / 100).round();
    } else {
      // Cantidad fija (valor está en euros, convertir a céntimos)
      return (valor * 100).round();
    }
  }

  factory Cupon.fromJson(Map<String, dynamic> json) {
    return Cupon(
      id: json['id'] as String,
      codigo: json['codigo'] as String,
      descripcion: json['descripcion'] as String?,
      tipo: json['tipo'] as String,
      valor: (json['valor'] as num).toDouble(),
      minimoCompra: json['minimo_compra'] as int? ?? 0,
      maximoUsos: json['maximo_uses'] as int?,
      usosActuales: json['usos_actuales'] as int? ?? 0,
      categoriaId: json['categoria_id'] as String?,
      activo: json['activo'] as bool? ?? true,
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'] as String)
          : null,
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'] as String)
          : null,
      creadoEn: json['creado_en'] != null
          ? DateTime.parse(json['creado_en'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'descripcion': descripcion,
      'tipo': tipo,
      'valor': valor,
      'minimo_compra': minimoCompra,
      'maximo_uses': maximoUsos,
      'usos_actuales': usosActuales,
      'categoria_id': categoriaId,
      'activo': activo,
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
    };
  }
}

/// Modelo de Reseña
class Resena {
  final String id;
  final String productoId;
  final String usuarioId;
  final int calificacion;
  final String? titulo;
  final String? comentario;
  final bool verificadaCompra;
  final int util;
  final int noUtil;
  final String estado;
  final DateTime? creadaEn;
  final String? usuarioNombre;

  Resena({
    required this.id,
    required this.productoId,
    required this.usuarioId,
    required this.calificacion,
    this.titulo,
    this.comentario,
    this.verificadaCompra = false,
    this.util = 0,
    this.noUtil = 0,
    this.estado = 'Pendiente',
    this.creadaEn,
    this.usuarioNombre,
  });

  factory Resena.fromJson(Map<String, dynamic> json) {
    return Resena(
      id: json['id'] as String,
      productoId: json['producto_id'] as String,
      usuarioId: json['usuario_id'] as String,
      calificacion: json['calificacion'] as int,
      titulo: json['titulo'] as String?,
      comentario: json['comentario'] as String?,
      verificadaCompra: json['verificada_compra'] as bool? ?? false,
      util: json['util'] as int? ?? 0,
      noUtil: json['no_util'] as int? ?? 0,
      estado: json['estado'] as String? ?? 'Pendiente',
      creadaEn: json['creada_en'] != null
          ? DateTime.parse(json['creada_en'] as String)
          : null,
      usuarioNombre: json['usuarios']?['nombre'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'usuario_id': usuarioId,
      'calificacion': calificacion,
      'titulo': titulo,
      'comentario': comentario,
      'estado': 'Pendiente',
    };
  }
}

/// Modelo de Lista de Deseos
class ListaDeseos {
  final String id;
  final String usuarioId;
  final String productoId;
  final DateTime? anadidaEn;

  ListaDeseos({
    required this.id,
    required this.usuarioId,
    required this.productoId,
    this.anadidaEn,
  });

  factory ListaDeseos.fromJson(Map<String, dynamic> json) {
    return ListaDeseos(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      productoId: json['producto_id'] as String,
      anadidaEn: json['anadida_en'] != null
          ? DateTime.parse(json['anadida_en'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'producto_id': productoId,
    };
  }
}
