import '../../core/services/supabase_service.dart';
import '../models/formacion.dart';

class FormacionRepository {
  final _db = SupabaseService.client;

  Future<List<Formacion>> obtenerTodas({String? categoria}) async {
    var query = _db.from('formacion').select();

    if (categoria != null) {
      query = query.eq('categoria', categoria);
    }

    final data = await query.order('titulo', ascending: true);
    return (data as List).map((e) => Formacion.fromMap(e)).toList();
  }
}
