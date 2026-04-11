import '../../core/services/supabase_service.dart';

class PostulacionRepository {
  final _db = SupabaseService.client;

  Future<bool> yaSePostulo(int usuarioId, int vacanteId) async {
    final data = await _db
        .from('postulaciones')
        .select('id')
        .eq('usuario_id', usuarioId)
        .eq('vacante_id', vacanteId)
        .maybeSingle();
    return data != null;
  }

  Future<void> registrar(int usuarioId, int vacanteId) async {
    await _db.from('postulaciones').insert({
      'usuario_id': usuarioId,
      'vacante_id': vacanteId,
      'estado':     'Enviada',
    });
  }

  // Historial con JOIN a vacantes para título, empresa, categoría
  // Si el estado es 'Aceptada', también trae correo y teléfono de la empresa
  Future<List<Map<String, dynamic>>> obtenerHistorial(
      int usuarioId) async {
    final data = await _db
        .from('postulaciones')
        .select(
            'id, vacante_id, fecha_postulacion, estado, '
            'vacantes(titulo, empresa, categoria, modalidad)')
        .eq('usuario_id', usuarioId)
        .order('fecha_postulacion', ascending: false);

    final lista = (data as List).map((p) {
      final v = p['vacantes'] as Map<String, dynamic>? ?? {};
      return <String, dynamic>{
        'id':               p['id'],
        'vacante_id':       p['vacante_id'],
        'fechaPostulacion': p['fecha_postulacion'] ?? '',
        'estado':           p['estado'] ?? 'Enviada',
        'titulo':           v['titulo'] ?? '',
        'empresa':          v['empresa'] ?? '',
        'categoria':        v['categoria'] ?? '',
        'modalidad':        v['modalidad'] ?? '',
        'empresa_correo':   null,
        'empresa_telefono': null,
      };
    }).toList();

    // Para postulaciones Aceptadas: traer datos de contacto de la empresa
    // Ruta: postulaciones.vacante_id → vacantes_empresa.vacante_id → empresas
    final vacanteIds = lista
        .where((p) => p['estado'] == 'Aceptada')
        .map((p) => p['vacante_id'] as int?)
        .whereType<int>()
        .toSet()
        .toList();

    if (vacanteIds.isNotEmpty) {
      final contactos = await _db
          .from('vacantes_empresa')
          .select('vacante_id, empresas(correo, telefono)')
          .inFilter('vacante_id', vacanteIds);

      final mapaContacto = <int, Map<String, dynamic>>{};
      for (final ve in contactos as List) {
        final vid = ve['vacante_id'] as int?;
        final e   = ve['empresas'] as Map<String, dynamic>?;
        if (vid != null && e != null) mapaContacto[vid] = e;
      }

      return lista.map((p) {
        final vid = p['vacante_id'] as int?;
        if (vid != null && mapaContacto.containsKey(vid)) {
          final e = mapaContacto[vid]!;
          return <String, dynamic>{
            ...p,
            'empresa_correo':   e['correo'],
            'empresa_telefono': e['telefono'],
          };
        }
        return p;
      }).toList();
    }

    return lista;
  }
}
