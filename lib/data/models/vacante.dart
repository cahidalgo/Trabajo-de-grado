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
    if (id != null) 'id': id,
    'titulo':              titulo,
    'descripcion':         descripcion,
    'empresa':             empresa,
    'categoria':           categoria,
    'modalidad':           modalidad,
    'jornada':             jornada,
    'salario_referencial': salarioReferencial,
    'requisitos':          requisitos,
    'fecha_cierre':        fechaCierre,
    'activa':              activa,
  };

  factory Vacante.fromMap(Map<String, dynamic> map) => Vacante(
    id:                  map['id'] as int?,
    titulo:              map['titulo'] as String? ?? '',
    descripcion:         map['descripcion'] as String?,
    empresa:             map['empresa'] as String?,
    categoria:           map['categoria'] as String?,
    modalidad:           map['modalidad'] as String?,
    jornada:             map['jornada'] as String?,
    salarioReferencial:  map['salario_referencial'] as String?,
    requisitos:          map['requisitos'] as String?,
    fechaCierre:         map['fecha_cierre'] as String?,
    activa:              map['activa'] == true || map['activa'] == 1,
  );
}
