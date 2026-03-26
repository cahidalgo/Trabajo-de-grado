class VacanteEmpresaModel {
  final int? id;
  final int empresaId;
  final String titulo;
  final String descripcion;
  final String sector;
  final String modalidad;
  final String jornada;
  final String? salarioReferencial;
  final String fechaCierre;
  final bool activa;
  final bool aceptaExperienciaInformal;
  final bool aceptaPepPpt;
  final bool horarioFlexible;
  final String? zonaPortal;
  final bool incluyeFormacion;
  final String fechaPublicacion;

  VacanteEmpresaModel({
    this.id,
    required this.empresaId,
    required this.titulo,
    required this.descripcion,
    required this.sector,
    required this.modalidad,
    required this.jornada,
    this.salarioReferencial,
    required this.fechaCierre,
    this.activa = true,
    this.aceptaExperienciaInformal = false,
    this.aceptaPepPpt = false,
    this.horarioFlexible = false,
    this.zonaPortal,
    this.incluyeFormacion = false,
    required this.fechaPublicacion,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'empresa_id': empresaId,
    'titulo': titulo,
    'descripcion': descripcion,
    'sector': sector,
    'modalidad': modalidad,
    'jornada': jornada,
    'salario_referencial': salarioReferencial,
    'fecha_cierre': fechaCierre,
    'activa': activa ? 1 : 0,
    'acepta_experiencia_informal': aceptaExperienciaInformal ? 1 : 0,
    'acepta_pep_ppt': aceptaPepPpt ? 1 : 0,
    'horario_flexible': horarioFlexible ? 1 : 0,
    'zona_portal': zonaPortal,
    'incluye_formacion': incluyeFormacion ? 1 : 0,
    'fecha_publicacion': fechaPublicacion,
  };

  factory VacanteEmpresaModel.fromMap(Map<String, dynamic> map) =>
      VacanteEmpresaModel(
        id: map['id'],
        empresaId: map['empresa_id'],
        titulo: map['titulo'],
        descripcion: map['descripcion'],
        sector: map['sector'],
        modalidad: map['modalidad'],
        jornada: map['jornada'],
        salarioReferencial: map['salario_referencial'],
        fechaCierre: map['fecha_cierre'],
        activa: map['activa'] == 1,
        aceptaExperienciaInformal: map['acepta_experiencia_informal'] == 1,
        aceptaPepPpt: map['acepta_pep_ppt'] == 1,
        horarioFlexible: map['horario_flexible'] == 1,
        zonaPortal: map['zona_portal'],
        incluyeFormacion: map['incluye_formacion'] == 1,
        fechaPublicacion: map['fecha_publicacion'],
      );
}
