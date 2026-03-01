// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coupon_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CouponModel {
  int get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get discountType =>
      throw _privateConstructorUsedError; // 'PERCENTAGE' or 'FIXED'
  double get value => throw _privateConstructorUsedError;
  double? get minOrderValue => throw _privateConstructorUsedError;
  int? get maxUsesGlobal => throw _privateConstructorUsedError;
  int get maxUsesPerUser => throw _privateConstructorUsedError;
  DateTime get expirationDate => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get assignedUserId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CouponModelCopyWith<CouponModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CouponModelCopyWith<$Res> {
  factory $CouponModelCopyWith(
          CouponModel value, $Res Function(CouponModel) then) =
      _$CouponModelCopyWithImpl<$Res, CouponModel>;
  @useResult
  $Res call(
      {int id,
      String code,
      String? description,
      String discountType,
      double value,
      double? minOrderValue,
      int? maxUsesGlobal,
      int maxUsesPerUser,
      DateTime expirationDate,
      bool isActive,
      String? assignedUserId,
      DateTime createdAt});
}

/// @nodoc
class _$CouponModelCopyWithImpl<$Res, $Val extends CouponModel>
    implements $CouponModelCopyWith<$Res> {
  _$CouponModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? description = freezed,
    Object? discountType = null,
    Object? value = null,
    Object? minOrderValue = freezed,
    Object? maxUsesGlobal = freezed,
    Object? maxUsesPerUser = null,
    Object? expirationDate = null,
    Object? isActive = null,
    Object? assignedUserId = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      discountType: null == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      minOrderValue: freezed == minOrderValue
          ? _value.minOrderValue
          : minOrderValue // ignore: cast_nullable_to_non_nullable
              as double?,
      maxUsesGlobal: freezed == maxUsesGlobal
          ? _value.maxUsesGlobal
          : maxUsesGlobal // ignore: cast_nullable_to_non_nullable
              as int?,
      maxUsesPerUser: null == maxUsesPerUser
          ? _value.maxUsesPerUser
          : maxUsesPerUser // ignore: cast_nullable_to_non_nullable
              as int,
      expirationDate: null == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      assignedUserId: freezed == assignedUserId
          ? _value.assignedUserId
          : assignedUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CouponModelImplCopyWith<$Res>
    implements $CouponModelCopyWith<$Res> {
  factory _$$CouponModelImplCopyWith(
          _$CouponModelImpl value, $Res Function(_$CouponModelImpl) then) =
      __$$CouponModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String code,
      String? description,
      String discountType,
      double value,
      double? minOrderValue,
      int? maxUsesGlobal,
      int maxUsesPerUser,
      DateTime expirationDate,
      bool isActive,
      String? assignedUserId,
      DateTime createdAt});
}

/// @nodoc
class __$$CouponModelImplCopyWithImpl<$Res>
    extends _$CouponModelCopyWithImpl<$Res, _$CouponModelImpl>
    implements _$$CouponModelImplCopyWith<$Res> {
  __$$CouponModelImplCopyWithImpl(
      _$CouponModelImpl _value, $Res Function(_$CouponModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? description = freezed,
    Object? discountType = null,
    Object? value = null,
    Object? minOrderValue = freezed,
    Object? maxUsesGlobal = freezed,
    Object? maxUsesPerUser = null,
    Object? expirationDate = null,
    Object? isActive = null,
    Object? assignedUserId = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$CouponModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      discountType: null == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      minOrderValue: freezed == minOrderValue
          ? _value.minOrderValue
          : minOrderValue // ignore: cast_nullable_to_non_nullable
              as double?,
      maxUsesGlobal: freezed == maxUsesGlobal
          ? _value.maxUsesGlobal
          : maxUsesGlobal // ignore: cast_nullable_to_non_nullable
              as int?,
      maxUsesPerUser: null == maxUsesPerUser
          ? _value.maxUsesPerUser
          : maxUsesPerUser // ignore: cast_nullable_to_non_nullable
              as int,
      expirationDate: null == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      assignedUserId: freezed == assignedUserId
          ? _value.assignedUserId
          : assignedUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$CouponModelImpl extends _CouponModel {
  const _$CouponModelImpl(
      {required this.id,
      required this.code,
      this.description,
      required this.discountType,
      required this.value,
      this.minOrderValue,
      this.maxUsesGlobal,
      this.maxUsesPerUser = 1,
      required this.expirationDate,
      this.isActive = true,
      this.assignedUserId,
      required this.createdAt})
      : super._();

  @override
  final int id;
  @override
  final String code;
  @override
  final String? description;
  @override
  final String discountType;
// 'PERCENTAGE' or 'FIXED'
  @override
  final double value;
  @override
  final double? minOrderValue;
  @override
  final int? maxUsesGlobal;
  @override
  @JsonKey()
  final int maxUsesPerUser;
  @override
  final DateTime expirationDate;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String? assignedUserId;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CouponModel(id: $id, code: $code, description: $description, discountType: $discountType, value: $value, minOrderValue: $minOrderValue, maxUsesGlobal: $maxUsesGlobal, maxUsesPerUser: $maxUsesPerUser, expirationDate: $expirationDate, isActive: $isActive, assignedUserId: $assignedUserId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CouponModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.minOrderValue, minOrderValue) ||
                other.minOrderValue == minOrderValue) &&
            (identical(other.maxUsesGlobal, maxUsesGlobal) ||
                other.maxUsesGlobal == maxUsesGlobal) &&
            (identical(other.maxUsesPerUser, maxUsesPerUser) ||
                other.maxUsesPerUser == maxUsesPerUser) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.assignedUserId, assignedUserId) ||
                other.assignedUserId == assignedUserId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      code,
      description,
      discountType,
      value,
      minOrderValue,
      maxUsesGlobal,
      maxUsesPerUser,
      expirationDate,
      isActive,
      assignedUserId,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CouponModelImplCopyWith<_$CouponModelImpl> get copyWith =>
      __$$CouponModelImplCopyWithImpl<_$CouponModelImpl>(this, _$identity);
}

abstract class _CouponModel extends CouponModel {
  const factory _CouponModel(
      {required final int id,
      required final String code,
      final String? description,
      required final String discountType,
      required final double value,
      final double? minOrderValue,
      final int? maxUsesGlobal,
      final int maxUsesPerUser,
      required final DateTime expirationDate,
      final bool isActive,
      final String? assignedUserId,
      required final DateTime createdAt}) = _$CouponModelImpl;
  const _CouponModel._() : super._();

  @override
  int get id;
  @override
  String get code;
  @override
  String? get description;
  @override
  String get discountType;
  @override // 'PERCENTAGE' or 'FIXED'
  double get value;
  @override
  double? get minOrderValue;
  @override
  int? get maxUsesGlobal;
  @override
  int get maxUsesPerUser;
  @override
  DateTime get expirationDate;
  @override
  bool get isActive;
  @override
  String? get assignedUserId;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$CouponModelImplCopyWith<_$CouponModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
