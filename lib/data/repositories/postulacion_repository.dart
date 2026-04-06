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
  Future<List<Map<String, dynamic>>> obtenerHistorial(
      int usuarioId) async {
    final data = await _db
        .from('postulaciones')
        .select('id, fecha_postulacion, estado, vacantes(titulo, empresa, categoria, modalidad)')
        .eq('usuario_id', usuarioId)
        .order('fecha_postulacion', ascending: false);

    return (data as List).map((p) {
      final v = p['vacantes'] as Map<String, dynamic>? ?? {};
      return {
        'id':               p['id'],
        'fechaPostulacion': p['fecha_postulacion'] ?? '',
        'estado':           p['estado'] ?? 'Enviada',
        'titulo':           v['titulo'] ?? '',
        'empresa':          v['empresa'] ?? '',
        'categoria':        v['categoria'] ?? '',
        'modalidad':        v['modalidad'] ?? '',
      };
    }).toList();
  }
}
