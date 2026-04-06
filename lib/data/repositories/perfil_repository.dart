import '../../core/services/supabase_service.dart';
import '../models/perfil.dart';

class PerfilRepository {
  final _db = SupabaseService.client;

  Future<void> guardar(Perfil perfil) async {
    final existe = await _db
        .from('perfiles')
        .select('id')
        .eq('usuario_id', perfil.usuarioId)
        .maybeSingle();

    final map = perfil.toMap();
    map.remove('id'); // nunca enviar id en insert/update

    if (existe == null) {
      await _db.from('perfiles').insert(map);
    } else {
      await _db
          .from('perfiles')
          .update(map)
          .eq('usuario_id', perfil.usuarioId);
    }
  }

  Future<Perfil?> obtenerPorUsuario(int usuarioId) async {
    final data = await _db
        .from('perfiles')
        .select()
        .eq('usuario_id', usuarioId)
        .maybeSingle();
    if (data == null) return null;
    return Perfil.fromMap(data);
  }

  Future<bool> estaCompleto(int usuarioId) async {
    final perfil = await obtenerPorUsuario(usuarioId);
    return perfil?.perfilCompleto ?? false;
  }
}
