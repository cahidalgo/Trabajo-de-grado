import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/empresa_model.dart';

class AdminRepository {
  final _db = SupabaseService.client;

  // ── Estadísticas ──────────────────────────────────────────────
  Future<Map<String, int>> obtenerEstadisticas() async {
    // En supabase_flutter v2, los conteos se obtienen encadenando
    // .count(CountOption.exact) — FetchOptions ya no es un parámetro de select().
    final usuarios = await _db
        .from('usuarios')
        .select()
        .count(CountOption.exact);
    final empresas = await _db
        .from('empresas')
        .select()
        .count(CountOption.exact);
    final empresasPend = await _db
        .from('empresas')
        .select()
        .eq('validado', false)
        .count(CountOption.exact);
    final totalVac = await _db
        .from('vacantes_empresa')
        .select()
        .count(CountOption.exact);
    final vacActivas = await _db
        .from('vacantes_empresa')
        .select()
        .eq('activa', true)
        .count(CountOption.exact);
    final postulaciones = await _db
        .from('postulaciones')
        .select()
        .count(CountOption.exact);

    return {
      'usuarios':           usuarios.count,
      'empresas':           empresas.count,
      'empresasPendientes': empresasPend.count,
      'totalVacantes':      totalVac.count,
      'vacantesActivas':    vacActivas.count,
      'postulaciones':      postulaciones.count,
    };
  }

  // ── Empresas ──────────────────────────────────────────────────
  Future<List<EmpresaModel>> listarEmpresas() async {
    final data = await _db
        .from('empresas')
        .select()
        .order('fecha_registro', ascending: false);
    return data.map(EmpresaModel.fromMap).toList();
  }

  Future<void> validarEmpresa(int id) async {
    await _db.from('empresas').update({'validado': true}).eq('id', id);
  }

  Future<void> revocarEmpresa(int id) async {
    await _db.from('empresas').update({'validado': false}).eq('id', id);
  }

  // ── Usuarios ──────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listarUsuarios() async {
    final data = await _db
        .from('usuarios')
        .select('id, nombre_completo, correo_o_telefono, fecha_registro, perfiles(perfil_completo)')
        .order('fecha_registro', ascending: false);

    return data.map((u) {
      // perfiles puede venir como Map (1:1) o List (1:many)
      final raw = u['perfiles'];
      Map<String, dynamic> pf;
      if (raw is Map<String, dynamic>) {
        pf = raw;
      } else if (raw is List && raw.isNotEmpty) {
        pf = raw.first as Map<String, dynamic>;
      } else {
        pf = {};
      }
      return {
        'id':              u['id'],
        'nombreCompleto':  u['nombre_completo'],
        'correoOTelefono': u['correo_o_telefono'],
        'fechaRegistro':   u['fecha_registro'],
        'perfilCompleto':  pf['perfil_completo'] == true ? 1 : 0,
      };
    }).toList();
  }

  // ── Vacantes ──────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listarVacantesConEmpresa() async {
    final data = await _db
        .from('vacantes_empresa')
        .select('id, titulo, sector, modalidad, jornada, activa, fecha_publicacion, fecha_cierre, empresas(razon_social)')
        .order('fecha_publicacion', ascending: false);

    return data.map((v) {
      final raw = v['empresas'];
      Map<String, dynamic> e;
      if (raw is Map<String, dynamic>) {
        e = raw;
      } else if (raw is List && raw.isNotEmpty) {
        e = raw.first as Map<String, dynamic>;
      } else {
        e = {};
      }
      return {
        'id':                v['id'],
        'titulo':            v['titulo'],
        'sector':            v['sector'],
        'modalidad':         v['modalidad'],
        'jornada':           v['jornada'],
        'activa':            v['activa'] == true ? 1 : 0,
        'fecha_publicacion': v['fecha_publicacion'],
        'fecha_cierre':      v['fecha_cierre'],
        'empresa_nombre':    e['razon_social'],
      };
    }).toList();
  }

  Future<void> desactivarVacante(int id) async {
    await _db.from('vacantes_empresa').update({'activa': false}).eq('id', id);
    await _sincronizarActivaVacante(id, false);
  }

  Future<void> activarVacante(int id) async {
    await _db.from('vacantes_empresa').update({'activa': true}).eq('id', id);
    await _sincronizarActivaVacante(id, true);
  }

  Future<void> _sincronizarActivaVacante(int veId, bool activa) async {
    final data = await _db
        .from('vacantes_empresa')
        .select('vacante_id')
        .eq('id', veId)
        .maybeSingle();
    final vacanteId = data?['vacante_id'] as int?;
    if (vacanteId != null) {
      await _db.from('vacantes').update({'activa': activa}).eq('id', vacanteId);
    }
  }
}