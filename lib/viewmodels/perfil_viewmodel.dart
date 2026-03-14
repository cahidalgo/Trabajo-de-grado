import 'package:flutter/foundation.dart';
import '../data/repositories/perfil_repository.dart';
import '../data/models/perfil.dart';

enum PerfilState { idle, loading, guardado, error }

class PerfilViewModel extends ChangeNotifier {
  final _repo = PerfilRepository();

  PerfilState _state = PerfilState.idle;
  Perfil?     _perfil;
  String?     _errorMsg;

  PerfilState get state    => _state;
  Perfil?     get perfil   => _perfil;
  String?     get errorMsg => _errorMsg;

  Future<void> cargar(int usuarioId) async {
    _state = PerfilState.loading;
    notifyListeners();
    _perfil = await _repo.obtenerPorUsuario(usuarioId);
    _state = PerfilState.idle;
    notifyListeners();
  }

  Future<void> guardar(Perfil perfil) async {
    _state = PerfilState.loading;
    notifyListeners();
    try {
      await _repo.guardar(perfil);
      _perfil = perfil;
      _state = PerfilState.guardado;
    } catch (e) {
      _errorMsg = 'No se pudo guardar el perfil. Intenta de nuevo.';
      _state = PerfilState.error;
    }
    notifyListeners();
  }

  void resetState() {
    _state = PerfilState.idle;
    _errorMsg = null;
    notifyListeners();
  }
}
