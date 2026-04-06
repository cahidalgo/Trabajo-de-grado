import '../../core/services/supabase_service.dart';
import '../models/vacante_empresa_model.dart';

class VacanteEmpresaRepository {
  final _db = SupabaseService.client;

  // ── Publicar: dual-write atómico ─────────────────────────────
  // Inserta en vacantes_empresa Y crea un espejo en vacantes para
  // que el usuario final la vea en su lista de vacantes.
  Future<int> publicarVacante(VacanteEmpresaModel vacante) async {
    // 1. Obtener nombre de la empresa
    final empData = await _db
        .from('empresas')
        .select('razon_social')
        .eq('id', vacante.empresaId)
        .single();
    final empresaNombre = empData['razon_social'] as String? ?? 'Empresa';

    // 2. Insertar espejo en vacantes
    final vacanteEspejoData = await _db.from('vacantes').insert({
      'titulo':              vacante.titulo,
      'descripcion':         vacante.descripcion,
      'empresa':             empresaNombre,
      'categoria':           vacante.sector,
      'modalidad':           vacante.modalidad,
      'jornada':             vacante.jornada,
      'salario_referencial': vacante.salarioReferencial,
      'fecha_cierre':        vacante.fechaCierre,
      'activa':              vacante.activa,
    }).select('id').single();
    final vacanteEspejoId = vacanteEspejoData['id'] as int;

    // 3. Insertar en vacantes_empresa con referencia al espejo
    final veData = await _db.from('vacantes_empresa').insert({
      ...vacante.toMap(),
      'vacante_id': vacanteEspejoId,
    }).select('id').single();

    return veData['id'] as int;
  }

  Future<List<VacanteEmpresaModel>> obtenerVacantesPorEmpresa(
      int empresaId) async {
    final data = await _db
        .from('vacantes_empresa')
        .select()
        .eq('empresa_id', empresaId)
        .order('fecha_publicacion', ascending: false);
    return (data as List)
        .map((e) => VacanteEmpresaModel.fromMap(e))
        .toList();
  }

  // ── Activar / pausar ──────────────────────────────────────────
  Future<void> pausarVacante(int id) async {
    await _sincronizarActiva(id, false);
  }

  Future<void> activarVacante(int id) async {
    await _sincronizarActiva(id, true);
  }

  Future<void> _sincronizarActiva(int vacanteEmpresaId, bool activa) async {
    await _db
        .from('vacantes_empresa')
        .update({'activa': activa})
        .eq('id', vacanteEmpresaId);

    final veData = await _db
        .from('vacantes_empresa')
        .select('vacante_id')
        .eq('id', vacanteEmpresaId)
        .maybeSingle();

    final vacanteId = veData?['vacante_id'] as int?;
    if (vacanteId != null) {
      await _db
          .from('vacantes')
          .update({'activa': activa})
          .eq('id', vacanteId);
    }
  }

  // ── Eliminar ──────────────────────────────────────────────────
  Future<void> eliminarVacante(int id) async {
    final veData = await _db
        .from('vacantes_empresa')
        .select('vacante_id')
        .eq('id', id)
        .maybeSingle();

    await _db.from('vacantes_empresa').delete().eq('id', id);

    final vacanteId = veData?['vacante_id'] as int?;
    if (vacanteId != null) {
      await _db.from('vacantes').delete().eq('id', vacanteId);
    }
  }

  // ── Actualizar ────────────────────────────────────────────────
  Future<void> actualizarVacante(VacanteEmpresaModel vacante) async {
    final map = vacante.toMap();
    map.remove('id'); // no enviar id en UPDATE
    await _db
        .from('vacantes_empresa')
        .update(map)
        .eq('id', vacante.id!);

    if (vacante.vacanteId != null) {
      await _db.from('vacantes').update({
        'titulo':              vacante.titulo,
        'descripcion':         vacante.descripcion,
        'categoria':           vacante.sector,
        'modalidad':           vacante.modalidad,
        'jornada':             vacante.jornada,
        'salario_referencial': vacante.salarioReferencial,
        'fecha_cierre':        vacante.fechaCierre,
        'activa':              vacante.activa,
      }).eq('id', vacante.vacanteId!);
    }
  }

  // ── Postulantes ───────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> obtenerPostulantesPorVacante(
      int vacanteEmpresaId) async {
    // Obtener el ID espejo
    final veData = await _db
        .from('vacantes_empresa')
        .select('vacante_id')
        .eq('id', vacanteEmpresaId)
        .maybeSingle();
    final vacanteId = veData?['vacante_id'] as int?;
    if (vacanteId == null) return [];

    // Join manual: postulaciones → usuarios → perfiles
    final data = await _db
        .from('postulaciones')
        .select('id, fecha_postulacion, estado, usuarios(id, nombre_completo, correo_o_telefono, perfiles(nivel_educativo, habilidades, experiencia_laboral))')
        .eq('vacante_id', vacanteId)
        .order('fecha_postulacion', ascending: false);

    return (data as List).map((p) {
      final u = p['usuarios'] as Map<String, dynamic>? ?? {};
      final rawPf = u['perfiles'];
      Map<String, dynamic> pf;
      if (rawPf is Map<String, dynamic>) {
        pf = rawPf;
      } else if (rawPf is List && rawPf.isNotEmpty) {
        pf = rawPf.first as Map<String, dynamic>;
      } else {
        pf = {};
      }
      return {
        'postulacion_id':  p['id'],
        'nombre':          u['nombre_completo'] ?? 'Sin nombre',
        'correo_o_celular': u['correo_o_telefono'] ?? '',
        'nivel_educativo': pf['nivel_educativo'] ?? '-',
        'habilidades':     pf['habilidades'] ?? '',
        'experiencia':     pf['experiencia_laboral'] ?? '',
        'fecha_postulacion': p['fecha_postulacion'] ?? '',
        'estado':          p['estado'] ?? 'Enviada',
      };
    }).toList();
  }

  Future<void> actualizarEstadoPostulacion(
      int postulacionId, String estado) async {
    await _db
        .from('postulaciones')
        .update({'estado': estado})
        .eq('id', postulacionId);
  }
}
