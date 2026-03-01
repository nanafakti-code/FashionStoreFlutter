import 'package:freezed_annotation/freezed_annotation.dart';

part 'extra_models.freezed.dart';

// ─── CuponModel ───────────────────────────────────────────────────────────────

@Freezed(toJson: false, fromJson: false)
class CuponModel with _$CuponModel {
  const CuponModel._();

  const factory CuponModel({
    required String id,
    required String codigo,
    String? descripcion,
    required String tipo, // 'Porcentaje' | 'Cantidad Fija'
    required double valor,
    @Default(0) int minimoCompra,
    int? maximoUses,
    @Default(0) int usosActuales,
    String? categoriaId,
    @Default(true) bool activo,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    DateTime? creadoEn,
  }) = _CuponModel;

  factory CuponModel.fromJson(Map<String, dynamic> json) => CuponModel(
        id: json['id'] ?? '',
        codigo: json['code'] ?? json['codigo'] ?? '',
        descripcion: (json['description'] ?? json['descripcion']) as String?,
        tipo: json['discount_type'] ?? json['tipo'] ?? 'PERCENTAGE',
        valor: (json['value'] ?? json['valor'] as num?)?.toDouble() ?? 0,
        minimoCompra: json['min_order_value'] ?? json['minimo_compra'] ?? 0,
        maximoUses: (json['max_uses_global'] ?? json['maximo_uses']) as int?,
        usosActuales: json['times_used'] ?? json['usos_actuales'] ?? 0,
        categoriaId: json['categoria_id'] as String?,
        activo: json['is_active'] ?? json['activo'] ?? true,
        fechaInicio: json['start_date'] != null
            ? DateTime.tryParse(json['start_date'] as String)
            : (json['fecha_inicio'] != null
                ? DateTime.tryParse(json['fecha_inicio'] as String)
                : null),
        fechaFin: json['expiration_date'] != null
            ? DateTime.tryParse(json['expiration_date'] as String)
            : (json['fecha_fin'] != null
                ? DateTime.tryParse(json['fecha_fin'] as String)
                : null),
        creadoEn: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : (json['creado_en'] != null
                ? DateTime.tryParse(json['creado_en'] as String)
                : null),
      );

  Map<String, dynamic> toJson() => {
        'code': codigo,
        'description': descripcion,
        'discount_type': tipo,
        'value': valor,
        'min_order_value': minimoCompra,
        'max_uses_global': maximoUses,
        'categoria_id': categoriaId,
        'is_active': activo,
        'start_date': fechaInicio?.toIso8601String(),
        'expiration_date': fechaFin?.toIso8601String(),
      };

  bool get isVigente {
    final now = DateTime.now();
    if (fechaInicio != null && now.isBefore(fechaInicio!)) return false;
    if (fechaFin != null && now.isAfter(fechaFin!)) return false;
    if (maximoUses != null && usosActuales >= maximoUses!) return false;
    return activo;
  }

  double calcularDescuento(double subtotal) {
    if (tipo == 'PERCENTAGE' || tipo == 'Porcentaje') {
      return subtotal * (valor / 100);
    }
    return valor * 100;
  }
}

// ─── DireccionModel ───────────────────────────────────────────────────────────

@Freezed(toJson: false, fromJson: false)
class DireccionModel with _$DireccionModel {
  const DireccionModel._();

  const factory DireccionModel({
    required String id,
    required String usuarioId,
    String? tipo,
    required String nombreDestinatario,
    required String calle,
    required String numero,
    String? piso,
    required String codigoPostal,
    required String ciudad,
    required String provincia,
    @Default('España') String pais,
    @Default(false) bool esPredeterminada,
  }) = _DireccionModel;

  factory DireccionModel.fromJson(Map<String, dynamic> json) => DireccionModel(
        id: json['id'] ?? '',
        usuarioId: json['usuario_id'] ?? '',
        tipo: json['tipo'] as String?,
        nombreDestinatario: json['nombre_destinatario'] ?? '',
        calle: json['calle'] ?? '',
        numero: json['numero'] ?? '',
        piso: json['piso'] as String?,
        codigoPostal: json['codigo_postal'] ?? '',
        ciudad: json['ciudad'] ?? '',
        provincia: json['provincia'] ?? '',
        pais: json['pais'] ?? 'España',
        esPredeterminada: json['es_predeterminada'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'usuario_id': usuarioId,
        'tipo': tipo,
        'nombre_destinatario': nombreDestinatario,
        'calle': calle,
        'numero': numero,
        'piso': piso,
        'codigo_postal': codigoPostal,
        'ciudad': ciudad,
        'provincia': provincia,
        'pais': pais,
        'es_predeterminada': esPredeterminada,
      };

  String get direccionCompleta =>
      '$calle $numero${piso != null ? ', $piso' : ''}, $codigoPostal $ciudad, $provincia';
}
// ─── NewsletterModel ──────────────────────────────────────────────────────────

@Freezed(toJson: false, fromJson: false)
class NewsletterModel with _$NewsletterModel {
  const NewsletterModel._();

  const factory NewsletterModel({
    required String id,
    required String email,
    String? nombre,
    String? codigoDescuento,
    @Default(false) bool usado,
    @Default(true) bool activo,
    DateTime? createdAt,
  }) = _NewsletterModel;

  factory NewsletterModel.fromJson(Map<String, dynamic> json) =>
      NewsletterModel(
        id: json['id'] ?? '',
        email: json['email'] ?? '',
        nombre: json['nombre'] as String?,
        codigoDescuento: json['codigo_descuento'] as String?,
        usado: json['usado'] ?? false,
        activo: json['activo'] ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );
}

// ─── CampanaModel ─────────────────────────────────────────────────────────────

@Freezed(toJson: false, fromJson: false)
class CampanaModel with _$CampanaModel {
  const CampanaModel._();

  const factory CampanaModel({
    required String id,
    required String nombre,
    String? descripcion,
    required String asunto,
    required String contenidoHtml,
    @Default('Borrador') String estado,
    String? tipoSegmento,
    DateTime? fechaProgramada,
    DateTime? fechaEnvio,
    @Default(0) int totalDestinatarios,
    @Default(0) int totalEnviados,
    @Default(0) int totalAbiertos,
    @Default(0) int totalClicks,
    DateTime? creadaEn,
  }) = _CampanaModel;

  factory CampanaModel.fromJson(Map<String, dynamic> json) => CampanaModel(
        id: json['id'] ?? '',
        nombre: json['nombre'] ?? '',
        descripcion: json['descripcion'] as String?,
        asunto: json['asunto'] ?? '',
        contenidoHtml: json['contenido_html'] ?? '',
        estado: json['estado'] ?? 'Borrador',
        tipoSegmento: json['tipo_segmento'] as String?,
        fechaProgramada: json['fecha_programada'] != null
            ? DateTime.tryParse(json['fecha_programada'] as String)
            : null,
        fechaEnvio: json['fecha_envio'] != null
            ? DateTime.tryParse(json['fecha_envio'] as String)
            : null,
        totalDestinatarios: json['total_destinatarios'] ?? 0,
        totalEnviados: json['total_enviados'] ?? 0,
        totalAbiertos: json['total_abiertos'] ?? 0,
        totalClicks: json['total_clicks'] ?? 0,
        creadaEn: json['creada_en'] != null
            ? DateTime.tryParse(json['creada_en'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'asunto': asunto,
        'contenido_html': contenidoHtml,
        'estado': estado,
        'tipo_segmento': tipoSegmento,
        'fecha_programada': fechaProgramada?.toIso8601String(),
      };

  double get tasaApertura =>
      totalEnviados > 0 ? (totalAbiertos / totalEnviados) * 100 : 0;

  bool get enviada => estado == 'Enviada';
}
