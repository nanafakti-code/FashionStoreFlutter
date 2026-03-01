import 'package:freezed_annotation/freezed_annotation.dart';

part 'resena_model.freezed.dart';

@Freezed(toJson: false, fromJson: false)
class ResenaModel with _$ResenaModel {
  const ResenaModel._();

  const factory ResenaModel({
    required String id,
    required String productoId,
    required String usuarioId,
    String? ordenId,
    required int calificacion,
    String? titulo,
    String? comentario,
    @Default(false) bool verificadaCompra,
    @Default(0) int util,
    @Default(0) int noUtil,
    @Default('Pendiente') String estado,
    DateTime? creadaEn,
    String? nombreUsuario,
    String? emailUsuario,
    String? nombreProducto,
  }) = _ResenaModel;

  factory ResenaModel.fromJson(Map<String, dynamic> json) => ResenaModel(
        id: json['id'] ?? '',
        productoId: json['producto_id'] ?? '',
        usuarioId: json['usuario_id'] ?? '',
        ordenId: json['orden_id'] as String?,
        calificacion: json['calificacion'] ?? 0,
        titulo: json['titulo'] as String?,
        comentario: json['comentario'] as String?,
        verificadaCompra: json['verificada_compra'] ?? false,
        util: json['util'] ?? 0,
        noUtil: json['no_util'] ?? 0,
        estado: json['estado'] ?? 'Pendiente',
        creadaEn: json['creada_en'] != null
            ? DateTime.tryParse(json['creada_en'] as String)
            : null,
        nombreUsuario: json['usuarios']?['nombre'] as String?,
        emailUsuario: json['usuarios']?['email'] as String?,
        nombreProducto: json['productos']?['nombre'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'producto_id': productoId,
        'usuario_id': usuarioId,
        if (ordenId != null) 'orden_id': ordenId,
        'calificacion': calificacion,
        'titulo': titulo,
        'comentario': comentario,
        'verificada_compra': verificadaCompra,
        'estado': estado,
      };
}
