import 'package:flutter/material.dart';
import '../data/repositories/admin_repository.dart';
import '../data/models/empresa_model.dart';

class AdminViewModel extends ChangeNotifier {
  final _repo = AdminRepository();

  int totalUsuarios = 0;
  int totalEmpresas = 0;
  int empresasPendientes = 0;
  int totalVacantes = 0;
  int vacantesActivas = 0;
  int totalPostulaciones = 0;

  List<EmpresaModel> empresas = [];
  List<Map<String, dynamic>> usuarios = [];
  List<Map<String, dynamic>> vacantes = [];

  bool cargando = false;
  String? errorMsg;

  Future<void> cargarTodo() async {
    cargando = true;
    errorMsg = null;
    notifyListeners();
    try {
      await Future.wait([
        _cargarStats(),
        _cargarEmpresas(),
        _cargarUsuarios(),
        _cargarVacantes(),
      ]);
    } catch (e) {
      errorMsg = 'Error al cargar datos: $e';
    }
    cargando = false;
    notifyListeners();
  }

  Future<void> _cargarStats() async {
    try {
      final s = await _repo.obtenerEstadisticas();
      totalUsuarios = s['usuarios']!;
      totalEmpresas = s['empresas']!;
      empresasPendientes = s['empresasPendientes']!;
      totalVacantes = s['totalVacantes']!;
      vacantesActivas = s['vacantesActivas']!;
      totalPostulaciones = s['postulaciones']!;
    } catch (_) {}
  }

  Future<void> _cargarEmpresas() async {
    empresas = await _repo.listarEmpresas();
  }

  Future<void> _cargarUsuarios() async {
    usuarios = await _repo.listarUsuarios();
  }

  Future<void> _cargarVacantes() async {
    vacantes = await _repo.listarVacantesConEmpresa();
  }

  /// Retorna true si la validación fue exitosa
  Future<bool> validarEmpresa(int id) async {
    try {
      await _repo.validarEmpresa(id);
      await Future.wait([_cargarEmpresas(), _cargarStats()]);
      notifyListeners();
      // Verificar que realmente se validó
      final empresa = empresas.where((e) => e.id == id).firstOrNull;
      if (empresa != null && !empresa.validado) {
        errorMsg = 'No se pudo validar la empresa. Verifica los permisos '
            'RLS en Supabase para la tabla "empresas".';
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      errorMsg = 'Error al validar empresa: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> revocarEmpresa(int id) async {
    try {
      await _repo.revocarEmpresa(id);
      await Future.wait([_cargarEmpresas(), _cargarStats()]);
      notifyListeners();
      return true;
    } catch (e) {
      errorMsg = 'Error al revocar empresa: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleVacante(int id, bool estaActiva) async {
    if (estaActiva) {
      await _repo.desactivarVacante(id);
    } else {
      await _repo.activarVacante(id);
    }
    await Future.wait([_cargarVacantes(), _cargarStats()]);
    notifyListeners();
  }
}