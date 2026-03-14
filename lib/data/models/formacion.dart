class Formacion {
  final int? id;
  final String titulo;
  final String? entidad;
  final String? modalidad;
  final String? duracion;
  final String? categoria;
  final String? descripcion;

  Formacion({
    this.id,
    required this.titulo,
    this.entidad,
    this.modalidad,
    this.duracion,
    this.categoria,
    this.descripcion,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'entidad': entidad,
    'modalidad': modalidad,
    'duracion': duracion,
    'categoria': categoria,
    'descripcion': descripcion,
  };

  factory Formacion.fromMap(Map<String, dynamic> map) => Formacion(
    id: map['id'],
    titulo: map['titulo'],
    entidad: map['entidad'],
    modalidad: map['modalidad'],
    duracion: map['duracion'],
    categoria: map['categoria'],
    descripcion: map['descripcion'],
  );
}
