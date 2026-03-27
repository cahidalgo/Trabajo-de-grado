class EmpresaModel {
  final int? id;
  final String razonSocial;
  final String nit;
  final String sector;
  final String correo;
  final String? telefono;
  final String? descripcion;
  final String? fotoPerfil;
  final String contrasenaHash;
  final bool validado;
  final String fechaRegistro;

  EmpresaModel({
    this.id,
    required this.razonSocial,
    required this.nit,
    required this.sector,
    required this.correo,
    this.telefono,
    this.descripcion,
    this.fotoPerfil,
    required this.contrasenaHash,
    this.validado = false,
    required this.fechaRegistro,
  });

  EmpresaModel copyWith({
    int? id,
    String? razonSocial,
    String? nit,
    String? sector,
    String? correo,
    String? telefono,
    String? descripcion,
    String? fotoPerfil,
    String? contrasenaHash,
    bool? validado,
    String? fechaRegistro,
  }) =>
      EmpresaModel(
        id: id ?? this.id,
        razonSocial: razonSocial ?? this.razonSocial,
        nit: nit ?? this.nit,
        sector: sector ?? this.sector,
        correo: correo ?? this.correo,
        telefono: telefono ?? this.telefono,
        descripcion: descripcion ?? this.descripcion,
        fotoPerfil: fotoPerfil ?? this.fotoPerfil,
        contrasenaHash: contrasenaHash ?? this.contrasenaHash,
        validado: validado ?? this.validado,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'razon_social': razonSocial,
      'nit': nit,
      'sector': sector,
      'correo': correo,
      'telefono': telefono,
      'descripcion': descripcion,
      'foto_perfil': fotoPerfil,
      'contrasena_hash': contrasenaHash,
      'validado': validado ? 1 : 0,
      'fecha_registro': fechaRegistro,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory EmpresaModel.fromMap(Map<String, dynamic> map) => EmpresaModel(
        id: map['id'],
        razonSocial: map['razon_social'],
        nit: map['nit'],
        sector: map['sector'],
        correo: map['correo'],
        telefono: map['telefono'],
        descripcion: map['descripcion'],
        fotoPerfil: map['foto_perfil'],
        contrasenaHash: map['contrasena_hash'],
        validado: map['validado'] == 1,
        fechaRegistro: map['fecha_registro'],
      );
}
