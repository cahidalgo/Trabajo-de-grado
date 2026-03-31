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

  Future<void> cargarTodo() async {
    cargando = true;
    notifyListeners();
    await Future.wait([
      _cargarStats(),
      _cargarEmpresas(),
      _cargarUsuarios(),
      _cargarVacantes(),
    ]);
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

  Future<void> validarEmpresa(int id) async {
    await _repo.validarEmpresa(id);
    await Future.wait([_cargarEmpresas(), _cargarStats()]);
    notifyListeners();
  }

  Future<void> revocarEmpresa(int id) async {
    await _repo.revocarEmpresa(id);
    await Future.wait([_cargarEmpresas(), _cargarStats()]);
    notifyListeners();
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