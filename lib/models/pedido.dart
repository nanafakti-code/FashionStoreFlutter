import '../config/constants.dart';

/// Modelo de Pedido (Orden)
class Pedido {
  final String id;
  final String numeroPedido;
  final String? usuarioId;
  final String estado;
  final int subtotal;
  final int impuestos;
  final int costeEnvio;
  final int descuento;
  final int total;
  final String? metodoPago;
  final String? referenciaPago;
  final String? direccionEnvioId;
  final String? direccionFacturacionId;
  final String? notas;
  final String? emailCliente;
  final String? nombreCliente;
  final String? telefonoCliente;
  final Map<String, dynamic>? direccionEnvio;
  final DateTime fechaCreacion;
  final DateTime? fechaConfirmacion;
  final DateTime? fechaPago;
  final DateTime? fechaEnvio;
  final DateTime? fechaEntregaEstimada;
  final List<ItemPedido> items;

  Pedido({
    required this.id,
    required this.numeroPedido,
    this.usuarioId,
    required this.estado,
    required this.subtotal,
    required this.impuestos,
    required this.costeEnvio,
    required this.descuento,
    required this.total,
    this.metodoPago,
    this.referenciaPago,
    this.direccionEnvioId,
    this.direccionFacturacionId,
    this.notas,
    this.emailCliente,
    this.nombreCliente,
    this.telefonoCliente,
    this.direccionEnvio,
    required this.fechaCreacion,
    this.fechaConfirmacion,
    this.fechaPago,
    this.fechaEnvio,
    this.fechaEntregaEstimada,
    this.items = const [],
  });

  /// Total en euros
  double get totalEnEuros => total / 100;

  /// Subtotal en euros
  double get subtotalEnEuros => subtotal / 100;

  /// Impuestos en euros
  double get impuestosEnEuros => impuestos / 100;

  /// Envío en euros
  double get envioEnEuros => costeEnvio / 100;

  /// Descuento en euros
  double get descuentoEnEuros => descuento / 100;

  /// Estado como enum
  EstadoPedido get estadoEnum => EstadoPedido.fromString(estado);

  /// Número total de items
  int get totalItems => items.fold(0, (sum, item) => sum + item.cantidad);

  factory Pedido.fromJson(Map<String, dynamic> json) {
    List<ItemPedido> items = [];
    if (json['detalles_pedido'] != null) {
      items = (json['detalles_pedido'] as List)
          .map((item) => ItemPedido.fromJson(item))
          .toList();
    } else if (json['items_orden'] != null) {
      items = (json['items_orden'] as List)
          .map((item) => ItemPedido.fromOrdenJson(item))
          .toList();
    }

    return Pedido(
      id: json['id'] as String,
      numeroPedido: json['numero_pedido'] ?? json['numero_orden'] ?? '',
      usuarioId: json['usuario_id'] as String?,
      estado: json['estado'] as String,
      subtotal: json['subtotal'] as int? ?? 0,
      impuestos: json['impuestos'] as int? ?? 0,
      costeEnvio: json['coste_envio'] as int? ?? 0,
      descuento: json['descuento'] as int? ?? 0,
      total: json['total'] as int,
      metodoPago: json['metodo_pago'] as String?,
      referenciaPago: json['referencia_pago'] as String?,
      direccionEnvioId: json['direccion_envio_id'] as String?,
      direccionFacturacionId: json['direccion_facturacion_id'] as String?,
      notas: json['notas'] as String?,
      emailCliente: json['email_cliente'] as String?,
      nombreCliente: json['nombre_cliente'] as String?,
      telefonoCliente: json['telefono_cliente'] as String?,
      direccionEnvio: json['direccion_envio'] as Map<String, dynamic>?,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaConfirmacion: json['fecha_confirmacion'] != null
          ? DateTime.parse(json['fecha_confirmacion'] as String)
          : null,
      fechaPago: json['fecha_pago'] != null
          ? DateTime.parse(json['fecha_pago'] as String)
          : null,
      fechaEnvio: json['fecha_envio'] != null
          ? DateTime.parse(json['fecha_envio'] as String)
          : null,
      fechaEntregaEstimada: json['fecha_entrega_estimada'] != null
          ? DateTime.parse(json['fecha_entrega_estimada'] as String)
          : null,
      items: items,
    );
  }
}

/// Modelo de Item de Pedido
class ItemPedido {
  final String id;
  final String pedidoId;
  final String productoId;
  final String? productoNombre;
  final String? productoImagen;
  final int cantidad;
  final String? talla;
  final String? color;
  final int precioUnitario;
  final int subtotal;
  final int descuento;
  final int total;

  ItemPedido({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    this.productoNombre,
    this.productoImagen,
    required this.cantidad,
    this.talla,
    this.color,
    required this.precioUnitario,
    required this.subtotal,
    this.descuento = 0,
    required this.total,
  });

  /// Precio unitario en euros
  double get precioUnitarioEnEuros => precioUnitario / 100;

  /// Subtotal en euros
  double get subtotalEnEuros => subtotal / 100;

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      id: json['id'] as String,
      pedidoId: json['pedido_id'] as String,
      productoId: json['producto_id'] as String,
      productoNombre: json['producto_nombre'] as String?,
      productoImagen: json['producto_imagen'] as String?,
      cantidad: json['cantidad'] as int,
      talla: json['talla'] as String?,
      color: json['color'] as String?,
      precioUnitario: json['precio_unitario'] as int,
      subtotal: json['subtotal'] as int,
      descuento: json['descuento'] as int? ?? 0,
      total: json['total'] as int,
    );
  }

  factory ItemPedido.fromOrdenJson(Map<String, dynamic> json) {
    final precioUnitario = json['precio_unitario'] as int;
    final cantidad = json['cantidad'] as int;
    final subtotal = json['subtotal'] as int? ?? (precioUnitario * cantidad);

    return ItemPedido(
      id: json['id'] as String,
      pedidoId: json['orden_id'] as String,
      productoId: json['producto_id'] as String,
      productoNombre: json['producto_nombre'] as String?,
      productoImagen: json['producto_imagen'] as String?,
      cantidad: cantidad,
      talla: json['talla'] as String?,
      color: json['color'] as String?,
      precioUnitario: precioUnitario,
      subtotal: subtotal,
      descuento: 0,
      total: subtotal,
    );
  }
}
