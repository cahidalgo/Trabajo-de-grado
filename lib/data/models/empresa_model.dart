class EmpresaModel {
  final int? id;
  final String? authId;     // UUID de auth.users
  final String razonSocial;
  final String nit;
  final String sector;
  final String correo;
  final String? telefono;
  final String? descripcion;
  final String? fotoPerfil;
  final bool validado;
  final String fechaRegistro;

  EmpresaModel({
    this.id,
    this.authId,
    required this.razonSocial,
    required this.nit,
    required this.sector,
    required this.correo,
    this.telefono,
    this.descripcion,
    this.fotoPerfil,
    this.validado = false,
    required this.fechaRegistro,
  });

  EmpresaModel copyWith({
    int? id,
    String? authId,
    String? razonSocial,
    String? nit,
    String? sector,
    String? correo,
    String? telefono,
    String? descripcion,
    String? fotoPerfil,
    bool? validado,
    String? fechaRegistro,
  }) =>
      EmpresaModel(
        id:            id ?? this.id,
        authId:        authId ?? this.authId,
        razonSocial:   razonSocial ?? this.razonSocial,
        nit:           nit ?? this.nit,
        sector:        sector ?? this.sector,
        correo:        correo ?? this.correo,
        telefono:      telefono ?? this.telefono,
        descripcion:   descripcion ?? this.descripcion,
        fotoPerfil:    fotoPerfil ?? this.fotoPerfil,
        validado:      validado ?? this.validado,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'razon_social':  razonSocial,
      'nit':           nit,
      'sector':        sector,
      'correo':        correo,
      'telefono':      telefono,
      'descripcion':   descripcion,
      'foto_perfil':   fotoPerfil,
      'validado':      validado,
      'fecha_registro': fechaRegistro,
    };
    if (id != null) map['id'] = id;
    if (authId != null) map['auth_id'] = authId;
    return map;
  }

  /// Map sin id ni auth_id, seguro para UPDATE en Supabase
  Map<String, dynamic> toUpdateMap() => {
    'razon_social':   razonSocial,
    'nit':            nit,
    'sector':         sector,
    'correo':         correo,
    'telefono':       telefono,
    'descripcion':    descripcion,
    'foto_perfil':    fotoPerfil,
    'validado':       validado,
    'fecha_registro': fechaRegistro,
  };

  factory EmpresaModel.fromMap(Map<String, dynamic> map) => EmpresaModel(
    id:            map['id'] as int?,
    authId:        map['auth_id'] as String?,
    razonSocial:   map['razon_social'] as String? ?? '',
    nit:           map['nit'] as String? ?? '',
    sector:        map['sector'] as String? ?? '',
    correo:        map['correo'] as String? ?? '',
    telefono:      map['telefono'] as String?,
    descripcion:   map['descripcion'] as String?,
    fotoPerfil:    map['foto_perfil'] as String?,
    validado:      map['validado'] == true || map['validado'] == 1,
    fechaRegistro: map['fecha_registro'] as String? ?? '',
  );
}
