// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'devolucion_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DevolucionModel {
  String get id => throw _privateConstructorUsedError;
  String get ordenId => throw _privateConstructorUsedError;
  String get numeroDevolucion => throw _privateConstructorUsedError;
  String get motivo => throw _privateConstructorUsedError;
  String get estado => throw _privateConstructorUsedError;
  String? get notasAdmin => throw _privateConstructorUsedError;
  DateTime? get fechaSolicitud => throw _privateConstructorUsedError;
  DateTime? get fechaAprobacion => throw _privateConstructorUsedError;
  DateTime? get fechaRecepcion => throw _privateConstructorUsedError;
  DateTime? get fechaReembolso => throw _privateConstructorUsedError;
  int? get importeReembolso => throw _privateConstructorUsedError;
  String? get metodoReembolso => throw _privateConstructorUsedError;
  PedidoModel? get pedido => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DevolucionModelCopyWith<DevolucionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DevolucionModelCopyWith<$Res> {
  factory $DevolucionModelCopyWith(
          DevolucionModel value, $Res Function(DevolucionModel) then) =
      _$DevolucionModelCopyWithImpl<$Res, DevolucionModel>;
  @useResult
  $Res call(
      {String id,
      String ordenId,
      String numeroDevolucion,
      String motivo,
      String estado,
      String? notasAdmin,
      DateTime? fechaSolicitud,
      DateTime? fechaAprobacion,
      DateTime? fechaRecepcion,
      DateTime? fechaReembolso,
      int? importeReembolso,
      String? metodoReembolso,
      PedidoModel? pedido});

  $PedidoModelCopyWith<$Res>? get pedido;
}

/// @nodoc
class _$DevolucionModelCopyWithImpl<$Res, $Val extends DevolucionModel>
    implements $DevolucionModelCopyWith<$Res> {
  _$DevolucionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ordenId = null,
    Object? numeroDevolucion = null,
    Object? motivo = null,
    Object? estado = null,
    Object? notasAdmin = freezed,
    Object? fechaSolicitud = freezed,
    Object? fechaAprobacion = freezed,
    Object? fechaRecepcion = freezed,
    Object? fechaReembolso = freezed,
    Object? importeReembolso = freezed,
    Object? metodoReembolso = freezed,
    Object? pedido = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ordenId: null == ordenId
          ? _value.ordenId
          : ordenId // ignore: cast_nullable_to_non_nullable
              as String,
      numeroDevolucion: null == numeroDevolucion
          ? _value.numeroDevolucion
          : numeroDevolucion // ignore: cast_nullable_to_non_nullable
              as String,
      motivo: null == motivo
          ? _value.motivo
          : motivo // ignore: cast_nullable_to_non_nullable
              as String,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      notasAdmin: freezed == notasAdmin
          ? _value.notasAdmin
          : notasAdmin // ignore: cast_nullable_to_non_nullable
              as String?,
      fechaSolicitud: freezed == fechaSolicitud
          ? _value.fechaSolicitud
          : fechaSolicitud // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaAprobacion: freezed == fechaAprobacion
          ? _value.fechaAprobacion
          : fechaAprobacion // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaRecepcion: freezed == fechaRecepcion
          ? _value.fechaRecepcion
          : fechaRecepcion // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaReembolso: freezed == fechaReembolso
          ? _value.fechaReembolso
          : fechaReembolso // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      importeReembolso: freezed == importeReembolso
          ? _value.importeReembolso
          : importeReembolso // ignore: cast_nullable_to_non_nullable
              as int?,
      metodoReembolso: freezed == metodoReembolso
          ? _value.metodoReembolso
          : metodoReembolso // ignore: cast_nullable_to_non_nullable
              as String?,
      pedido: freezed == pedido
          ? _value.pedido
          : pedido // ignore: cast_nullable_to_non_nullable
              as PedidoModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PedidoModelCopyWith<$Res>? get pedido {
    if (_value.pedido == null) {
      return null;
    }

    return $PedidoModelCopyWith<$Res>(_value.pedido!, (value) {
      return _then(_value.copyWith(pedido: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DevolucionModelImplCopyWith<$Res>
    implements $DevolucionModelCopyWith<$Res> {
  factory _$$DevolucionModelImplCopyWith(_$DevolucionModelImpl value,
          $Res Function(_$DevolucionModelImpl) then) =
      __$$DevolucionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String ordenId,
      String numeroDevolucion,
      String motivo,
      String estado,
      String? notasAdmin,
      DateTime? fechaSolicitud,
      DateTime? fechaAprobacion,
      DateTime? fechaRecepcion,
      DateTime? fechaReembolso,
      int? importeReembolso,
      String? metodoReembolso,
      PedidoModel? pedido});

  @override
  $PedidoModelCopyWith<$Res>? get pedido;
}

/// @nodoc
class __$$DevolucionModelImplCopyWithImpl<$Res>
    extends _$DevolucionModelCopyWithImpl<$Res, _$DevolucionModelImpl>
    implements _$$DevolucionModelImplCopyWith<$Res> {
  __$$DevolucionModelImplCopyWithImpl(
      _$DevolucionModelImpl _value, $Res Function(_$DevolucionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ordenId = null,
    Object? numeroDevolucion = null,
    Object? motivo = null,
    Object? estado = null,
    Object? notasAdmin = freezed,
    Object? fechaSolicitud = freezed,
    Object? fechaAprobacion = freezed,
    Object? fechaRecepcion = freezed,
    Object? fechaReembolso = freezed,
    Object? importeReembolso = freezed,
    Object? metodoReembolso = freezed,
    Object? pedido = freezed,
  }) {
    return _then(_$DevolucionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ordenId: null == ordenId
          ? _value.ordenId
          : ordenId // ignore: cast_nullable_to_non_nullable
              as String,
      numeroDevolucion: null == numeroDevolucion
          ? _value.numeroDevolucion
          : numeroDevolucion // ignore: cast_nullable_to_non_nullable
              as String,
      motivo: null == motivo
          ? _value.motivo
          : motivo // ignore: cast_nullable_to_non_nullable
              as String,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      notasAdmin: freezed == notasAdmin
          ? _value.notasAdmin
          : notasAdmin // ignore: cast_nullable_to_non_nullable
              as String?,
      fechaSolicitud: freezed == fechaSolicitud
          ? _value.fechaSolicitud
          : fechaSolicitud // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaAprobacion: freezed == fechaAprobacion
          ? _value.fechaAprobacion
          : fechaAprobacion // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaRecepcion: freezed == fechaRecepcion
          ? _value.fechaRecepcion
          : fechaRecepcion // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaReembolso: freezed == fechaReembolso
          ? _value.fechaReembolso
          : fechaReembolso // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      importeReembolso: freezed == importeReembolso
          ? _value.importeReembolso
          : importeReembolso // ignore: cast_nullable_to_non_nullable
              as int?,
      metodoReembolso: freezed == metodoReembolso
          ? _value.metodoReembolso
          : metodoReembolso // ignore: cast_nullable_to_non_nullable
              as String?,
      pedido: freezed == pedido
          ? _value.pedido
          : pedido // ignore: cast_nullable_to_non_nullable
              as PedidoModel?,
    ));
  }
}

/// @nodoc

class _$DevolucionModelImpl extends _DevolucionModel {
  const _$DevolucionModelImpl(
      {required this.id,
      required this.ordenId,
      required this.numeroDevolucion,
      required this.motivo,
      this.estado = 'Pendiente',
      this.notasAdmin,
      this.fechaSolicitud,
      this.fechaAprobacion,
      this.fechaRecepcion,
      this.fechaReembolso,
      this.importeReembolso,
      this.metodoReembolso,
      this.pedido})
      : super._();

  @override
  final String id;
  @override
  final String ordenId;
  @override
  final String numeroDevolucion;
  @override
  final String motivo;
  @override
  @JsonKey()
  final String estado;
  @override
  final String? notasAdmin;
  @override
  final DateTime? fechaSolicitud;
  @override
  final DateTime? fechaAprobacion;
  @override
  final DateTime? fechaRecepcion;
  @override
  final DateTime? fechaReembolso;
  @override
  final int? importeReembolso;
  @override
  final String? metodoReembolso;
  @override
  final PedidoModel? pedido;

  @override
  String toString() {
    return 'DevolucionModel(id: $id, ordenId: $ordenId, numeroDevolucion: $numeroDevolucion, motivo: $motivo, estado: $estado, notasAdmin: $notasAdmin, fechaSolicitud: $fechaSolicitud, fechaAprobacion: $fechaAprobacion, fechaRecepcion: $fechaRecepcion, fechaReembolso: $fechaReembolso, importeReembolso: $importeReembolso, metodoReembolso: $metodoReembolso, pedido: $pedido)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DevolucionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ordenId, ordenId) || other.ordenId == ordenId) &&
            (identical(other.numeroDevolucion, numeroDevolucion) ||
                other.numeroDevolucion == numeroDevolucion) &&
            (identical(other.motivo, motivo) || other.motivo == motivo) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.notasAdmin, notasAdmin) ||
                other.notasAdmin == notasAdmin) &&
            (identical(other.fechaSolicitud, fechaSolicitud) ||
                other.fechaSolicitud == fechaSolicitud) &&
            (identical(other.fechaAprobacion, fechaAprobacion) ||
                other.fechaAprobacion == fechaAprobacion) &&
            (identical(other.fechaRecepcion, fechaRecepcion) ||
                other.fechaRecepcion == fechaRecepcion) &&
            (identical(other.fechaReembolso, fechaReembolso) ||
                other.fechaReembolso == fechaReembolso) &&
            (identical(other.importeReembolso, importeReembolso) ||
                other.importeReembolso == importeReembolso) &&
            (identical(other.metodoReembolso, metodoReembolso) ||
                other.metodoReembolso == metodoReembolso) &&
            (identical(other.pedido, pedido) || other.pedido == pedido));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      ordenId,
      numeroDevolucion,
      motivo,
      estado,
      notasAdmin,
      fechaSolicitud,
      fechaAprobacion,
      fechaRecepcion,
      fechaReembolso,
      importeReembolso,
      metodoReembolso,
      pedido);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DevolucionModelImplCopyWith<_$DevolucionModelImpl> get copyWith =>
      __$$DevolucionModelImplCopyWithImpl<_$DevolucionModelImpl>(
          this, _$identity);
}

abstract class _DevolucionModel extends DevolucionModel {
  const factory _DevolucionModel(
      {required final String id,
      required final String ordenId,
      required final String numeroDevolucion,
      required final String motivo,
      final String estado,
      final String? notasAdmin,
      final DateTime? fechaSolicitud,
      final DateTime? fechaAprobacion,
      final DateTime? fechaRecepcion,
      final DateTime? fechaReembolso,
      final int? importeReembolso,
      final String? metodoReembolso,
      final PedidoModel? pedido}) = _$DevolucionModelImpl;
  const _DevolucionModel._() : super._();

  @override
  String get id;
  @override
  String get ordenId;
  @override
  String get numeroDevolucion;
  @override
  String get motivo;
  @override
  String get estado;
  @override
  String? get notasAdmin;
  @override
  DateTime? get fechaSolicitud;
  @override
  DateTime? get fechaAprobacion;
  @override
  DateTime? get fechaRecepcion;
  @override
  DateTime? get fechaReembolso;
  @override
  int? get importeReembolso;
  @override
  String? get metodoReembolso;
  @override
  PedidoModel? get pedido;
  @override
  @JsonKey(ignore: true)
  _$$DevolucionModelImplCopyWith<_$DevolucionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
