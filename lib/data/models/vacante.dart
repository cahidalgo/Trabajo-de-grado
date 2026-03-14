class Vacante {
  final int? id;
  final String titulo;
  final String? descripcion;
  final String? empresa;
  final String? categoria;
  final String? modalidad;
  final String? jornada;
  final String? salarioReferencial;
  final String? requisitos;
  final String? fechaCierre;
  final bool activa;

  Vacante({
    this.id,
    required this.titulo,
    this.descripcion,
    this.empresa,
    this.categoria,
    this.modalidad,
    this.jornada,
    this.salarioReferencial,
    this.requisitos,
    this.fechaCierre,
    this.activa = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'empresa': empresa,
    'categoria': categoria,
    'modalidad': modalidad,
    'jornada': jornada,
    'salarioReferencial': salarioReferencial,
    'requisitos': requisitos,
    'fechaCierre': fechaCierre,
    'activa': activa ? 1 : 0,
  };

  factory Vacante.fromMap(Map<String, dynamic> map) => Vacante(
    id: map['id'],
    titulo: map['titulo'],
    descripcion: map['descripcion'],
    empresa: map['empresa'],
    categoria: map['categoria'],
    modalidad: map['modalidad'],
    jornada: map['jornada'],
    salarioReferencial: map['salarioReferencial'],
    requisitos: map['requisitos'],
    fechaCierre: map['fechaCierre'],
    activa: map['activa'] == 1,
  );
}
