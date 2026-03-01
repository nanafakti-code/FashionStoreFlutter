// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reviewable_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReviewableItemModel {
  ItemOrdenModel get item => throw _privateConstructorUsedError;
  String get ordenId => throw _privateConstructorUsedError;
  DateTime? get fechaCompra => throw _privateConstructorUsedError;
  bool get estaResenado => throw _privateConstructorUsedError;
  ResenaModel? get resenaExistente => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ReviewableItemModelCopyWith<ReviewableItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewableItemModelCopyWith<$Res> {
  factory $ReviewableItemModelCopyWith(
          ReviewableItemModel value, $Res Function(ReviewableItemModel) then) =
      _$ReviewableItemModelCopyWithImpl<$Res, ReviewableItemModel>;
  @useResult
  $Res call(
      {ItemOrdenModel item,
      String ordenId,
      DateTime? fechaCompra,
      bool estaResenado,
      ResenaModel? resenaExistente});

  $ItemOrdenModelCopyWith<$Res> get item;
  $ResenaModelCopyWith<$Res>? get resenaExistente;
}

/// @nodoc
class _$ReviewableItemModelCopyWithImpl<$Res, $Val extends ReviewableItemModel>
    implements $ReviewableItemModelCopyWith<$Res> {
  _$ReviewableItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = null,
    Object? ordenId = null,
    Object? fechaCompra = freezed,
    Object? estaResenado = null,
    Object? resenaExistente = freezed,
  }) {
    return _then(_value.copyWith(
      item: null == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as ItemOrdenModel,
      ordenId: null == ordenId
          ? _value.ordenId
          : ordenId // ignore: cast_nullable_to_non_nullable
              as String,
      fechaCompra: freezed == fechaCompra
          ? _value.fechaCompra
          : fechaCompra // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      estaResenado: null == estaResenado
          ? _value.estaResenado
          : estaResenado // ignore: cast_nullable_to_non_nullable
              as bool,
      resenaExistente: freezed == resenaExistente
          ? _value.resenaExistente
          : resenaExistente // ignore: cast_nullable_to_non_nullable
              as ResenaModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ItemOrdenModelCopyWith<$Res> get item {
    return $ItemOrdenModelCopyWith<$Res>(_value.item, (value) {
      return _then(_value.copyWith(item: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ResenaModelCopyWith<$Res>? get resenaExistente {
    if (_value.resenaExistente == null) {
      return null;
    }

    return $ResenaModelCopyWith<$Res>(_value.resenaExistente!, (value) {
      return _then(_value.copyWith(resenaExistente: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReviewableItemModelImplCopyWith<$Res>
    implements $ReviewableItemModelCopyWith<$Res> {
  factory _$$ReviewableItemModelImplCopyWith(_$ReviewableItemModelImpl value,
          $Res Function(_$ReviewableItemModelImpl) then) =
      __$$ReviewableItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ItemOrdenModel item,
      String ordenId,
      DateTime? fechaCompra,
      bool estaResenado,
      ResenaModel? resenaExistente});

  @override
  $ItemOrdenModelCopyWith<$Res> get item;
  @override
  $ResenaModelCopyWith<$Res>? get resenaExistente;
}

/// @nodoc
class __$$ReviewableItemModelImplCopyWithImpl<$Res>
    extends _$ReviewableItemModelCopyWithImpl<$Res, _$ReviewableItemModelImpl>
    implements _$$ReviewableItemModelImplCopyWith<$Res> {
  __$$ReviewableItemModelImplCopyWithImpl(_$ReviewableItemModelImpl _value,
      $Res Function(_$ReviewableItemModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = null,
    Object? ordenId = null,
    Object? fechaCompra = freezed,
    Object? estaResenado = null,
    Object? resenaExistente = freezed,
  }) {
    return _then(_$ReviewableItemModelImpl(
      item: null == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as ItemOrdenModel,
      ordenId: null == ordenId
          ? _value.ordenId
          : ordenId // ignore: cast_nullable_to_non_nullable
              as String,
      fechaCompra: freezed == fechaCompra
          ? _value.fechaCompra
          : fechaCompra // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      estaResenado: null == estaResenado
          ? _value.estaResenado
          : estaResenado // ignore: cast_nullable_to_non_nullable
              as bool,
      resenaExistente: freezed == resenaExistente
          ? _value.resenaExistente
          : resenaExistente // ignore: cast_nullable_to_non_nullable
              as ResenaModel?,
    ));
  }
}

/// @nodoc

class _$ReviewableItemModelImpl implements _ReviewableItemModel {
  const _$ReviewableItemModelImpl(
      {required this.item,
      required this.ordenId,
      required this.fechaCompra,
      this.estaResenado = false,
      this.resenaExistente});

  @override
  final ItemOrdenModel item;
  @override
  final String ordenId;
  @override
  final DateTime? fechaCompra;
  @override
  @JsonKey()
  final bool estaResenado;
  @override
  final ResenaModel? resenaExistente;

  @override
  String toString() {
    return 'ReviewableItemModel(item: $item, ordenId: $ordenId, fechaCompra: $fechaCompra, estaResenado: $estaResenado, resenaExistente: $resenaExistente)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewableItemModelImpl &&
            (identical(other.item, item) || other.item == item) &&
            (identical(other.ordenId, ordenId) || other.ordenId == ordenId) &&
            (identical(other.fechaCompra, fechaCompra) ||
                other.fechaCompra == fechaCompra) &&
            (identical(other.estaResenado, estaResenado) ||
                other.estaResenado == estaResenado) &&
            (identical(other.resenaExistente, resenaExistente) ||
                other.resenaExistente == resenaExistente));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, item, ordenId, fechaCompra, estaResenado, resenaExistente);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewableItemModelImplCopyWith<_$ReviewableItemModelImpl> get copyWith =>
      __$$ReviewableItemModelImplCopyWithImpl<_$ReviewableItemModelImpl>(
          this, _$identity);
}

abstract class _ReviewableItemModel implements ReviewableItemModel {
  const factory _ReviewableItemModel(
      {required final ItemOrdenModel item,
      required final String ordenId,
      required final DateTime? fechaCompra,
      final bool estaResenado,
      final ResenaModel? resenaExistente}) = _$ReviewableItemModelImpl;

  @override
  ItemOrdenModel get item;
  @override
  String get ordenId;
  @override
  DateTime? get fechaCompra;
  @override
  bool get estaResenado;
  @override
  ResenaModel? get resenaExistente;
  @override
  @JsonKey(ignore: true)
  _$$ReviewableItemModelImplCopyWith<_$ReviewableItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
