// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'extra_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CuponModel {
  String get id => throw _privateConstructorUsedError;
  String get codigo => throw _privateConstructorUsedError;
  String? get descripcion => throw _privateConstructorUsedError;
  String get tipo =>
      throw _privateConstructorUsedError; // 'Porcentaje' | 'Cantidad Fija'
  double get valor => throw _privateConstructorUsedError;
  int get minimoCompra => throw _privateConstructorUsedError;
  int? get maximoUses => throw _privateConstructorUsedError;
  int get usosActuales => throw _privateConstructorUsedError;
  String? get categoriaId => throw _privateConstructorUsedError;
  bool get activo => throw _privateConstructorUsedError;
  DateTime? get fechaInicio => throw _privateConstructorUsedError;
  DateTime? get fechaFin => throw _privateConstructorUsedError;
  DateTime? get creadoEn => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CuponModelCopyWith<CuponModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CuponModelCopyWith<$Res> {
  factory $CuponModelCopyWith(
          CuponModel value, $Res Function(CuponModel) then) =
      _$CuponModelCopyWithImpl<$Res, CuponModel>;
  @useResult
  $Res call(
      {String id,
      String codigo,
      String? descripcion,
      String tipo,
      double valor,
      int minimoCompra,
      int? maximoUses,
      int usosActuales,
      String? categoriaId,
      bool activo,
      DateTime? fechaInicio,
      DateTime? fechaFin,
      DateTime? creadoEn});
}

/// @nodoc
class _$CuponModelCopyWithImpl<$Res, $Val extends CuponModel>
    implements $CuponModelCopyWith<$Res> {
  _$CuponModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? descripcion = freezed,
    Object? tipo = null,
    Object? valor = null,
    Object? minimoCompra = null,
    Object? maximoUses = freezed,
    Object? usosActuales = null,
    Object? categoriaId = freezed,
    Object? activo = null,
    Object? fechaInicio = freezed,
    Object? fechaFin = freezed,
    Object? creadoEn = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: null == codigo
          ? _value.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: freezed == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as String,
      valor: null == valor
          ? _value.valor
          : valor // ignore: cast_nullable_to_non_nullable
              as double,
      minimoCompra: null == minimoCompra
          ? _value.minimoCompra
          : minimoCompra // ignore: cast_nullable_to_non_nullable
              as int,
      maximoUses: freezed == maximoUses
          ? _value.maximoUses
          : maximoUses // ignore: cast_nullable_to_non_nullable
              as int?,
      usosActuales: null == usosActuales
          ? _value.usosActuales
          : usosActuales // ignore: cast_nullable_to_non_nullable
              as int,
      categoriaId: freezed == categoriaId
          ? _value.categoriaId
          : categoriaId // ignore: cast_nullable_to_non_nullable
              as String?,
      activo: null == activo
          ? _value.activo
          : activo // ignore: cast_nullable_to_non_nullable
              as bool,
      fechaInicio: freezed == fechaInicio
          ? _value.fechaInicio
          : fechaInicio // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaFin: freezed == fechaFin
          ? _value.fechaFin
          : fechaFin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creadoEn: freezed == creadoEn
          ? _value.creadoEn
          : creadoEn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CuponModelImplCopyWith<$Res>
    implements $CuponModelCopyWith<$Res> {
  factory _$$CuponModelImplCopyWith(
          _$CuponModelImpl value, $Res Function(_$CuponModelImpl) then) =
      __$$CuponModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String codigo,
      String? descripcion,
      String tipo,
      double valor,
      int minimoCompra,
      int? maximoUses,
      int usosActuales,
      String? categoriaId,
      bool activo,
      DateTime? fechaInicio,
      DateTime? fechaFin,
      DateTime? creadoEn});
}

/// @nodoc
class __$$CuponModelImplCopyWithImpl<$Res>
    extends _$CuponModelCopyWithImpl<$Res, _$CuponModelImpl>
    implements _$$CuponModelImplCopyWith<$Res> {
  __$$CuponModelImplCopyWithImpl(
      _$CuponModelImpl _value, $Res Function(_$CuponModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? descripcion = freezed,
    Object? tipo = null,
    Object? valor = null,
    Object? minimoCompra = null,
    Object? maximoUses = freezed,
    Object? usosActuales = null,
    Object? categoriaId = freezed,
    Object? activo = null,
    Object? fechaInicio = freezed,
    Object? fechaFin = freezed,
    Object? creadoEn = freezed,
  }) {
    return _then(_$CuponModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: null == codigo
          ? _value.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: freezed == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as String,
      valor: null == valor
          ? _value.valor
          : valor // ignore: cast_nullable_to_non_nullable
              as double,
      minimoCompra: null == minimoCompra
          ? _value.minimoCompra
          : minimoCompra // ignore: cast_nullable_to_non_nullable
              as int,
      maximoUses: freezed == maximoUses
          ? _value.maximoUses
          : maximoUses // ignore: cast_nullable_to_non_nullable
              as int?,
      usosActuales: null == usosActuales
          ? _value.usosActuales
          : usosActuales // ignore: cast_nullable_to_non_nullable
              as int,
      categoriaId: freezed == categoriaId
          ? _value.categoriaId
          : categoriaId // ignore: cast_nullable_to_non_nullable
              as String?,
      activo: null == activo
          ? _value.activo
          : activo // ignore: cast_nullable_to_non_nullable
              as bool,
      fechaInicio: freezed == fechaInicio
          ? _value.fechaInicio
          : fechaInicio // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaFin: freezed == fechaFin
          ? _value.fechaFin
          : fechaFin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creadoEn: freezed == creadoEn
          ? _value.creadoEn
          : creadoEn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$CuponModelImpl extends _CuponModel {
  const _$CuponModelImpl(
      {required this.id,
      required this.codigo,
      this.descripcion,
      required this.tipo,
      required this.valor,
      this.minimoCompra = 0,
      this.maximoUses,
      this.usosActuales = 0,
      this.categoriaId,
      this.activo = true,
      this.fechaInicio,
      this.fechaFin,
      this.creadoEn})
      : super._();

  @override
  final String id;
  @override
  final String codigo;
  @override
  final String? descripcion;
  @override
  final String tipo;
// 'Porcentaje' | 'Cantidad Fija'
  @override
  final double valor;
  @override
  @JsonKey()
  final int minimoCompra;
  @override
  final int? maximoUses;
  @override
  @JsonKey()
  final int usosActuales;
  @override
  final String? categoriaId;
  @override
  @JsonKey()
  final bool activo;
  @override
  final DateTime? fechaInicio;
  @override
  final DateTime? fechaFin;
  @override
  final DateTime? creadoEn;

  @override
  String toString() {
    return 'CuponModel(id: $id, codigo: $codigo, descripcion: $descripcion, tipo: $tipo, valor: $valor, minimoCompra: $minimoCompra, maximoUses: $maximoUses, usosActuales: $usosActuales, categoriaId: $categoriaId, activo: $activo, fechaInicio: $fechaInicio, fechaFin: $fechaFin, creadoEn: $creadoEn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CuponModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.valor, valor) || other.valor == valor) &&
            (identical(other.minimoCompra, minimoCompra) ||
                other.minimoCompra == minimoCompra) &&
            (identical(other.maximoUses, maximoUses) ||
                other.maximoUses == maximoUses) &&
            (identical(other.usosActuales, usosActuales) ||
                other.usosActuales == usosActuales) &&
            (identical(other.categoriaId, categoriaId) ||
                other.categoriaId == categoriaId) &&
            (identical(other.activo, activo) || other.activo == activo) &&
            (identical(other.fechaInicio, fechaInicio) ||
                other.fechaInicio == fechaInicio) &&
            (identical(other.fechaFin, fechaFin) ||
                other.fechaFin == fechaFin) &&
            (identical(other.creadoEn, creadoEn) ||
                other.creadoEn == creadoEn));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      codigo,
      descripcion,
      tipo,
      valor,
      minimoCompra,
      maximoUses,
      usosActuales,
      categoriaId,
      activo,
      fechaInicio,
      fechaFin,
      creadoEn);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CuponModelImplCopyWith<_$CuponModelImpl> get copyWith =>
      __$$CuponModelImplCopyWithImpl<_$CuponModelImpl>(this, _$identity);
}

abstract class _CuponModel extends CuponModel {
  const factory _CuponModel(
      {required final String id,
      required final String codigo,
      final String? descripcion,
      required final String tipo,
      required final double valor,
      final int minimoCompra,
      final int? maximoUses,
      final int usosActuales,
      final String? categoriaId,
      final bool activo,
      final DateTime? fechaInicio,
      final DateTime? fechaFin,
      final DateTime? creadoEn}) = _$CuponModelImpl;
  const _CuponModel._() : super._();

  @override
  String get id;
  @override
  String get codigo;
  @override
  String? get descripcion;
  @override
  String get tipo;
  @override // 'Porcentaje' | 'Cantidad Fija'
  double get valor;
  @override
  int get minimoCompra;
  @override
  int? get maximoUses;
  @override
  int get usosActuales;
  @override
  String? get categoriaId;
  @override
  bool get activo;
  @override
  DateTime? get fechaInicio;
  @override
  DateTime? get fechaFin;
  @override
  DateTime? get creadoEn;
  @override
  @JsonKey(ignore: true)
  _$$CuponModelImplCopyWith<_$CuponModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DireccionModel {
  String get id => throw _privateConstructorUsedError;
  String get usuarioId => throw _privateConstructorUsedError;
  String? get tipo => throw _privateConstructorUsedError;
  String get nombreDestinatario => throw _privateConstructorUsedError;
  String get calle => throw _privateConstructorUsedError;
  String get numero => throw _privateConstructorUsedError;
  String? get piso => throw _privateConstructorUsedError;
  String get codigoPostal => throw _privateConstructorUsedError;
  String get ciudad => throw _privateConstructorUsedError;
  String get provincia => throw _privateConstructorUsedError;
  String get pais => throw _privateConstructorUsedError;
  bool get esPredeterminada => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DireccionModelCopyWith<DireccionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DireccionModelCopyWith<$Res> {
  factory $DireccionModelCopyWith(
          DireccionModel value, $Res Function(DireccionModel) then) =
      _$DireccionModelCopyWithImpl<$Res, DireccionModel>;
  @useResult
  $Res call(
      {String id,
      String usuarioId,
      String? tipo,
      String nombreDestinatario,
      String calle,
      String numero,
      String? piso,
      String codigoPostal,
      String ciudad,
      String provincia,
      String pais,
      bool esPredeterminada});
}

/// @nodoc
class _$DireccionModelCopyWithImpl<$Res, $Val extends DireccionModel>
    implements $DireccionModelCopyWith<$Res> {
  _$DireccionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? usuarioId = null,
    Object? tipo = freezed,
    Object? nombreDestinatario = null,
    Object? calle = null,
    Object? numero = null,
    Object? piso = freezed,
    Object? codigoPostal = null,
    Object? ciudad = null,
    Object? provincia = null,
    Object? pais = null,
    Object? esPredeterminada = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      usuarioId: null == usuarioId
          ? _value.usuarioId
          : usuarioId // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: freezed == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as String?,
      nombreDestinatario: null == nombreDestinatario
          ? _value.nombreDestinatario
          : nombreDestinatario // ignore: cast_nullable_to_non_nullable
              as String,
      calle: null == calle
          ? _value.calle
          : calle // ignore: cast_nullable_to_non_nullable
              as String,
      numero: null == numero
          ? _value.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as String,
      piso: freezed == piso
          ? _value.piso
          : piso // ignore: cast_nullable_to_non_nullable
              as String?,
      codigoPostal: null == codigoPostal
          ? _value.codigoPostal
          : codigoPostal // ignore: cast_nullable_to_non_nullable
              as String,
      ciudad: null == ciudad
          ? _value.ciudad
          : ciudad // ignore: cast_nullable_to_non_nullable
              as String,
      provincia: null == provincia
          ? _value.provincia
          : provincia // ignore: cast_nullable_to_non_nullable
              as String,
      pais: null == pais
          ? _value.pais
          : pais // ignore: cast_nullable_to_non_nullable
              as String,
      esPredeterminada: null == esPredeterminada
          ? _value.esPredeterminada
          : esPredeterminada // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DireccionModelImplCopyWith<$Res>
    implements $DireccionModelCopyWith<$Res> {
  factory _$$DireccionModelImplCopyWith(_$DireccionModelImpl value,
          $Res Function(_$DireccionModelImpl) then) =
      __$$DireccionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String usuarioId,
      String? tipo,
      String nombreDestinatario,
      String calle,
      String numero,
      String? piso,
      String codigoPostal,
      String ciudad,
      String provincia,
      String pais,
      bool esPredeterminada});
}

/// @nodoc
class __$$DireccionModelImplCopyWithImpl<$Res>
    extends _$DireccionModelCopyWithImpl<$Res, _$DireccionModelImpl>
    implements _$$DireccionModelImplCopyWith<$Res> {
  __$$DireccionModelImplCopyWithImpl(
      _$DireccionModelImpl _value, $Res Function(_$DireccionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? usuarioId = null,
    Object? tipo = freezed,
    Object? nombreDestinatario = null,
    Object? calle = null,
    Object? numero = null,
    Object? piso = freezed,
    Object? codigoPostal = null,
    Object? ciudad = null,
    Object? provincia = null,
    Object? pais = null,
    Object? esPredeterminada = null,
  }) {
    return _then(_$DireccionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      usuarioId: null == usuarioId
          ? _value.usuarioId
          : usuarioId // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: freezed == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as String?,
      nombreDestinatario: null == nombreDestinatario
          ? _value.nombreDestinatario
          : nombreDestinatario // ignore: cast_nullable_to_non_nullable
              as String,
      calle: null == calle
          ? _value.calle
          : calle // ignore: cast_nullable_to_non_nullable
              as String,
      numero: null == numero
          ? _value.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as String,
      piso: freezed == piso
          ? _value.piso
          : piso // ignore: cast_nullable_to_non_nullable
              as String?,
      codigoPostal: null == codigoPostal
          ? _value.codigoPostal
          : codigoPostal // ignore: cast_nullable_to_non_nullable
              as String,
      ciudad: null == ciudad
          ? _value.ciudad
          : ciudad // ignore: cast_nullable_to_non_nullable
              as String,
      provincia: null == provincia
          ? _value.provincia
          : provincia // ignore: cast_nullable_to_non_nullable
              as String,
      pais: null == pais
          ? _value.pais
          : pais // ignore: cast_nullable_to_non_nullable
              as String,
      esPredeterminada: null == esPredeterminada
          ? _value.esPredeterminada
          : esPredeterminada // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$DireccionModelImpl extends _DireccionModel {
  const _$DireccionModelImpl(
      {required this.id,
      required this.usuarioId,
      this.tipo,
      required this.nombreDestinatario,
      required this.calle,
      required this.numero,
      this.piso,
      required this.codigoPostal,
      required this.ciudad,
      required this.provincia,
      this.pais = 'España',
      this.esPredeterminada = false})
      : super._();

  @override
  final String id;
  @override
  final String usuarioId;
  @override
  final String? tipo;
  @override
  final String nombreDestinatario;
  @override
  final String calle;
  @override
  final String numero;
  @override
  final String? piso;
  @override
  final String codigoPostal;
  @override
  final String ciudad;
  @override
  final String provincia;
  @override
  @JsonKey()
  final String pais;
  @override
  @JsonKey()
  final bool esPredeterminada;

  @override
  String toString() {
    return 'DireccionModel(id: $id, usuarioId: $usuarioId, tipo: $tipo, nombreDestinatario: $nombreDestinatario, calle: $calle, numero: $numero, piso: $piso, codigoPostal: $codigoPostal, ciudad: $ciudad, provincia: $provincia, pais: $pais, esPredeterminada: $esPredeterminada)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DireccionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.usuarioId, usuarioId) ||
                other.usuarioId == usuarioId) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.nombreDestinatario, nombreDestinatario) ||
                other.nombreDestinatario == nombreDestinatario) &&
            (identical(other.calle, calle) || other.calle == calle) &&
            (identical(other.numero, numero) || other.numero == numero) &&
            (identical(other.piso, piso) || other.piso == piso) &&
            (identical(other.codigoPostal, codigoPostal) ||
                other.codigoPostal == codigoPostal) &&
            (identical(other.ciudad, ciudad) || other.ciudad == ciudad) &&
            (identical(other.provincia, provincia) ||
                other.provincia == provincia) &&
            (identical(other.pais, pais) || other.pais == pais) &&
            (identical(other.esPredeterminada, esPredeterminada) ||
                other.esPredeterminada == esPredeterminada));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      usuarioId,
      tipo,
      nombreDestinatario,
      calle,
      numero,
      piso,
      codigoPostal,
      ciudad,
      provincia,
      pais,
      esPredeterminada);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DireccionModelImplCopyWith<_$DireccionModelImpl> get copyWith =>
      __$$DireccionModelImplCopyWithImpl<_$DireccionModelImpl>(
          this, _$identity);
}

abstract class _DireccionModel extends DireccionModel {
  const factory _DireccionModel(
      {required final String id,
      required final String usuarioId,
      final String? tipo,
      required final String nombreDestinatario,
      required final String calle,
      required final String numero,
      final String? piso,
      required final String codigoPostal,
      required final String ciudad,
      required final String provincia,
      final String pais,
      final bool esPredeterminada}) = _$DireccionModelImpl;
  const _DireccionModel._() : super._();

  @override
  String get id;
  @override
  String get usuarioId;
  @override
  String? get tipo;
  @override
  String get nombreDestinatario;
  @override
  String get calle;
  @override
  String get numero;
  @override
  String? get piso;
  @override
  String get codigoPostal;
  @override
  String get ciudad;
  @override
  String get provincia;
  @override
  String get pais;
  @override
  bool get esPredeterminada;
  @override
  @JsonKey(ignore: true)
  _$$DireccionModelImplCopyWith<_$DireccionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NewsletterModel {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get nombre => throw _privateConstructorUsedError;
  String? get codigoDescuento => throw _privateConstructorUsedError;
  bool get usado => throw _privateConstructorUsedError;
  bool get activo => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NewsletterModelCopyWith<NewsletterModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsletterModelCopyWith<$Res> {
  factory $NewsletterModelCopyWith(
          NewsletterModel value, $Res Function(NewsletterModel) then) =
      _$NewsletterModelCopyWithImpl<$Res, NewsletterModel>;
  @useResult
  $Res call(
      {String id,
      String email,
      String? nombre,
      String? codigoDescuento,
      bool usado,
      bool activo,
      DateTime? createdAt});
}

/// @nodoc
class _$NewsletterModelCopyWithImpl<$Res, $Val extends NewsletterModel>
    implements $NewsletterModelCopyWith<$Res> {
  _$NewsletterModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? nombre = freezed,
    Object? codigoDescuento = freezed,
    Object? usado = null,
    Object? activo = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: freezed == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      codigoDescuento: freezed == codigoDescuento
          ? _value.codigoDescuento
          : codigoDescuento // ignore: cast_nullable_to_non_nullable
              as String?,
      usado: null == usado
          ? _value.usado
          : usado // ignore: cast_nullable_to_non_nullable
              as bool,
      activo: null == activo
          ? _value.activo
          : activo // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NewsletterModelImplCopyWith<$Res>
    implements $NewsletterModelCopyWith<$Res> {
  factory _$$NewsletterModelImplCopyWith(_$NewsletterModelImpl value,
          $Res Function(_$NewsletterModelImpl) then) =
      __$$NewsletterModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String? nombre,
      String? codigoDescuento,
      bool usado,
      bool activo,
      DateTime? createdAt});
}

/// @nodoc
class __$$NewsletterModelImplCopyWithImpl<$Res>
    extends _$NewsletterModelCopyWithImpl<$Res, _$NewsletterModelImpl>
    implements _$$NewsletterModelImplCopyWith<$Res> {
  __$$NewsletterModelImplCopyWithImpl(
      _$NewsletterModelImpl _value, $Res Function(_$NewsletterModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? nombre = freezed,
    Object? codigoDescuento = freezed,
    Object? usado = null,
    Object? activo = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$NewsletterModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: freezed == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      codigoDescuento: freezed == codigoDescuento
          ? _value.codigoDescuento
          : codigoDescuento // ignore: cast_nullable_to_non_nullable
              as String?,
      usado: null == usado
          ? _value.usado
          : usado // ignore: cast_nullable_to_non_nullable
              as bool,
      activo: null == activo
          ? _value.activo
          : activo // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$NewsletterModelImpl extends _NewsletterModel {
  const _$NewsletterModelImpl(
      {required this.id,
      required this.email,
      this.nombre,
      this.codigoDescuento,
      this.usado = false,
      this.activo = true,
      this.createdAt})
      : super._();

  @override
  final String id;
  @override
  final String email;
  @override
  final String? nombre;
  @override
  final String? codigoDescuento;
  @override
  @JsonKey()
  final bool usado;
  @override
  @JsonKey()
  final bool activo;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'NewsletterModel(id: $id, email: $email, nombre: $nombre, codigoDescuento: $codigoDescuento, usado: $usado, activo: $activo, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsletterModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.codigoDescuento, codigoDescuento) ||
                other.codigoDescuento == codigoDescuento) &&
            (identical(other.usado, usado) || other.usado == usado) &&
            (identical(other.activo, activo) || other.activo == activo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, email, nombre,
      codigoDescuento, usado, activo, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsletterModelImplCopyWith<_$NewsletterModelImpl> get copyWith =>
      __$$NewsletterModelImplCopyWithImpl<_$NewsletterModelImpl>(
          this, _$identity);
}

abstract class _NewsletterModel extends NewsletterModel {
  const factory _NewsletterModel(
      {required final String id,
      required final String email,
      final String? nombre,
      final String? codigoDescuento,
      final bool usado,
      final bool activo,
      final DateTime? createdAt}) = _$NewsletterModelImpl;
  const _NewsletterModel._() : super._();

  @override
  String get id;
  @override
  String get email;
  @override
  String? get nombre;
  @override
  String? get codigoDescuento;
  @override
  bool get usado;
  @override
  bool get activo;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$NewsletterModelImplCopyWith<_$NewsletterModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CampanaModel {
  String get id => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String? get descripcion => throw _privateConstructorUsedError;
  String get asunto => throw _privateConstructorUsedError;
  String get contenidoHtml => throw _privateConstructorUsedError;
  String get estado => throw _privateConstructorUsedError;
  String? get tipoSegmento => throw _privateConstructorUsedError;
  DateTime? get fechaProgramada => throw _privateConstructorUsedError;
  DateTime? get fechaEnvio => throw _privateConstructorUsedError;
  int get totalDestinatarios => throw _privateConstructorUsedError;
  int get totalEnviados => throw _privateConstructorUsedError;
  int get totalAbiertos => throw _privateConstructorUsedError;
  int get totalClicks => throw _privateConstructorUsedError;
  DateTime? get creadaEn => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CampanaModelCopyWith<CampanaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CampanaModelCopyWith<$Res> {
  factory $CampanaModelCopyWith(
          CampanaModel value, $Res Function(CampanaModel) then) =
      _$CampanaModelCopyWithImpl<$Res, CampanaModel>;
  @useResult
  $Res call(
      {String id,
      String nombre,
      String? descripcion,
      String asunto,
      String contenidoHtml,
      String estado,
      String? tipoSegmento,
      DateTime? fechaProgramada,
      DateTime? fechaEnvio,
      int totalDestinatarios,
      int totalEnviados,
      int totalAbiertos,
      int totalClicks,
      DateTime? creadaEn});
}

/// @nodoc
class _$CampanaModelCopyWithImpl<$Res, $Val extends CampanaModel>
    implements $CampanaModelCopyWith<$Res> {
  _$CampanaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? descripcion = freezed,
    Object? asunto = null,
    Object? contenidoHtml = null,
    Object? estado = null,
    Object? tipoSegmento = freezed,
    Object? fechaProgramada = freezed,
    Object? fechaEnvio = freezed,
    Object? totalDestinatarios = null,
    Object? totalEnviados = null,
    Object? totalAbiertos = null,
    Object? totalClicks = null,
    Object? creadaEn = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: freezed == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      asunto: null == asunto
          ? _value.asunto
          : asunto // ignore: cast_nullable_to_non_nullable
              as String,
      contenidoHtml: null == contenidoHtml
          ? _value.contenidoHtml
          : contenidoHtml // ignore: cast_nullable_to_non_nullable
              as String,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      tipoSegmento: freezed == tipoSegmento
          ? _value.tipoSegmento
          : tipoSegmento // ignore: cast_nullable_to_non_nullable
              as String?,
      fechaProgramada: freezed == fechaProgramada
          ? _value.fechaProgramada
          : fechaProgramada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaEnvio: freezed == fechaEnvio
          ? _value.fechaEnvio
          : fechaEnvio // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalDestinatarios: null == totalDestinatarios
          ? _value.totalDestinatarios
          : totalDestinatarios // ignore: cast_nullable_to_non_nullable
              as int,
      totalEnviados: null == totalEnviados
          ? _value.totalEnviados
          : totalEnviados // ignore: cast_nullable_to_non_nullable
              as int,
      totalAbiertos: null == totalAbiertos
          ? _value.totalAbiertos
          : totalAbiertos // ignore: cast_nullable_to_non_nullable
              as int,
      totalClicks: null == totalClicks
          ? _value.totalClicks
          : totalClicks // ignore: cast_nullable_to_non_nullable
              as int,
      creadaEn: freezed == creadaEn
          ? _value.creadaEn
          : creadaEn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CampanaModelImplCopyWith<$Res>
    implements $CampanaModelCopyWith<$Res> {
  factory _$$CampanaModelImplCopyWith(
          _$CampanaModelImpl value, $Res Function(_$CampanaModelImpl) then) =
      __$$CampanaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String nombre,
      String? descripcion,
      String asunto,
      String contenidoHtml,
      String estado,
      String? tipoSegmento,
      DateTime? fechaProgramada,
      DateTime? fechaEnvio,
      int totalDestinatarios,
      int totalEnviados,
      int totalAbiertos,
      int totalClicks,
      DateTime? creadaEn});
}

/// @nodoc
class __$$CampanaModelImplCopyWithImpl<$Res>
    extends _$CampanaModelCopyWithImpl<$Res, _$CampanaModelImpl>
    implements _$$CampanaModelImplCopyWith<$Res> {
  __$$CampanaModelImplCopyWithImpl(
      _$CampanaModelImpl _value, $Res Function(_$CampanaModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? descripcion = freezed,
    Object? asunto = null,
    Object? contenidoHtml = null,
    Object? estado = null,
    Object? tipoSegmento = freezed,
    Object? fechaProgramada = freezed,
    Object? fechaEnvio = freezed,
    Object? totalDestinatarios = null,
    Object? totalEnviados = null,
    Object? totalAbiertos = null,
    Object? totalClicks = null,
    Object? creadaEn = freezed,
  }) {
    return _then(_$CampanaModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _value.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: freezed == descripcion
          ? _value.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      asunto: null == asunto
          ? _value.asunto
          : asunto // ignore: cast_nullable_to_non_nullable
              as String,
      contenidoHtml: null == contenidoHtml
          ? _value.contenidoHtml
          : contenidoHtml // ignore: cast_nullable_to_non_nullable
              as String,
      estado: null == estado
          ? _value.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      tipoSegmento: freezed == tipoSegmento
          ? _value.tipoSegmento
          : tipoSegmento // ignore: cast_nullable_to_non_nullable
              as String?,
      fechaProgramada: freezed == fechaProgramada
          ? _value.fechaProgramada
          : fechaProgramada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaEnvio: freezed == fechaEnvio
          ? _value.fechaEnvio
          : fechaEnvio // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalDestinatarios: null == totalDestinatarios
          ? _value.totalDestinatarios
          : totalDestinatarios // ignore: cast_nullable_to_non_nullable
              as int,
      totalEnviados: null == totalEnviados
          ? _value.totalEnviados
          : totalEnviados // ignore: cast_nullable_to_non_nullable
              as int,
      totalAbiertos: null == totalAbiertos
          ? _value.totalAbiertos
          : totalAbiertos // ignore: cast_nullable_to_non_nullable
              as int,
      totalClicks: null == totalClicks
          ? _value.totalClicks
          : totalClicks // ignore: cast_nullable_to_non_nullable
              as int,
      creadaEn: freezed == creadaEn
          ? _value.creadaEn
          : creadaEn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$CampanaModelImpl extends _CampanaModel {
  const _$CampanaModelImpl(
      {required this.id,
      required this.nombre,
      this.descripcion,
      required this.asunto,
      required this.contenidoHtml,
      this.estado = 'Borrador',
      this.tipoSegmento,
      this.fechaProgramada,
      this.fechaEnvio,
      this.totalDestinatarios = 0,
      this.totalEnviados = 0,
      this.totalAbiertos = 0,
      this.totalClicks = 0,
      this.creadaEn})
      : super._();

  @override
  final String id;
  @override
  final String nombre;
  @override
  final String? descripcion;
  @override
  final String asunto;
  @override
  final String contenidoHtml;
  @override
  @JsonKey()
  final String estado;
  @override
  final String? tipoSegmento;
  @override
  final DateTime? fechaProgramada;
  @override
  final DateTime? fechaEnvio;
  @override
  @JsonKey()
  final int totalDestinatarios;
  @override
  @JsonKey()
  final int totalEnviados;
  @override
  @JsonKey()
  final int totalAbiertos;
  @override
  @JsonKey()
  final int totalClicks;
  @override
  final DateTime? creadaEn;

  @override
  String toString() {
    return 'CampanaModel(id: $id, nombre: $nombre, descripcion: $descripcion, asunto: $asunto, contenidoHtml: $contenidoHtml, estado: $estado, tipoSegmento: $tipoSegmento, fechaProgramada: $fechaProgramada, fechaEnvio: $fechaEnvio, totalDestinatarios: $totalDestinatarios, totalEnviados: $totalEnviados, totalAbiertos: $totalAbiertos, totalClicks: $totalClicks, creadaEn: $creadaEn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CampanaModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.asunto, asunto) || other.asunto == asunto) &&
            (identical(other.contenidoHtml, contenidoHtml) ||
                other.contenidoHtml == contenidoHtml) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.tipoSegmento, tipoSegmento) ||
                other.tipoSegmento == tipoSegmento) &&
            (identical(other.fechaProgramada, fechaProgramada) ||
                other.fechaProgramada == fechaProgramada) &&
            (identical(other.fechaEnvio, fechaEnvio) ||
                other.fechaEnvio == fechaEnvio) &&
            (identical(other.totalDestinatarios, totalDestinatarios) ||
                other.totalDestinatarios == totalDestinatarios) &&
            (identical(other.totalEnviados, totalEnviados) ||
                other.totalEnviados == totalEnviados) &&
            (identical(other.totalAbiertos, totalAbiertos) ||
                other.totalAbiertos == totalAbiertos) &&
            (identical(other.totalClicks, totalClicks) ||
                other.totalClicks == totalClicks) &&
            (identical(other.creadaEn, creadaEn) ||
                other.creadaEn == creadaEn));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      nombre,
      descripcion,
      asunto,
      contenidoHtml,
      estado,
      tipoSegmento,
      fechaProgramada,
      fechaEnvio,
      totalDestinatarios,
      totalEnviados,
      totalAbiertos,
      totalClicks,
      creadaEn);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CampanaModelImplCopyWith<_$CampanaModelImpl> get copyWith =>
      __$$CampanaModelImplCopyWithImpl<_$CampanaModelImpl>(this, _$identity);
}

abstract class _CampanaModel extends CampanaModel {
  const factory _CampanaModel(
      {required final String id,
      required final String nombre,
      final String? descripcion,
      required final String asunto,
      required final String contenidoHtml,
      final String estado,
      final String? tipoSegmento,
      final DateTime? fechaProgramada,
      final DateTime? fechaEnvio,
      final int totalDestinatarios,
      final int totalEnviados,
      final int totalAbiertos,
      final int totalClicks,
      final DateTime? creadaEn}) = _$CampanaModelImpl;
  const _CampanaModel._() : super._();

  @override
  String get id;
  @override
  String get nombre;
  @override
  String? get descripcion;
  @override
  String get asunto;
  @override
  String get contenidoHtml;
  @override
  String get estado;
  @override
  String? get tipoSegmento;
  @override
  DateTime? get fechaProgramada;
  @override
  DateTime? get fechaEnvio;
  @override
  int get totalDestinatarios;
  @override
  int get totalEnviados;
  @override
  int get totalAbiertos;
  @override
  int get totalClicks;
  @override
  DateTime? get creadaEn;
  @override
  @JsonKey(ignore: true)
  _$$CampanaModelImplCopyWith<_$CampanaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
