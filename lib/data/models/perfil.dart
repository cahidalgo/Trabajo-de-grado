class Perfil {
  final int? id;
  final int usuarioId;
  final String? nivelEducativo;
  final String? experienciaLaboral;
  final String? habilidades;
  final String? areasInteres;
  final String? modalidadPreferida;
  final String? jornadaPreferida;
  final bool perfilCompleto;

  Perfil({
    this.id,
    required this.usuarioId,
    this.nivelEducativo,
    this.experienciaLaboral,
    this.habilidades,
    this.areasInteres,
    this.modalidadPreferida,
    this.jornadaPreferida,
    this.perfilCompleto = false,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'usuario_id':          usuarioId,
    'nivel_educativo':     nivelEducativo,
    'experiencia_laboral': experienciaLaboral,
    'habilidades':         habilidades,
    'areas_interes':       areasInteres,
    'modalidad_preferida': modalidadPreferida,
    'jornada_preferida':   jornadaPreferida,
    'perfil_completo':     perfilCompleto,
  };

  factory Perfil.fromMap(Map<String, dynamic> map) => Perfil(
    id:                 map['id'] as int?,
    usuarioId:          map['usuario_id'] as int,
    nivelEducativo:     map['nivel_educativo'] as String?,
    experienciaLaboral: map['experiencia_laboral'] as String?,
    habilidades:        map['habilidades'] as String?,
    areasInteres:       map['areas_interes'] as String?,
    modalidadPreferida: map['modalidad_preferida'] as String?,
    jornadaPreferida:   map['jornada_preferida'] as String?,
    perfilCompleto:     map['perfil_completo'] == true || map['perfil_completo'] == 1,
  );
}
