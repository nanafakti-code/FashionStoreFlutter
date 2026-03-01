import 'package:freezed_annotation/freezed_annotation.dart';

part 'carrito_model.freezed.dart';

@Freezed(toJson: false, fromJson: false)
class CartItemModel with _$CartItemModel {
  const CartItemModel._();

  const factory CartItemModel({
    required String id,
    required String productId,
    required String productName,
    required int quantity,
    required int precioUnitario, // Centavos
    String? productImage,
    String? talla,
    String? color,
    String? capacidad,
    String? variantId,
    required int maxStock,
    DateTime? expireAt,
  }) = _CartItemModel;

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        id: json['id'] ?? '',
        productId: json['product_id'] ?? '',
        productName: json['product_name'] ?? 'Producto',
        quantity: json['quantity'] ?? 1,
        precioUnitario: json['precio_unitario'] ?? 0,
        productImage: json['product_image'] as String?,
        talla: json['talla'] as String?,
        color: json['color'] as String?,
        capacidad: json['capacidad'] as String?,
        variantId: json['variant_id'] as String?,
        maxStock: json['max_stock'] ?? 100,
        expireAt: json['expire_at'] != null
            ? DateTime.tryParse(json['expire_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'precio_unitario': precioUnitario,
        'product_image': productImage,
        'talla': talla,
        'color': color,
        'capacidad': capacidad,
        'variant_id': variantId,
        'max_stock': maxStock,
        'expire_at': expireAt?.toIso8601String(),
      };

  double get precioTotalEuros => (precioUnitario * quantity) / 100;
}
