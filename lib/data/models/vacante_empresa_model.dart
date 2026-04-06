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
  final int? vacanteId;

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
    this.vacanteId,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'empresa_id':                  empresaId,
      'titulo':                      titulo,
      'descripcion':                 descripcion,
      'sector':                      sector,
      'modalidad':                   modalidad,
      'jornada':                     jornada,
      'salario_referencial':         salarioReferencial,
      'fecha_cierre':                fechaCierre,
      'activa':                      activa,
      'acepta_experiencia_informal': aceptaExperienciaInformal,
      'acepta_pep_ppt':              aceptaPepPpt,
      'horario_flexible':            horarioFlexible,
      'zona_portal':                 zonaPortal,
      'incluye_formacion':           incluyeFormacion,
      'fecha_publicacion':           fechaPublicacion,
      'vacante_id':                  vacanteId,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory VacanteEmpresaModel.fromMap(Map<String, dynamic> map) =>
      VacanteEmpresaModel(
        id:                          map['id'] as int?,
        empresaId:                   map['empresa_id'] as int,
        titulo:                      map['titulo'] as String? ?? '',
        descripcion:                 map['descripcion'] as String? ?? '',
        sector:                      map['sector'] as String? ?? '',
        modalidad:                   map['modalidad'] as String? ?? '',
        jornada:                     map['jornada'] as String? ?? '',
        salarioReferencial:          map['salario_referencial'] as String?,
        fechaCierre:                 map['fecha_cierre'] as String? ?? '',
        activa:                      map['activa'] == true || map['activa'] == 1,
        aceptaExperienciaInformal:   map['acepta_experiencia_informal'] == true,
        aceptaPepPpt:                map['acepta_pep_ppt'] == true,
        horarioFlexible:             map['horario_flexible'] == true,
        zonaPortal:                  map['zona_portal'] as String?,
        incluyeFormacion:            map['incluye_formacion'] == true,
        fechaPublicacion:            map['fecha_publicacion'] as String? ?? '',
        vacanteId:                   map['vacante_id'] as int?,
      );
}
