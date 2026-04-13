import 'dart:async';
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
  final _repo           = VacanteRepository();
  final _searchCtrl     = TextEditingController();
  final _searchFocus    = FocusNode();
  Timer? _debounce;

  List<Vacante> _vacantes = [];
  bool _cargando          = true;
  String _busqueda        = '';

  final List<String> _filtrosCategorias = [];
  final List<String> _filtrosModalidades = [];

  static const _categorias = [
    'ventas', 'gastronomía', 'logística', 'servicios', 'construcción'
  ];
  static const _modalidades = ['presencial', 'virtual', 'híbrida'];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    _vacantes = await _repo.obtenerTodas(
      busqueda:   _busqueda.isEmpty ? null : _busqueda,
      categorias: _filtrosCategorias.isEmpty ? null : _filtrosCategorias,
      modalidades: _filtrosModalidades.isEmpty ? null : _filtrosModalidades,
    );
    setState(() => _cargando = false);
  }

  void _onBusquedaChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _busqueda = value.trim());
      _cargar();
    });
  }

  void _limpiarBusqueda() {
    _searchCtrl.clear();
    setState(() => _busqueda = '');
    _cargar();
  }

  bool get _hayFiltros =>
      _filtrosCategorias.isNotEmpty || _filtrosModalidades.isNotEmpty;

  int get _totalFiltrosActivos =>
      _filtrosCategorias.length + _filtrosModalidades.length;

  void _limpiarTodo() {
    setState(() {
      _filtrosCategorias.clear();
      _filtrosModalidades.clear();
    });
    _cargar();
  }

  void _mostrarFiltros() {
    final tempCategorias = List<String>.from(_filtrosCategorias);
    final tempModalidades = List<String>.from(_filtrosModalidades);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FiltroModal(
        tempCategorias: tempCategorias,
        tempModalidades: tempModalidades,
        categorias: _categorias,
        modalidades: _modalidades,
        onAplicar: (cats, mods) {
          setState(() {
            _filtrosCategorias
              ..clear()
              ..addAll(cats);
            _filtrosModalidades
              ..clear()
              ..addAll(mods);
          });
          Navigator.pop(context);
          _cargar();
        },
        onCancelar: () => Navigator.pop(context),
      ),
    );
  }

  bool get _hayAlgunFiltroActivo =>
      _hayFiltros || _busqueda.isNotEmpty;

  @override
  Widget build(BuildContext context) {
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
              if (_hayFiltros)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_totalFiltrosActivos',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Barra de búsqueda ────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              onChanged: _onBusquedaChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar por cargo o empresa...',
                hintStyle: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 20),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textSecondary),
                        onPressed: _limpiarBusqueda,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Barra de filtros activos ─────────────────────────────
          if (_hayFiltros)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Filtros activos ($_totalFiltrosActivos)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _limpiarTodo,
                        child: const Text(
                          'Limpiar todo',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ..._filtrosCategorias.map(
                        (c) => _FiltroActivo(
                          label: c,
                          onQuitar: () {
                            setState(() => _filtrosCategorias.remove(c));
                            _cargar();
                          },
                        ),
                      ),
                      ..._filtrosModalidades.map(
                        (m) => _FiltroActivo(
                          label: m,
                          onQuitar: () {
                            setState(() => _filtrosModalidades.remove(m));
                            _cargar();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          if (_hayFiltros) const Divider(height: 1),

          // ── Lista de vacantes ────────────────────────────────────
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _vacantes.isEmpty
                    ? _EmptyState(
                        conFiltros: _hayAlgunFiltroActivo,
                        onLimpiar: _hayAlgunFiltroActivo
                            ? () {
                                _limpiarBusqueda();
                                _limpiarTodo();
                              }
                            : null,
                      )
                    : RefreshIndicator(
                        onRefresh: _cargar,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          itemCount: _vacantes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) => _TarjetaVacante(
                            vacante: _vacantes[i],
                            terminoBusqueda: _busqueda,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VacanteDetalleScreen(
                                  vacanteId: _vacantes[i].id!,
                                ),
                              ),
                            ).then((_) => _cargar()),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state contextual ────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool conFiltros;
  final VoidCallback? onLimpiar;
  const _EmptyState({required this.conFiltros, this.onLimpiar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            conFiltros ? Icons.search_off : Icons.work_off_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            conFiltros
                ? 'No hay vacantes con esa búsqueda'
                : 'No hay vacantes disponibles',
            style: const TextStyle(
                fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            conFiltros
                ? 'Prueba con otras palabras o quita los filtros'
                : 'Vuelve pronto, se publican nuevas vacantes cada día',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
          ),
          if (onLimpiar != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onLimpiar,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Limpiar búsqueda y filtros'),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Modal de filtros ──────────────────────────────────────────
class _FiltroModal extends StatefulWidget {
  final List<String> tempCategorias;
  final List<String> tempModalidades;
  final List<String> categorias;
  final List<String> modalidades;
  final void Function(List<String> cats, List<String> mods) onAplicar;
  final VoidCallback onCancelar;

  const _FiltroModal({
    required this.tempCategorias,
    required this.tempModalidades,
    required this.categorias,
    required this.modalidades,
    required this.onAplicar,
    required this.onCancelar,
  });

  @override
  State<_FiltroModal> createState() => _FiltroModalState();
}

class _FiltroModalState extends State<_FiltroModal> {
  late final List<String> _cats;
  late final List<String> _mods;

  @override
  void initState() {
    super.initState();
    _cats = List<String>.from(widget.tempCategorias);
    _mods = List<String>.from(widget.tempModalidades);
  }

  int get _total => _cats.length + _mods.length;

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 14, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContador(int count) => Container(
        margin: const EdgeInsets.only(left: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filtrar vacantes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_total > 0)
                TextButton(
                  onPressed: () => setState(() {
                    _cats.clear();
                    _mods.clear();
                  }),
                  child: const Text('Limpiar todo'),
                ),
            ],
          ),
          if (_total > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '$_total filtro(s) seleccionado(s)',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.category_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text(
                'Categoría',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_cats.isNotEmpty) _buildContador(_cats.length),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.categorias.map((c) {
              final sel = _cats.contains(c);
              return _buildChip(
                label: c,
                selected: sel,
                onTap: () => setState(
                  () => sel ? _cats.remove(c) : _cats.add(c),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.laptop_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text(
                'Modalidad',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_mods.isNotEmpty) _buildContador(_mods.length),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.modalidades.map((m) {
              final sel = _mods.contains(m);
              return _buildChip(
                label: m,
                selected: sel,
                onTap: () => setState(
                  () => sel ? _mods.remove(m) : _mods.add(m),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancelar,
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => widget.onAplicar(_cats, _mods),
                  child: Text(
                    _total == 0 ? 'Ver todas' : 'Aplicar filtros',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Chip de filtro activo ─────────────────────────────────────
class _FiltroActivo extends StatelessWidget {
  final String label;
  final VoidCallback onQuitar;
  const _FiltroActivo({required this.label, required this.onQuitar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onQuitar,
            child: const CircleAvatar(
              radius: 9,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.close, size: 11, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de vacante ────────────────────────────────────────
class _TarjetaVacante extends StatelessWidget {
  final Vacante vacante;
  final String terminoBusqueda;
  final VoidCallback onTap;
  const _TarjetaVacante({
    required this.vacante,
    required this.terminoBusqueda,
    required this.onTap,
  });

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

  /// Resalta el término de búsqueda dentro del texto.
  Widget _textoResaltado(String texto, String termino, TextStyle base) {
    if (termino.isEmpty) return Text(texto, style: base, maxLines: 2, overflow: TextOverflow.ellipsis);
    final lower   = texto.toLowerCase();
    final lTerm   = termino.toLowerCase();
    final idx     = lower.indexOf(lTerm);
    if (idx == -1) return Text(texto, style: base, maxLines: 2, overflow: TextOverflow.ellipsis);

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: base, children: [
        TextSpan(text: texto.substring(0, idx)),
        TextSpan(
          text: texto.substring(idx, idx + termino.length),
          style: base.copyWith(
            backgroundColor: Colors.yellow.withOpacity(0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(text: texto.substring(idx + termino.length)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = vacante.categoria?.toLowerCase() ?? '';
    final colores =
        _coloresCat[cat] ?? [const Color(0xFFF5F5F5), AppColors.primary];
    final icono = _iconosCat[cat] ?? Icons.work_outline;
    final bgColor = colores[0] as Color;
    final acColor = colores[1] as Color;

    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      shadowColor: acColor.withOpacity(0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: acColor.withOpacity(0.15),
                      child: Icon(icono, color: acColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _textoResaltado(
                            vacante.titulo,
                            terminoBusqueda,
                            TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: acColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          _textoResaltado(
                            vacante.empresa ?? '',
                            terminoBusqueda,
                            const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.attach_money,
                              size: 16, color: acColor),
                          const SizedBox(width: 4),
                          Text(
                            vacante.salarioReferencial!,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: acColor,
                              fontSize: 14,
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
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pill chip ─────────────────────────────────────────────────
class _PillChip extends StatelessWidget {
  final String label;
  final Color color;
  const _PillChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}
