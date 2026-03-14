class Usuario {
  final int? id;
  final String? nombreCompleto;
  final String correoOTelefono;
  final String contrasenaHash;
  final bool aceptoPolitica;
  final String fechaRegistro;

  Usuario({
    this.id,
    this.nombreCompleto,
    required this.correoOTelefono,
    required this.contrasenaHash,
    required this.aceptoPolitica,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombreCompleto': nombreCompleto,
    'correoOTelefono': correoOTelefono,
    'contrasenaHash': contrasenaHash,
    'aceptoPolitica': aceptoPolitica ? 1 : 0,
    'fechaRegistro': fechaRegistro,
  };

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
    id: map['id'],
    nombreCompleto: map['nombreCompleto'],
    correoOTelefono: map['correoOTelefono'],
    contrasenaHash: map['contrasenaHash'],
    aceptoPolitica: map['aceptoPolitica'] == 1,
    fechaRegistro: map['fechaRegistro'],
  );
}
