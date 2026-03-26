class EmpresaModel {
  final int? id;
  final String razonSocial;
  final String nit;
  final String sector;
  final String correo;
  final String? telefono;
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
    required this.contrasenaHash,
    this.validado = false,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'razon_social': razonSocial,
      'nit': nit,
      'sector': sector,
      'correo': correo,
      'telefono': telefono,
      'contrasena_hash': contrasenaHash,
      'validado': validado ? 1 : 0,
      'fecha_registro': fechaRegistro,
    };
    // Solo incluye id si ya existe (updates), nunca en inserts
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
    contrasenaHash: map['contrasena_hash'],
    validado: map['validado'] == 1,
    fechaRegistro: map['fecha_registro'],
  );
}
