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
    'id': id,
    'usuarioId': usuarioId,
    'nivelEducativo': nivelEducativo,
    'experienciaLaboral': experienciaLaboral,
    'habilidades': habilidades,
    'areasInteres': areasInteres,
    'modalidadPreferida': modalidadPreferida,
    'jornadaPreferida': jornadaPreferida,
    'perfilCompleto': perfilCompleto ? 1 : 0,
  };

  factory Perfil.fromMap(Map<String, dynamic> map) => Perfil(
    id: map['id'],
    usuarioId: map['usuarioId'],
    nivelEducativo: map['nivelEducativo'],
    experienciaLaboral: map['experienciaLaboral'],
    habilidades: map['habilidades'],
    areasInteres: map['areasInteres'],
    modalidadPreferida: map['modalidadPreferida'],
    jornadaPreferida: map['jornadaPreferida'],
    perfilCompleto: map['perfilCompleto'] == 1,
  );
}
