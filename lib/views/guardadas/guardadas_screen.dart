import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/category_style.dart';
import '../../core/widgets/app_ui.dart';
import '../../data/models/vacante.dart';
import '../../data/repositories/vacante_repository.dart';
import '../vacantes/vacante_detalle_screen.dart';

class GuardadasScreen extends StatefulWidget {
  final VoidCallback? onIrAVacantes;

  const GuardadasScreen({super.key, this.onIrAVacantes});

  @override
  State<GuardadasScreen> createState() => _GuardadasScreenState();
}

class _GuardadasScreenState extends State<GuardadasScreen>
    with AutomaticKeepAliveClientMixin {
  final _repo = VacanteRepository();
  List<Vacante> _guardadas = [];
  bool _cargando = true;
  int? _usuarioId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final authId = SupabaseService.currentAuthId;
    if (authId != null) {
      final data = await SupabaseService.client
          .from('usuarios')
          .select('id')
          .eq('auth_id', authId)
          .maybeSingle();
      _usuarioId = data?['id'] as int?;
    }
    if (_usuarioId != null) {
      _guardadas = await _repo.obtenerGuardadas(_usuarioId!);
    }
    if (mounted) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _quitarGuardada(Vacante vacante) async {
    if (_usuarioId == null) return;
    await _repo.quitarGuardada(_usuarioId!, vacante.id!);
    if (!mounted) return;

    setState(() => _guardadas.removeWhere((item) => item.id == vacante.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vacante "${vacante.titulo}" eliminada de guardadas'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () async {
            await _repo.guardar(_usuarioId!, vacante.id!);
            _cargar();
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_cargando ? 'Guardadas' : 'Guardadas (${_guardadas.length})'),
        actions: [
          if (!_cargando)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _cargar,
              tooltip: 'Actualizar',
            ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _guardadas.isEmpty
              ? AppEmptyState(
                  icon: Icons.bookmark_border,
                  title: 'No tienes vacantes guardadas',
                  description:
                      'Guarda oportunidades interesantes para revisarlas luego en un solo lugar.',
                  action: ElevatedButton.icon(
                    onPressed: widget.onIrAVacantes,
                    icon: const Icon(Icons.search),
                    label: const Text('Explorar vacantes'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _guardadas.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      if (index == 0) {
                        return AppInfoBanner(
                          title: 'Tus vacantes favoritas',
                          description:
                              'Mantén a mano las oportunidades que quieres comparar o retomar después.',
                          icon: Icons.bookmark_added_outlined,
                          color: AppColors.primary,
                        );
                      }

                      final vacante = _guardadas[index - 1];
                      return _TarjetaGuardada(
                        vacante: vacante,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  VacanteDetalleScreen(vacanteId: vacante.id!),
                            ),
                          );
                          _cargar();
                        },
                        onQuitar: () => _quitarGuardada(vacante),
                      );
                    },
                  ),
                ),
    );
  }
}

class _TarjetaGuardada extends StatelessWidget {
  final Vacante vacante;
  final VoidCallback onTap;
  final VoidCallback onQuitar;

  const _TarjetaGuardada({
    required this.vacante,
    required this.onTap,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppCategoryStyles.resolve(vacante.categoria);

    return Dismissible(
      key: Key('guardada_${vacante.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_remove, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Quitar', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      onDismissed: (_) => onQuitar(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: AppSurfaceCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: style.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(style.icon, color: style.accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vacante.titulo,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vacante.empresa ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if ((vacante.modalidad ?? '').trim().isNotEmpty)
                            AppTag(
                              label: vacante.modalidad!,
                              color: style.accent,
                            ),
                          if ((vacante.salarioReferencial ?? '').trim().isNotEmpty)
                            AppTag(
                              label: vacante.salarioReferencial!,
                              color: AppColors.success,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.bookmark_remove_outlined,
                    color: AppColors.textDisabled,
                  ),
                  tooltip: 'Quitar de guardadas',
                  onPressed: onQuitar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
