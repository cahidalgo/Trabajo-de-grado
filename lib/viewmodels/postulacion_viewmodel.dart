import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/postulacion_repository.dart';

enum PostulacionState { idle, loading, exitosa, yaPostulado, error }

class PostulacionViewModel extends ChangeNotifier {
  final _repo = PostulacionRepository();

  PostulacionState          _state    = PostulacionState.idle;
  List<Map<String, dynamic>> _historial = [];
  String?                   _errorMsg;

  PostulacionState           get state     => _state;
  List<Map<String, dynamic>> get historial => _historial;
  String?                    get errorMsg  => _errorMsg;

  Future<int?> _getUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('usuarioId');
  }

  Future<bool> verificarYaPostulado(int vacanteId) async {
    final usuarioId = await _getUsuarioId();
    if (usuarioId == null) return false;
    return _repo.yaSePostulo(usuarioId, vacanteId);
  }

  Future<void> postular(int vacanteId) async {
    _state = PostulacionState.loading;
    notifyListeners();

    final usuarioId = await _getUsuarioId();
    if (usuarioId == null) {
      _errorMsg = 'Debes iniciar sesión para postularte.';
      _state    = PostulacionState.error;
      notifyListeners();
      return;
    }

    try {
      final yaPostulado = await _repo.yaSePostulo(usuarioId, vacanteId);
      if (yaPostulado) {
        _state = PostulacionState.yaPostulado;
        notifyListeners();
        return;
      }
      await _repo.registrar(usuarioId, vacanteId);
      _state = PostulacionState.exitosa;
    } catch (e) {
      _errorMsg = 'No se pudo registrar la postulación. Intenta de nuevo.';
      _state    = PostulacionState.error;
    }
    notifyListeners();
  }

  Future<void> cargarHistorial() async {
    _state = PostulacionState.loading;
    notifyListeners();

    final usuarioId = await _getUsuarioId();
    if (usuarioId == null) {
      _historial = [];
      _state     = PostulacionState.idle;
      notifyListeners();
      return;
    }
    _historial = await _repo.obtenerHistorial(usuarioId);
    _state     = PostulacionState.idle;
    notifyListeners();
  }

  void resetState() {
    _state    = PostulacionState.idle;
    _errorMsg = null;
    notifyListeners();
  }
}
