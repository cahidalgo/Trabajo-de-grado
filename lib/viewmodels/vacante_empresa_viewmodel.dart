import 'package:flutter/material.dart';
import '../data/repositories/vacante_empresa_repository.dart';
import '../data/models/vacante_empresa_model.dart';

class VacanteEmpresaViewModel extends ChangeNotifier {
  final VacanteEmpresaRepository _repo = VacanteEmpresaRepository();

  List<VacanteEmpresaModel> vacantes = [];
  List<Map<String, dynamic>> postulantes = [];
  bool cargando = false;
  String? errorMensaje;

  Future<void> cargarVacantes(int empresaId) async {
    cargando = true;
    notifyListeners();
    vacantes = await _repo.obtenerVacantesPorEmpresa(empresaId);
    cargando = false;
    notifyListeners();
  }

  Future<bool> publicar(VacanteEmpresaModel vacante) async {
    cargando = true;
    notifyListeners();
    await _repo.publicarVacante(vacante);
    await cargarVacantes(vacante.empresaId);
    cargando = false;
    notifyListeners();
    return true;
  }

  Future<void> toggleActiva(VacanteEmpresaModel vacante) async {
    if (vacante.activa) {
      await _repo.pausarVacante(vacante.id!);
    } else {
      await _repo.activarVacante(vacante.id!);
    }
    await cargarVacantes(vacante.empresaId);
  }

  Future<void> eliminar(VacanteEmpresaModel vacante) async {
    await _repo.eliminarVacante(vacante.id!);
    await cargarVacantes(vacante.empresaId);
  }

  Future<void> cargarPostulantes(int vacanteId) async {
    cargando = true;
    notifyListeners();
    postulantes = await _repo.obtenerPostulantesPorVacante(vacanteId);
    cargando = false;
    notifyListeners();
  }
}
