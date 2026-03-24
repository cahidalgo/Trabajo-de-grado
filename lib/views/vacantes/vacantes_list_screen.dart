import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/vacante.dart';
import '../../data/repositories/vacante_repository.dart';
import 'vacante_detalle_screen.dart';

class VacantesListScreen extends StatefulWidget {
  const VacantesListScreen({super.key});

  @override
  State<VacantesListScreen> createState() => _VacantesListScreenState();
}

class _VacantesListScreenState extends State<VacantesListScreen> {
  final _repo = VacanteRepository();
  List<Vacante> _vacantes = [];
  bool _cargando = true;
  String? _filtroCategoria;
  String? _filtroModalidad;

  static const _categorias = ['ventas', 'gastronomía', 'logística', 'servicios'];
  static const _modalidades = ['presencial', 'virtual', 'híbrida'];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    _vacantes = await _repo.obtenerTodas(
      categoria: _filtroCategoria,
      modalidad: _filtroModalidad,
    );
    setState(() => _cargando = false);
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrar vacantes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('Categoría', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categorias.map((c) => FilterChip(
                  label: Text(c),
                  selected: _filtroCategoria == c,
                  onSelected: (v) {
                    setModalState(() => _filtroCategoria = v ? c : null);
                    setState(() {});
                  },
                )).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Modalidad', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _modalidades.map((m) => FilterChip(
                  label: Text(m),
                  selected: _filtroModalidad == m,
                  onSelected: (v) {
                    setModalState(() => _filtroModalidad = v ? m : null);
                    setState(() {});
                  },
                )).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _filtroCategoria = null;
                          _filtroModalidad = null;
                        });
                        Navigator.pop(context);
                        _cargar();
                      },
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _cargar();
                      },
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hayFiltros = _filtroCategoria != null || _filtroModalidad != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacantes disponibles'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: _mostrarFiltros,
                tooltip: 'Filtros',
              ),
              if (hayFiltros)
                const Positioned(
                  right: 10,
                  top: 10,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: AppColors.warning,
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _vacantes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay vacantes disponibles',
                        style: TextStyle(fontSize: 16),
                      ),
                      if (hayFiltros) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _filtroCategoria = null;
                              _filtroModalidad = null;
                            });
                            _cargar();
                          },
                          child: const Text('Limpiar filtros'),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: _vacantes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _TarjetaVacante(
                      vacante: _vacantes[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VacanteDetalleScreen(vacanteId: _vacantes[i].id!),
                        ),
                      ).then((_) => _cargar()),
                    ),
                  ),
                ),
    );
  }
}

class _TarjetaVacante extends StatelessWidget {
  final Vacante vacante;
  final VoidCallback onTap;
  const _TarjetaVacante({required this.vacante, required this.onTap});

  static const _coloresCat = {
    'ventas':       Color(0xFF1565C0),
    'gastronomía':  Color(0xFFE65100),
    'logística':    Color(0xFF2E7D32),
    'servicios':    Color(0xFF6A1B9A),
    'construcción': Color(0xFFBF360C),
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
    final cat = vacante.categoria?.toLowerCase() ?? '';
    final acColor = _coloresCat[cat] ?? AppColors.primary;
    final icono = _iconosCat[cat] ?? Icons.work_outline;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: acColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: acColor.withOpacity(0.1),
                          child: Icon(icono, color: acColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vacante.titulo,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vacante.empresa ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (vacante.modalidad != null)
                                    _PillChip(vacante.modalidad!, acColor),
                                  if (vacante.jornada != null)
                                    _PillChip(vacante.jornada!, acColor),
                                  if (vacante.categoria != null)
                                    _PillChip(vacante.categoria!, acColor),
                                ],
                              ),
                              if (vacante.salarioReferencial != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.attach_money, size: 15, color: acColor),
                                    const SizedBox(width: 3),
                                    Text(
                                      vacante.salarioReferencial!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: acColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (vacante.fechaCierre != null)
                                      Text(
                                        'Cierre: ${vacante.fechaCierre}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final Color color;
  const _PillChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
        ),
      );
}