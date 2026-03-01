// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carrito_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CartItemModel {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  int get precioUnitario => throw _privateConstructorUsedError; // Centavos
  String? get productImage => throw _privateConstructorUsedError;
  String? get talla => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String? get capacidad => throw _privateConstructorUsedError;
  String? get variantId => throw _privateConstructorUsedError;
  int get maxStock => throw _privateConstructorUsedError;
  DateTime? get expireAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CartItemModelCopyWith<CartItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemModelCopyWith<$Res> {
  factory $CartItemModelCopyWith(
          CartItemModel value, $Res Function(CartItemModel) then) =
      _$CartItemModelCopyWithImpl<$Res, CartItemModel>;
  @useResult
  $Res call(
      {String id,
      String productId,
      String productName,
      int quantity,
      int precioUnitario,
      String? productImage,
      String? talla,
      String? color,
      String? capacidad,
      String? variantId,
      int maxStock,
      DateTime? expireAt});
}

/// @nodoc
class _$CartItemModelCopyWithImpl<$Res, $Val extends CartItemModel>
    implements $CartItemModelCopyWith<$Res> {
  _$CartItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? precioUnitario = null,
    Object? productImage = freezed,
    Object? talla = freezed,
    Object? color = freezed,
    Object? capacidad = freezed,
    Object? variantId = freezed,
    Object? maxStock = null,
    Object? expireAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      precioUnitario: null == precioUnitario
          ? _value.precioUnitario
          : precioUnitario // ignore: cast_nullable_to_non_nullable
              as int,
      productImage: freezed == productImage
          ? _value.productImage
          : productImage // ignore: cast_nullable_to_non_nullable
              as String?,
      talla: freezed == talla
          ? _value.talla
          : talla // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      capacidad: freezed == capacidad
          ? _value.capacidad
          : capacidad // ignore: cast_nullable_to_non_nullable
              as String?,
      variantId: freezed == variantId
          ? _value.variantId
          : variantId // ignore: cast_nullable_to_non_nullable
              as String?,
      maxStock: null == maxStock
          ? _value.maxStock
          : maxStock // ignore: cast_nullable_to_non_nullable
              as int,
      expireAt: freezed == expireAt
          ? _value.expireAt
          : expireAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CartItemModelImplCopyWith<$Res>
    implements $CartItemModelCopyWith<$Res> {
  factory _$$CartItemModelImplCopyWith(
          _$CartItemModelImpl value, $Res Function(_$CartItemModelImpl) then) =
      __$$CartItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String productId,
      String productName,
      int quantity,
      int precioUnitario,
      String? productImage,
      String? talla,
      String? color,
      String? capacidad,
      String? variantId,
      int maxStock,
      DateTime? expireAt});
}

/// @nodoc
class __$$CartItemModelImplCopyWithImpl<$Res>
    extends _$CartItemModelCopyWithImpl<$Res, _$CartItemModelImpl>
    implements _$$CartItemModelImplCopyWith<$Res> {
  __$$CartItemModelImplCopyWithImpl(
      _$CartItemModelImpl _value, $Res Function(_$CartItemModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? precioUnitario = null,
    Object? productImage = freezed,
    Object? talla = freezed,
    Object? color = freezed,
    Object? capacidad = freezed,
    Object? variantId = freezed,
    Object? maxStock = null,
    Object? expireAt = freezed,
  }) {
    return _then(_$CartItemModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      precioUnitario: null == precioUnitario
          ? _value.precioUnitario
          : precioUnitario // ignore: cast_nullable_to_non_nullable
              as int,
      productImage: freezed == productImage
          ? _value.productImage
          : productImage // ignore: cast_nullable_to_non_nullable
              as String?,
      talla: freezed == talla
          ? _value.talla
          : talla // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      capacidad: freezed == capacidad
          ? _value.capacidad
          : capacidad // ignore: cast_nullable_to_non_nullable
              as String?,
      variantId: freezed == variantId
          ? _value.variantId
          : variantId // ignore: cast_nullable_to_non_nullable
              as String?,
      maxStock: null == maxStock
          ? _value.maxStock
          : maxStock // ignore: cast_nullable_to_non_nullable
              as int,
      expireAt: freezed == expireAt
          ? _value.expireAt
          : expireAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$CartItemModelImpl extends _CartItemModel {
  const _$CartItemModelImpl(
      {required this.id,
      required this.productId,
      required this.productName,
      required this.quantity,
      required this.precioUnitario,
      this.productImage,
      this.talla,
      this.color,
      this.capacidad,
      this.variantId,
      required this.maxStock,
      this.expireAt})
      : super._();

  @override
  final String id;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final int quantity;
  @override
  final int precioUnitario;
// Centavos
  @override
  final String? productImage;
  @override
  final String? talla;
  @override
  final String? color;
  @override
  final String? capacidad;
  @override
  final String? variantId;
  @override
  final int maxStock;
  @override
  final DateTime? expireAt;

  @override
  String toString() {
    return 'CartItemModel(id: $id, productId: $productId, productName: $productName, quantity: $quantity, precioUnitario: $precioUnitario, productImage: $productImage, talla: $talla, color: $color, capacidad: $capacidad, variantId: $variantId, maxStock: $maxStock, expireAt: $expireAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.precioUnitario, precioUnitario) ||
                other.precioUnitario == precioUnitario) &&
            (identical(other.productImage, productImage) ||
                other.productImage == productImage) &&
            (identical(other.talla, talla) || other.talla == talla) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.capacidad, capacidad) ||
                other.capacidad == capacidad) &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.maxStock, maxStock) ||
                other.maxStock == maxStock) &&
            (identical(other.expireAt, expireAt) ||
                other.expireAt == expireAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      productId,
      productName,
      quantity,
      precioUnitario,
      productImage,
      talla,
      color,
      capacidad,
      variantId,
      maxStock,
      expireAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemModelImplCopyWith<_$CartItemModelImpl> get copyWith =>
      __$$CartItemModelImplCopyWithImpl<_$CartItemModelImpl>(this, _$identity);
}

abstract class _CartItemModel extends CartItemModel {
  const factory _CartItemModel(
      {required final String id,
      required final String productId,
      required final String productName,
      required final int quantity,
      required final int precioUnitario,
      final String? productImage,
      final String? talla,
      final String? color,
      final String? capacidad,
      final String? variantId,
      required final int maxStock,
      final DateTime? expireAt}) = _$CartItemModelImpl;
  const _CartItemModel._() : super._();

  @override
  String get id;
  @override
  String get productId;
  @override
  String get productName;
  @override
  int get quantity;
  @override
  int get precioUnitario;
  @override // Centavos
  String? get productImage;
  @override
  String? get talla;
  @override
  String? get color;
  @override
  String? get capacidad;
  @override
  String? get variantId;
  @override
  int get maxStock;
  @override
  DateTime? get expireAt;
  @override
  @JsonKey(ignore: true)
  _$$CartItemModelImplCopyWith<_$CartItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
