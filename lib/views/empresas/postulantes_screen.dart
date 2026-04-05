import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_ui.dart';
import '../../data/models/vacante_empresa_model.dart';
import '../../viewmodels/vacante_empresa_viewmodel.dart';

class PostulantesScreen extends StatefulWidget {
  final VacanteEmpresaModel vacante;
  const PostulantesScreen({super.key, required this.vacante});

  @override
  State<PostulantesScreen> createState() => _PostulantesScreenState();
}

class _PostulantesScreenState extends State<PostulantesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    context.read<VacanteEmpresaViewModel>().cargarPostulantes(widget.vacante.id!);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VacanteEmpresaViewModel>();

    final todos     = vm.postulantes;
    final enviados  = todos.where((p) => p['estado'] == 'Enviada').toList();
    final vistos    = todos.where((p) => p['estado'] == 'Vista').toList();
    final aceptados = todos.where((p) => p['estado'] == 'Aceptada').toList();
    final rechazados = todos.where((p) => p['estado'] == 'Rechazada').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Postulantes',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              widget.vacante.titulo,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        bottom: todos.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(46),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: TabBar(
                    controller: _tabCtrl,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12),
                    tabs: [
                      Tab(text: 'Todos (${todos.length})'),
                      Tab(text: 'Nuevos (${enviados.length})'),
                      Tab(text: 'Aceptados (${aceptados.length})'),
                      Tab(text: 'Rechazados (${rechazados.length})'),
                    ],
                  ),
                ),
              ),
      ),
      body: vm.cargando
          ? const Center(child: CircularProgressIndicator())
          : todos.isEmpty
              ? AppEmptyState(
                  icon: Icons.people_outline,
                  title: 'Aún no hay postulantes',
                  description:
                      'Cuando alguien se postule a "${widget.vacante.titulo}", aparecerá aquí.',
                )
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _ListaPostulantes(
                        postulantes: todos, vacante: widget.vacante),
                    _ListaPostulantes(
                        postulantes: enviados, vacante: widget.vacante,
                        emptyMsg: 'No hay postulaciones nuevas sin revisar.'),
                    _ListaPostulantes(
                        postulantes: aceptados, vacante: widget.vacante,
                        emptyMsg: 'Aún no has aceptado a ningún candidato.'),
                    _ListaPostulantes(
                        postulantes: rechazados, vacante: widget.vacante,
                        emptyMsg: 'No hay candidatos rechazados.'),
                  ],
                ),
    );
  }
}

// ── Lista ─────────────────────────────────────────────────────
class _ListaPostulantes extends StatelessWidget {
  final List<Map<String, dynamic>> postulantes;
  final VacanteEmpresaModel vacante;
  final String emptyMsg;

  const _ListaPostulantes({
    required this.postulantes,
    required this.vacante,
    this.emptyMsg = 'No hay candidatos en esta categoría.',
  });

  @override
  Widget build(BuildContext context) {
    if (postulantes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(emptyMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: postulantes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _TarjetaPostulante(
        postulante: postulantes[i],
        vacante: vacante,
      ),
    );
  }
}

// ── Tarjeta individual ────────────────────────────────────────
class _TarjetaPostulante extends StatelessWidget {
  final Map<String, dynamic> postulante;
  final VacanteEmpresaModel vacante;

  const _TarjetaPostulante(
      {required this.postulante, required this.vacante});

  String get _estado => postulante['estado'] as String? ?? 'Enviada';
  int get _postulacionId => postulante['postulacion_id'] as int;

  Color get _colorEstado {
    switch (_estado) {
      case 'Aceptada':  return AppColors.success;
      case 'Rechazada': return AppColors.error;
      case 'Vista':     return AppColors.warning;
      default:          return AppColors.primary;
    }
  }

  IconData get _iconoEstado {
    switch (_estado) {
      case 'Aceptada':  return Icons.check_circle_rounded;
      case 'Rechazada': return Icons.cancel_rounded;
      case 'Vista':     return Icons.visibility_rounded;
      default:          return Icons.send_rounded;
    }
  }

  String _formatFecha(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _cambiarEstado(
      BuildContext context, String nuevoEstado) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          nuevoEstado == 'Aceptada'
              ? '¿Aceptar candidato?'
              : '¿Rechazar candidato?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          nuevoEstado == 'Aceptada'
              ? '${postulante['nombre'] ?? 'Este candidato'} será notificado de que su postulación fue aceptada.'
              : '${postulante['nombre'] ?? 'Este candidato'} será notificado de que su postulación no avanzó.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: nuevoEstado == 'Aceptada'
                  ? AppColors.success
                  : AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(nuevoEstado == 'Aceptada' ? 'Aceptar' : 'Rechazar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      await context.read<VacanteEmpresaViewModel>()
          .actualizarEstadoPostulante(_postulacionId, nuevoEstado, vacante.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nuevoEstado == 'Aceptada'
                ? '✅ Candidato aceptado'
                : '❌ Candidato rechazado'),
            backgroundColor: nuevoEstado == 'Aceptada'
                ? AppColors.success
                : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre  = postulante['nombre'] as String? ?? 'Sin nombre';
    final contacto = postulante['correo_o_celular'] as String? ?? '';
    final nivel   = postulante['nivel_educativo'] as String? ?? '-';
    final exp     = postulante['experiencia'] as String? ?? '';
    final habs    = postulante['habilidades'] as String? ?? '';
    final fecha   = _formatFecha(
        postulante['fecha_postulacion'] as String? ?? '');
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    final bool yaDecidido =
        _estado == 'Aceptada' || _estado == 'Rechazada';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: yaDecidido
              ? _colorEstado.withOpacity(0.3)
              : AppColors.border,
          width: yaDecidido ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabecera ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.alternate_email,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              contacto,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Badge estado
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _colorEstado.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_iconoEstado,
                          size: 12, color: _colorEstado),
                      const SizedBox(width: 4),
                      Text(
                        _estado,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _colorEstado,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Datos del candidato ───────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DatoRow(
                  icono: Icons.school_outlined,
                  label: 'Educación',
                  valor: nivel,
                ),
                if (exp.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _DatoRow(
                    icono: Icons.work_history_outlined,
                    label: 'Experiencia',
                    valor: exp,
                    maxLines: 2,
                  ),
                ],
                if (habs.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _DatoRow(
                    icono: Icons.auto_awesome_outlined,
                    label: 'Habilidades',
                    valor: habs,
                    maxLines: 2,
                  ),
                ],
                const SizedBox(height: 6),
                _DatoRow(
                  icono: Icons.calendar_today_outlined,
                  label: 'Postuló el',
                  valor: fecha,
                ),
              ],
            ),
          ),

          // ── Acciones ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: yaDecidido
                ? _BannerDecision(estado: _estado)
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _cambiarEstado(context, 'Rechazada'),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Rechazar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(
                                color: AppColors.error.withOpacity(0.4)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _cambiarEstado(context, 'Aceptada'),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Aceptar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Banner cuando ya se tomó decisión ────────────────────────
class _BannerDecision extends StatelessWidget {
  final String estado;
  const _BannerDecision({required this.estado});

  @override
  Widget build(BuildContext context) {
    final aceptado = estado == 'Aceptada';
    final color = aceptado ? AppColors.success : AppColors.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(
            aceptado
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            aceptado
                ? 'Candidato aceptado — ya fue notificado'
                : 'Candidato rechazado — ya fue notificado',
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fila de dato ──────────────────────────────────────────────
class _DatoRow extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final int maxLines;

  const _DatoRow({
    required this.icono,
    required this.label,
    required this.valor,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 14, color: AppColors.primary.withOpacity(0.6)),
        const SizedBox(width: 7),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
