class Postulacion {
  final int? id;
  final int usuarioId;
  final int vacanteId;
  final String fechaPostulacion;
  final String estado;

  Postulacion({
    this.id,
    required this.usuarioId,
    required this.vacanteId,
    required this.fechaPostulacion,
    this.estado = 'Enviada',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'usuarioId': usuarioId,
    'vacanteId': vacanteId,
    'fechaPostulacion': fechaPostulacion,
    'estado': estado,
  };

  factory Postulacion.fromMap(Map<String, dynamic> map) => Postulacion(
    id: map['id'],
    usuarioId: map['usuarioId'],
    vacanteId: map['vacanteId'],
    fechaPostulacion: map['fechaPostulacion'],
    estado: map['estado'],
  );
}
