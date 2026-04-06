import 'package:flutter/foundation.dart';
import '../core/services/supabase_service.dart';
import '../data/repositories/perfil_repository.dart';
import '../data/models/perfil.dart';

enum PerfilState { idle, loading, guardado, error }

class PerfilViewModel extends ChangeNotifier {
  final _repo = PerfilRepository();

  PerfilState _state   = PerfilState.idle;
  Perfil?     _perfil;
  String?     _errorMsg;

  PerfilState get state    => _state;
  Perfil?     get perfil   => _perfil;
  String?     get errorMsg => _errorMsg;

  Future<int?> _getUsuarioId() async {
    final authId = SupabaseService.currentAuthId;
    if (authId == null) return null;
    final data = await SupabaseService.client
        .from('usuarios')
        .select('id')
        .eq('auth_id', authId)
        .maybeSingle();
    return data?['id'] as int?;
  }

  Future<void> cargar(int usuarioId) async {
    _state = PerfilState.loading;
    notifyListeners();
    _perfil = await _repo.obtenerPorUsuario(usuarioId);
    _state  = PerfilState.idle;
    notifyListeners();
  }

  Future<void> cargarDesdeAuth() async {
    final id = await _getUsuarioId();
    if (id != null) await cargar(id);
  }

  Future<void> guardar(Perfil perfil) async {
    _state = PerfilState.loading;
    notifyListeners();
    try {
      await _repo.guardar(perfil);
      _perfil = perfil;
      _state  = PerfilState.guardado;
    } catch (_) {
      _errorMsg = 'No se pudo guardar el perfil. Intenta de nuevo.';
      _state    = PerfilState.error;
    }
    notifyListeners();
  }

  void resetState() {
    _state    = PerfilState.idle;
    _errorMsg = null;
    notifyListeners();
  }
}
