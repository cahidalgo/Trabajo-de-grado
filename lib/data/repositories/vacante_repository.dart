import '../../core/services/supabase_service.dart';
import '../models/vacante.dart';

class VacanteRepository {
  final _db = SupabaseService.client;

  Future<List<Vacante>> obtenerTodas({
    List<String>? categorias,
    List<String>? modalidades,
    List<String>? jornadas,
  }) async {
    var query = _db
        .from('vacantes')
        .select()
        .eq('activa', true);

    // Supabase no tiene IN con lista dinámica en el builder fluido,
    // usamos filter con 'in' para listas no vacías.
    if (categorias != null && categorias.isNotEmpty) {
      query = query.inFilter('categoria', categorias);
    }
    if (modalidades != null && modalidades.isNotEmpty) {
      query = query.inFilter('modalidad', modalidades);
    }
    if (jornadas != null && jornadas.isNotEmpty) {
      query = query.inFilter('jornada', jornadas);
    }

    final data = await query.order('fecha_cierre', ascending: true);
    return (data as List).map((e) => Vacante.fromMap(e)).toList();
  }

  Future<Vacante?> obtenerPorId(int id) async {
    final data = await _db
        .from('vacantes')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return Vacante.fromMap(data);
  }

  // ── Guardadas ─────────────────────────────────────────────────
  Future<bool> estaGuardada(int usuarioId, int vacanteId) async {
    final data = await _db
        .from('vacantes_guardadas')
        .select('id')
        .eq('usuario_id', usuarioId)
        .eq('vacante_id', vacanteId)
        .maybeSingle();
    return data != null;
  }

  Future<void> guardar(int usuarioId, int vacanteId) async {
    await _db.from('vacantes_guardadas').insert({
      'usuario_id': usuarioId,
      'vacante_id': vacanteId,
    });
  }

  Future<void> quitarGuardada(int usuarioId, int vacanteId) async {
    await _db
        .from('vacantes_guardadas')
        .delete()
        .eq('usuario_id', usuarioId)
        .eq('vacante_id', vacanteId);
  }

  Future<List<Vacante>> obtenerGuardadas(int usuarioId) async {
    final data = await _db
        .from('vacantes_guardadas')
        .select('vacantes(*)')
        .eq('usuario_id', usuarioId)
        .order('fecha_guardado', ascending: false);

    return (data as List)
        .map((e) => Vacante.fromMap(e['vacantes'] as Map<String, dynamic>))
        .toList();
  }
}
