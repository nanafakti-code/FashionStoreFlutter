import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon_model.freezed.dart';

@Freezed(toJson: false, fromJson: false)
class CouponModel with _$CouponModel {
  const CouponModel._();

  const factory CouponModel({
    required int id,
    required String code,
    String? description,
    required String discountType, // 'PERCENTAGE' or 'FIXED'
    required double value,
    double? minOrderValue,
    int? maxUsesGlobal,
    @Default(1) int maxUsesPerUser,
    required DateTime expirationDate,
    @Default(true) bool isActive,
    String? assignedUserId,
    required DateTime createdAt,
  }) = _CouponModel;

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id'].toString()) ?? 0,
        code: json['code'] ?? '',
        description: json['description'] as String?,
        discountType: json['discount_type'] ?? 'PERCENTAGE',
        value: (json['value'] is num) ? (json['value'] as num).toDouble() : 0.0,
        minOrderValue: (json['min_order_value'] is num)
            ? (json['min_order_value'] as num).toDouble()
            : null,
        maxUsesGlobal: json['max_uses_global'] as int?,
        maxUsesPerUser: json['max_uses_per_user'] ?? 1,
        expirationDate: DateTime.parse(json['expiration_date'] as String),
        isActive: json['is_active'] ?? true,
        assignedUserId: json['assigned_user_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'discount_type': discountType,
        'value': value,
        'min_order_value': minOrderValue,
        'max_uses_global': maxUsesGlobal,
        'max_uses_per_user': maxUsesPerUser,
        'expiration_date': expirationDate.toIso8601String(),
        'is_active': isActive,
        'assigned_user_id': assignedUserId,
      };

  double calculateDiscount(double orderTotal) {
    if (discountType == 'PERCENTAGE') {
      return orderTotal * (value / 100);
    } else {
      return value > orderTotal ? orderTotal : value;
    }
  }
}
