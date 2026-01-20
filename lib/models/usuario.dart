/// Modelo de Usuario
class Usuario {
  final String id;
  final String email;
  final String nombre;
  final String? apellidos;
  final String? telefono;
  final String? genero;
  final DateTime? fechaNacimiento;
  final String? fotoPerfil;
  final bool activo;
  final bool verificado;
  final DateTime? fechaRegistro;
  final DateTime? ultimoAcceso;

  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    this.apellidos,
    this.telefono,
    this.genero,
    this.fechaNacimiento,
    this.fotoPerfil,
    this.activo = true,
    this.verificado = false,
    this.fechaRegistro,
    this.ultimoAcceso,
  });

  /// Nombre completo
  String get nombreCompleto {
    if (apellidos != null && apellidos!.isNotEmpty) {
      return '$nombre $apellidos';
    }
    return nombre;
  }

  /// Iniciales del nombre
  String get iniciales {
    final parts = nombreCompleto.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      apellidos: json['apellidos'] as String?,
      telefono: json['telefono'] as String?,
      genero: json['genero'] as String?,
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'] as String)
          : null,
      fotoPerfil: json['foto_perfil'] as String?,
      activo: json['activo'] as bool? ?? true,
      verificado: json['verificado'] as bool? ?? false,
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'] as String)
          : null,
      ultimoAcceso: json['ultimo_acceso'] != null
          ? DateTime.parse(json['ultimo_acceso'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellidos': apellidos,
      'telefono': telefono,
      'genero': genero,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'foto_perfil': fotoPerfil,
      'activo': activo,
      'verificado': verificado,
    };
  }

  Usuario copyWith({
    String? nombre,
    String? apellidos,
    String? telefono,
    String? genero,
    DateTime? fechaNacimiento,
    String? fotoPerfil,
  }) {
    return Usuario(
      id: id,
      email: email,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      telefono: telefono ?? this.telefono,
      genero: genero ?? this.genero,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      activo: activo,
      verificado: verificado,
      fechaRegistro: fechaRegistro,
      ultimoAcceso: ultimoAcceso,
    );
  }
}

/// Modelo de Dirección
class Direccion {
  final String id;
  final String usuarioId;
  final String? tipo; // 'Envío', 'Facturación', 'Ambas'
  final String nombreDestinatario;
  final String calle;
  final String numero;
  final String? piso;
  final String codigoPostal;
  final String ciudad;
  final String provincia;
  final String pais;
  final bool esPredeterminada;

  Direccion({
    required this.id,
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
    this.esPredeterminada = false,
  });

  /// Dirección completa en una línea
  String get direccionCompleta {
    final parts = <String>[calle, numero];
    if (piso != null && piso!.isNotEmpty) parts.add(piso!);
    parts.addAll([codigoPostal, ciudad, provincia, pais]);
    return parts.join(', ');
  }

  /// Dirección corta
  String get direccionCorta => '$calle $numero, $ciudad';

  factory Direccion.fromJson(Map<String, dynamic> json) {
    return Direccion(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      tipo: json['tipo'] as String?,
      nombreDestinatario: json['nombre_destinatario'] as String,
      calle: json['calle'] as String,
      numero: json['numero'] as String,
      piso: json['piso'] as String?,
      codigoPostal: json['codigo_postal'] as String,
      ciudad: json['ciudad'] as String,
      provincia: json['provincia'] as String,
      pais: json['pais'] as String? ?? 'España',
      esPredeterminada: json['es_predeterminada'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'tipo': tipo,
      'nombre_destinatario': nombreDestinatario,
      'calle': calle,
      'numero': numero,
      'piso': piso,
      'codigo_postal': codigoPostal,
      'ciudad': ciudad,
      'provincia': provincia,
      'pais': pais,
      'es_predeterminada': esPredeterminada,
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}
