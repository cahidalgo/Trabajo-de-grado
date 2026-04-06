class Usuario {
  final int? id;
  final String? authId;      // UUID de auth.users
  final String? nombreCompleto;
  final String correoOTelefono;
  final bool aceptoPolitica;
  final String fechaRegistro;

  Usuario({
    this.id,
    this.authId,
    this.nombreCompleto,
    required this.correoOTelefono,
    required this.aceptoPolitica,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    if (authId != null) 'auth_id': authId,
    'nombre_completo':   nombreCompleto,
    'correo_o_telefono': correoOTelefono,
    'acepto_politica':   aceptoPolitica,
    'fecha_registro':    fechaRegistro,
  };

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
    id:               map['id'] as int?,
    authId:           map['auth_id'] as String?,
    nombreCompleto:   map['nombre_completo'] as String?,
    correoOTelefono:  map['correo_o_telefono'] as String? ?? '',
    aceptoPolitica:   map['acepto_politica'] == true || map['acepto_politica'] == 1,
    fechaRegistro:    map['fecha_registro'] as String? ?? '',
  );
}
