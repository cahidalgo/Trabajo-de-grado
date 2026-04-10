class Formacion {
  final int? id;
  final String titulo;
  final String? entidad;
  final String? modalidad;
  final String? duracion;
  final String? categoria;
  final String? descripcion;
  final String? url;
  final String? imagenUrl;
  final String tipo; // 'curso' | 'video'
  final bool gratuito;

  Formacion({
    this.id,
    required this.titulo,
    this.entidad,
    this.modalidad,
    this.duracion,
    this.categoria,
    this.descripcion,
    this.url,
    this.imagenUrl,
    this.tipo = 'curso',
    this.gratuito = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'entidad': entidad,
    'modalidad': modalidad,
    'duracion': duracion,
    'categoria': categoria,
    'descripcion': descripcion,
    'url': url,
    'imagen_url': imagenUrl,
    'tipo': tipo,
    'gratuito': gratuito,
  };

  factory Formacion.fromMap(Map<String, dynamic> map) => Formacion(
    id: map['id'],
    titulo: map['titulo'] ?? '',
    entidad: map['entidad'],
    modalidad: map['modalidad'],
    duracion: map['duracion'],
    categoria: map['categoria'],
    descripcion: map['descripcion'],
    url: map['url'],
    imagenUrl: map['imagen_url'],
    tipo: map['tipo'] ?? 'curso',
    gratuito: map['gratuito'] == true || map['gratuito'] == 1,
  );
}
