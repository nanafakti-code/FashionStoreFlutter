import 'package:freezed_annotation/freezed_annotation.dart';
import 'pedido_model.dart';

part 'devolucion_model.freezed.dart';

@Freezed(toJson: false, fromJson: false)
class DevolucionModel with _$DevolucionModel {
  const DevolucionModel._();

  const factory DevolucionModel({
    required String id,
    required String ordenId,
    required String numeroDevolucion,
    required String motivo,
    @Default('Pendiente') String estado,
    String? notasAdmin,
    DateTime? fechaSolicitud,
    DateTime? fechaAprobacion,
    DateTime? fechaRecepcion,
    DateTime? fechaReembolso,
    int? importeReembolso,
    String? metodoReembolso,
    PedidoModel? pedido,
  }) = _DevolucionModel;

  factory DevolucionModel.fromJson(Map<String, dynamic> json) =>
      DevolucionModel(
        id: json['id'] ?? '',
        ordenId: json['orden_id'] ?? '',
        numeroDevolucion: json['numero_devolucion'] ?? '',
        motivo: json['motivo'] ?? '',
        estado: json['estado'] ?? 'Pendiente',
        notasAdmin: json['notas_admin'] as String?,
        fechaSolicitud: json['fecha_solicitud'] != null
            ? DateTime.tryParse(json['fecha_solicitud'] as String)
            : null,
        fechaAprobacion: json['fecha_aprobacion'] != null
            ? DateTime.tryParse(json['fecha_aprobacion'] as String)
            : null,
        fechaRecepcion: json['fecha_recepcion'] != null
            ? DateTime.tryParse(json['fecha_recepcion'] as String)
            : null,
        fechaReembolso: json['fecha_reembolso'] != null
            ? DateTime.tryParse(json['fecha_reembolso'] as String)
            : null,
        importeReembolso: json['importe_reembolso'] as int?,
        metodoReembolso: json['metodo_reembolso'] as String?,
        pedido: json['ordenes'] != null
            ? PedidoModel.fromJson(json['ordenes'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'orden_id': ordenId,
        'numero_devolucion': numeroDevolucion,
        'motivo': motivo,
        'estado': estado,
        if (notasAdmin != null) 'notas_admin': notasAdmin,
        if (importeReembolso != null) 'importe_reembolso': importeReembolso,
        if (metodoReembolso != null) 'metodo_reembolso': metodoReembolso,
      };

  double? get importeReembolsoEnEuros =>
      importeReembolso != null ? importeReembolso! / 100 : null;
}
