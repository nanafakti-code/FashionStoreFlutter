import 'package:freezed_annotation/freezed_annotation.dart';

part 'pedido_model.freezed.dart';

// ─── ItemOrdenModel ───────────────────────────────────────────────────────────

@Freezed(toJson: false, fromJson: false)
class ItemOrdenModel with _$ItemOrdenModel {
  const ItemOrdenModel._();

  const factory ItemOrdenModel({
    required String id,
    required String ordenId,
    required String productoId,
    String? variantId,
    String? nombreProducto,
    required int cantidad,
    required int precioUnitario,
    required int subtotal,
    String? talla,
    String? color,
    String? imagenUrl,
  }) = _ItemOrdenModel;

  factory ItemOrdenModel.fromJson(Map<String, dynamic> json) => ItemOrdenModel(
        id: json['id'] ?? '',
        ordenId: json['orden_id'] ?? json['pedido_id'] ?? '',
        productoId: json['producto_id'] ?? '',
        variantId: json['variant_id'] as String?,
        nombreProducto: json['producto_nombre'] ??
            json['nombre_producto'] ??
            json['producto']?['nombre'] as String?,
        cantidad: json['cantidad'] ?? 1,
        precioUnitario: json['precio_unitario'] ?? 0,
        subtotal: json['subtotal'] ?? 0,
        talla: json['talla'] as String?,
        color: json['color'] as String?,
        imagenUrl: (json['producto_imagen'] ?? json['imagen_url']) as String?,
      );

  double get precioUnitarioEnEuros => precioUnitario / 100;
  double get subtotalEnEuros => subtotal / 100;
}

// ─── PedidoModel ─────────────────────────────────────────────────────────────

@Freezed(toJson: false, fromJson: false)
class PedidoModel with _$PedidoModel {
  const PedidoModel._();

  const factory PedidoModel({
    required String id,
    required String numeroOrden,
    String? usuarioId,
    @Default('Pendiente') String estado,
    @Default(0) int subtotal,
    @Default(0) int impuestos,
    @Default(0) int descuento,
    @Default(0) int costeEnvio,
    required int total,
    String? cuponId,
    String? stripeSessionId,
    String? stripePaymentIntent,
    String? emailCliente,
    String? nombreCliente,
    String? telefonoCliente,
    Map<String, dynamic>? direccionEnvio,
    String? notas,
    DateTime? fechaCreacion,
    DateTime? fechaPago,
    DateTime? fechaEnvio,
    DateTime? fechaEntrega,
    @Default([]) List<ItemOrdenModel> items,
  }) = _PedidoModel;

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    List<ItemOrdenModel> items = [];
    if (json['items_orden'] != null && json['items_orden'] is List) {
      items = (json['items_orden'] as List)
          .map((i) => ItemOrdenModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return PedidoModel(
      id: json['id'] ?? '',
      numeroOrden: json['numero_orden'] ?? '',
      usuarioId: json['usuario_id'] as String?,
      estado: json['estado'] ?? 'Pendiente',
      subtotal: json['subtotal'] ?? 0,
      impuestos: json['impuestos'] ?? 0,
      descuento: json['descuento'] ?? 0,
      costeEnvio: json['coste_envio'] ?? 0,
      total: json['total'] ?? 0,
      cuponId: json['cupon_id'] != null ? json['cupon_id'].toString() : null,
      stripeSessionId: json['stripe_session_id'] as String?,
      stripePaymentIntent: json['stripe_payment_intent'] as String?,
      emailCliente: json['email_cliente'] as String?,
      nombreCliente: json['nombre_cliente'] as String?,
      telefonoCliente: json['telefono_cliente'] as String?,
      direccionEnvio: json['direccion_envio'] is Map
          ? json['direccion_envio'] as Map<String, dynamic>
          : null,
      notas: json['notas'] as String?,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'] as String)
          : null,
      fechaPago: json['fecha_pago'] != null
          ? DateTime.tryParse(json['fecha_pago'] as String)
          : null,
      fechaEnvio: json['fecha_envio'] != null
          ? DateTime.tryParse(json['fecha_envio'] as String)
          : null,
      fechaEntrega: json['fecha_entrega'] != null
          ? DateTime.tryParse(json['fecha_entrega'] as String)
          : null,
      items: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'numero_orden': numeroOrden,
        'usuario_id': usuarioId,
        'estado': estado,
        'subtotal': subtotal,
        'impuestos': impuestos,
        'descuento': descuento,
        'coste_envio': costeEnvio,
        'total': total,
        'cupon_id': cuponId,
        'email_cliente': emailCliente,
        'nombre_cliente': nombreCliente,
        'telefono_cliente': telefonoCliente,
        'direccion_envio': direccionEnvio,
        'notas': notas,
      };

  double get totalEnEuros => total / 100;
  double get subtotalEnEuros => subtotal / 100;
  double get descuentoEnEuros => descuento / 100;
  double get envioEnEuros => costeEnvio / 100;
  bool get isPagado =>
      estado == 'Pagado' || estado == 'Enviado' || estado == 'Entregado';
  bool get isCancelable => estado == 'Pendiente' || estado == 'Pendiente_Pago';
}
