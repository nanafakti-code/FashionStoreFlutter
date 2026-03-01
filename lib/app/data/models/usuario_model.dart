import 'package:freezed_annotation/freezed_annotation.dart';

part 'usuario_model.freezed.dart';

@Freezed(toJson: false, fromJson: false)
class UsuarioModel with _$UsuarioModel {
  const UsuarioModel._();

  const factory UsuarioModel({
    required String id,
    required String email,
    String? nombre,
    String? apellidos,
    String? telefono,
    String? fotoPerfil,
    String? genero,
    DateTime? fechaNacimiento,
    @Default('user') String rol,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) = _UsuarioModel;

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
        id: json['id'] as String,
        email: json['email'] as String,
        nombre: json['nombre'] as String?,
        apellidos: json['apellidos'] as String?,
        telefono: json['telefono'] as String?,
        fotoPerfil: json['foto_perfil'] as String?,
        genero: json['genero'] as String?,
        fechaNacimiento: json['fecha_nacimiento'] != null
            ? DateTime.parse(json['fecha_nacimiento'] as String)
            : null,
        rol: json['rol'] as String? ?? 'user',
        creadoEn: json['creado_en'] != null
            ? DateTime.parse(json['creado_en'] as String)
            : null,
        actualizadoEn: json['actualizado_en'] != null
            ? DateTime.parse(json['actualizado_en'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'nombre': nombre,
        'apellidos': apellidos,
        'telefono': telefono,
        'foto_perfil': fotoPerfil,
        'genero': genero,
        'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
        'rol': rol,
      };

  String get nombreCompleto {
    if (nombre == null && apellidos == null) return email;
    return '${nombre ?? ''} ${apellidos ?? ''}'.trim();
  }
}
