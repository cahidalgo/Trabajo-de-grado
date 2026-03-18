import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/vacante.dart';
import '../../data/repositories/vacante_repository.dart';
import '../vacantes/vacante_detalle_screen.dart';

class GuardadasScreen extends StatefulWidget {
  final VoidCallback? onIrAVacantes;
  const GuardadasScreen({super.key, this.onIrAVacantes});

  @override
  State<GuardadasScreen> createState() => _GuardadasScreenState();
}

class _GuardadasScreenState extends State<GuardadasScreen> with AutomaticKeepAliveClientMixin {
  final _repo   = VacanteRepository();
  List<Vacante> _guardadas = [];
  bool          _cargando  = true;
  int?          _usuarioId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final prefs = await SharedPreferences.getInstance();
    _usuarioId  = prefs.getInt('usuarioId');
    if (_usuarioId != null) {
      _guardadas = await _repo.obtenerGuardadas(_usuarioId!);
    }
    setState(() => _cargando = false);
  }

  Future<void> _quitarGuardada(Vacante vacante) async {
    if (_usuarioId == null) return;
    await _repo.quitarGuardada(_usuarioId!, vacante.id!);
    if (!mounted) return;
    setState(() => _guardadas.removeWhere((v) => v.id == vacante.id));
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
              ? _EstadoVacio(
                  // ← usa el callback directo, sin DefaultTabController
                  onExplorar: widget.onIrAVacantes ?? () {},
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _guardadas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _TarjetaGuardada(
                      vacante: _guardadas[i],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VacanteDetalleScreen(vacanteId: _guardadas[i].id!),
                          ),
                        );
                        _cargar();
                      },
                      onQuitar: () => _quitarGuardada(_guardadas[i]),
                    ),
                  ),
                ),
    );
  }
}

// ── Estado vacío ──────────────────────────────────────────────────────────
class _EstadoVacio extends StatelessWidget {
  final VoidCallback onExplorar;
  const _EstadoVacio({required this.onExplorar});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.bookmark_border, size: 52, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text('No tienes vacantes guardadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          const Text(
            'Toca el ícono 🔖 en cualquier vacante para guardarla y consultarla sin conexión.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onExplorar,   // ← callback directo
            icon: const Icon(Icons.search),
            label: const Text('Explorar vacantes'),
          ),
        ],
      ),
    ),
  );
}

// ── Tarjeta de vacante guardada ───────────────────────────────────────────
class _TarjetaGuardada extends StatelessWidget {
  final Vacante      vacante;
  final VoidCallback onTap;
  final VoidCallback onQuitar;
  const _TarjetaGuardada({required this.vacante, required this.onTap, required this.onQuitar});

  static const _coloresCat = {
    'ventas':       [Color(0xFFE3F2FD), Color(0xFF1565C0)],
    'gastronomía':  [Color(0xFFFFF3E0), Color(0xFFE65100)],
    'logística':    [Color(0xFFE8F5E9), Color(0xFF2E7D32)],
    'servicios':    [Color(0xFFF3E5F5), Color(0xFF6A1B9A)],
    'construcción': [Color(0xFFFBE9E7), Color(0xFFBF360C)],
  };
  static const _iconosCat = {
    'ventas':       Icons.storefront_outlined,
    'gastronomía':  Icons.restaurant_outlined,
    'logística':    Icons.local_shipping_outlined,
    'servicios':    Icons.support_agent_outlined,
    'construcción': Icons.construction_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final cat     = vacante.categoria?.toLowerCase() ?? '';
    final colores  = _coloresCat[cat] ?? [const Color(0xFFF5F5F5), AppColors.primary];
    final icono    = _iconosCat[cat] ?? Icons.work_outline;
    final acColor  = colores[1] as Color;

    return Dismissible(
      key: Key('guardada_${vacante.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
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
        borderRadius: BorderRadius.circular(14),
        elevation: 2,
        shadowColor: acColor.withOpacity(0.15),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 6, height: 90,
                  decoration: BoxDecoration(
                    color: acColor,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: acColor.withOpacity(0.1),
                    child: Icon(icono, color: acColor, size: 22),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vacante.titulo,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(vacante.empresa ?? '',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (vacante.modalidad != null)
                              _MiniChip(vacante.modalidad!, acColor),
                            const SizedBox(width: 6),
                            if (vacante.salarioReferencial != null)
                              _MiniChip(vacante.salarioReferencial!, Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_remove_outlined),
                  color: const Color(0xFFBDBDBD),
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

class _MiniChip extends StatelessWidget {
  final String label;
  final Color  color;
  const _MiniChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
  );
}
