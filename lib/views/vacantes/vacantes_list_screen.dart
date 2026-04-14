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
  final _repo        = VacanteRepository();
  final _searchCtrl  = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  List<Vacante> _vacantes = [];
  bool   _cargando = true;
  String _busqueda = '';

  final List<String> _filtrosCategorias  = [];
  final List<String> _filtrosModalidades = [];

  static const _categorias = [
    'ventas', 'gastronomía', 'logística', 'servicios', 'construcción',
  ];
  static const _modalidades = ['presencial', 'virtual', 'híbrida'];

  static const _catMeta = {
    'ventas':       {'icono': Icons.storefront_outlined,      'bg': Color(0xFFE3F2FD), 'ac': Color(0xFF1565C0)},
    'gastronomía':  {'icono': Icons.restaurant_outlined,      'bg': Color(0xFFFFF3E0), 'ac': Color(0xFFE65100)},
    'logística':    {'icono': Icons.local_shipping_outlined,  'bg': Color(0xFFE8F5E9), 'ac': Color(0xFF2E7D32)},
    'servicios':    {'icono': Icons.support_agent_outlined,   'bg': Color(0xFFF3E5F5), 'ac': Color(0xFF6A1B9A)},
    'construcción': {'icono': Icons.construction_outlined,    'bg': Color(0xFFFBE9E7), 'ac': Color(0xFFBF360C)},
  };

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
      busqueda:    _busqueda.isEmpty ? null : _busqueda,
      categorias:  _filtrosCategorias.isEmpty  ? null : _filtrosCategorias,
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

  void _toggleCategoria(String cat) {
    setState(() => _filtrosCategorias.contains(cat)
        ? _filtrosCategorias.remove(cat)
        : _filtrosCategorias.add(cat));
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

  bool get _hayAlgunFiltroActivo => _hayFiltros || _busqueda.isNotEmpty;

  void _mostrarFiltrosModal() {
    showModalBottomSheet(
      context:           context,
      isScrollControlled: true,
      backgroundColor:   Colors.transparent,
      builder: (_) => _FiltroModal(
        filtrosModalidades: List.from(_filtrosModalidades),
        modalidades:        _modalidades,
        onAplicar: (mods) {
          setState(() => _filtrosModalidades..clear()..addAll(mods));
          Navigator.pop(context);
          _cargar();
        },
        onCancelar: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header con degradado ─────────────────────────────
            _Header(
              busqueda:         _busqueda,
              searchCtrl:       _searchCtrl,
              searchFocus:      _searchFocus,
              onChanged:        _onBusquedaChanged,
              onClear:          _limpiarBusqueda,
              totalFiltros:     _totalFiltrosActivos,
              onMostrarFiltros: _mostrarFiltrosModal,
              hayFiltros:       _hayFiltros,
            ),

            // ── Chips de categoría (scroll horizontal) ───────────
            _CategoriasRail(
              categorias:    _categorias,
              catMeta:       _catMeta,
              seleccionadas: _filtrosCategorias,
              onToggle:      _toggleCategoria,
            ),

            // ── Contador de resultados ───────────────────────────
            if (!_cargando)
              _ResultadosBar(
                total:      _vacantes.length,
                hayFiltros: _hayAlgunFiltroActivo,
                onLimpiar:  _hayAlgunFiltroActivo ? _limpiarTodo : null,
              ),

            // ── Lista ────────────────────────────────────────────
            Expanded(
              child: _cargando
                  ? const _LoadingState()
                  : _vacantes.isEmpty
                      ? _EmptyState(
                          conFiltros: _hayAlgunFiltroActivo,
                          onLimpiar:  _hayAlgunFiltroActivo
                              ? () { _limpiarBusqueda(); _limpiarTodo(); }
                              : null,
                        )
                      : RefreshIndicator(
                          color:     AppColors.primary,
                          onRefresh: _cargar,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                                16, 8, 16, 32),
                            itemCount: _vacantes.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) => _TarjetaVacante(
                              vacante:         _vacantes[i],
                              catMeta:         _catMeta,
                              terminoBusqueda: _busqueda,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VacanteDetalleScreen(
                                      vacanteId: _vacantes[i].id!),
                                ),
                              ).then((_) => _cargar()),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header con degradado + búsqueda integrada ─────────────────
class _Header extends StatelessWidget {
  final String                busqueda;
  final TextEditingController searchCtrl;
  final FocusNode             searchFocus;
  final ValueChanged<String>  onChanged;
  final VoidCallback          onClear;
  final int                   totalFiltros;
  final VoidCallback          onMostrarFiltros;
  final bool                  hayFiltros;

  const _Header({
    required this.busqueda,
    required this.searchCtrl,
    required this.searchFocus,
    required this.onChanged,
    required this.onClear,
    required this.totalFiltros,
    required this.onMostrarFiltros,
    required this.hayFiltros,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encuentra tu trabajo',
                      style: TextStyle(
                        fontSize:   20,
                        fontWeight: FontWeight.bold,
                        color:      Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Oportunidades formales para ti',
                      style: TextStyle(
                          fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              // Botón de filtros de modalidad
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: onMostrarFiltros,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color:        Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                        border:       Border.all(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tune_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 5),
                          Text('Filtros',
                              style: TextStyle(
                                  color:      Colors.white,
                                  fontSize:   13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  if (hayFiltros)
                    Positioned(
                      top:   -4,
                      right: -4,
                      child: Container(
                        width:  16,
                        height: 16,
                        decoration: const BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '$totalFiltros',
                            style: const TextStyle(
                                color:      Colors.white,
                                fontSize:   9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Barra de búsqueda
          Container(
            decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset:     const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller:      searchCtrl,
              focusNode:       searchFocus,
              onChanged:       onChanged,
              textInputAction: TextInputAction.search,
              style:           const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cargo, empresa, habilidad...',
                hintStyle: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.primary, size: 20),
                suffixIcon: busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18,
                            color: AppColors.textSecondary),
                        onPressed: onClear,
                      )
                    : null,
                border:         InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chips de categoría con scroll horizontal ──────────────────
class _CategoriasRail extends StatelessWidget {
  final List<String>         categorias;
  final Map<String, dynamic> catMeta;
  final List<String>         seleccionadas;
  final ValueChanged<String> onToggle;

  const _CategoriasRail({
    required this.categorias,
    required this.catMeta,
    required this.seleccionadas,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categorias.map((cat) {
            final meta  = catMeta[cat] ?? {};
            final icono = meta['icono'] as IconData? ?? Icons.work_outline;
            final bg    = meta['bg']    as Color? ?? AppColors.primaryLight;
            final ac    = meta['ac']    as Color? ?? AppColors.primary;
            final sel   = seleccionadas.contains(cat);
            final label = cat[0].toUpperCase() + cat.substring(1);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onToggle(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color:        sel ? ac : bg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: sel ? ac : ac.withOpacity(0.25),
                      width: sel ? 0 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icono,
                          size:  14,
                          color: sel ? Colors.white : ac),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize:   12,
                          fontWeight: FontWeight.w600,
                          color:      sel ? Colors.white : ac,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Barra de resultados ───────────────────────────────────────
class _ResultadosBar extends StatelessWidget {
  final int           total;
  final bool          hayFiltros;
  final VoidCallback? onLimpiar;

  const _ResultadosBar({
    required this.total,
    required this.hayFiltros,
    this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 10),
      child: Row(
        children: [
          Text(
            total == 0
                ? 'Sin resultados'
                : '$total ${total == 1 ? 'vacante' : 'vacantes'} disponibles',
            style: const TextStyle(
              fontSize:   12,
              color:      AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (hayFiltros && onLimpiar != null)
            TextButton(
              onPressed: onLimpiar,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding:   const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                minimumSize:    Size.zero,
                tapTargetSize:  MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Limpiar filtros',
                  style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

// ── Tarjeta de vacante — layout horizontal compacto ───────────
class _TarjetaVacante extends StatelessWidget {
  final Vacante              vacante;
  final Map<String, dynamic> catMeta;
  final String               terminoBusqueda;
  final VoidCallback         onTap;

  const _TarjetaVacante({
    required this.vacante,
    required this.catMeta,
    required this.terminoBusqueda,
    required this.onTap,
  });

  Widget _resaltado(String texto, String termino, TextStyle base) {
    if (termino.isEmpty) {
      return Text(texto,
          style: base, maxLines: 2, overflow: TextOverflow.ellipsis);
    }
    final idx = texto.toLowerCase().indexOf(termino.toLowerCase());
    if (idx == -1) {
      return Text(texto,
          style: base, maxLines: 2, overflow: TextOverflow.ellipsis);
    }
    return RichText(
      maxLines:  2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: base, children: [
        TextSpan(text: texto.substring(0, idx)),
        TextSpan(
          text:  texto.substring(idx, idx + termino.length),
          style: base.copyWith(
            backgroundColor: Colors.yellow.withOpacity(0.55),
            fontWeight:      FontWeight.bold,
          ),
        ),
        TextSpan(text: texto.substring(idx + termino.length)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat   = vacante.categoria?.toLowerCase() ?? '';
    final meta  = catMeta[cat] ?? {};
    final bg    = meta['bg']    as Color? ?? AppColors.primaryLight;
    final ac    = meta['ac']    as Color? ?? AppColors.primary;
    final icono = meta['icono'] as IconData? ?? Icons.work_outline;

    return Material(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border:       Border.all(color: AppColors.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra de acento izquierda
                Container(
                  width:  4,
                  decoration: BoxDecoration(
                    color:        ac,
                    borderRadius: const BorderRadius.only(
                      topLeft:    Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),

                // Contenido
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila superior: ícono + título + flecha
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width:  42,
                              height: 42,
                              decoration: BoxDecoration(
                                color:        bg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icono, color: ac, size: 20),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _resaltado(
                                    vacante.titulo,
                                    terminoBusqueda,
                                    const TextStyle(
                                      fontSize:   14,
                                      fontWeight: FontWeight.bold,
                                      color:      AppColors.textPrimary,
                                      height:     1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  _resaltado(
                                    vacante.empresa ?? '',
                                    terminoBusqueda,
                                    TextStyle(
                                      fontSize:   12,
                                      color:      ac,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size:  13,
                                color: AppColors.textDisabled),
                          ],
                        ),

                        const SizedBox(height: 11),

                        // Chips de info
                        Wrap(
                          spacing:    6,
                          runSpacing: 5,
                          children: [
                            if (vacante.modalidad != null)
                              _InfoChip(
                                icono: Icons.laptop_outlined,
                                label: vacante.modalidad!,
                                color: ac,
                              ),
                            if (vacante.jornada != null)
                              _InfoChip(
                                icono: Icons.schedule_outlined,
                                label: vacante.jornada!,
                                color: ac,
                              ),
                            if (vacante.categoria != null)
                              _InfoChip(
                                icono: Icons.category_outlined,
                                label: vacante.categoria!,
                                color: ac,
                              ),
                          ],
                        ),

                        // Footer: salario + fecha cierre
                        if (vacante.salarioReferencial != null ||
                            vacante.fechaCierre != null) ...[
                          const SizedBox(height: 10),
                          const Divider(
                              height: 1, color: AppColors.border),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              if (vacante.salarioReferencial != null) ...[
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success
                                          .withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                            Icons.attach_money_rounded,
                                            size:  13,
                                            color: AppColors.success),
                                        Flexible(
                                          child: Text(
                                            vacante.salarioReferencial!,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize:   12,
                                              fontWeight: FontWeight.w700,
                                              color:      AppColors.success,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8),
                              if (vacante.fechaCierre != null)
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(Icons.event_outlined,
                                          size:  12,
                                          color: AppColors.textSecondary),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          'Cierra: ${vacante.fechaCierre}',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color:    AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
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

class _InfoChip extends StatelessWidget {
  final IconData icono;
  final String   label;
  final Color    color;
  const _InfoChip(
      {required this.icono, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color:        color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(6),
          border:       Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 11, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize:   11,
                color:      color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

// ── Loading skeleton ──────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding:          const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount:        5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder:      (_, __) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  Widget _rect(double w, double h, {double r = 4}) => Container(
        width:  w,
        height: h,
        decoration: BoxDecoration(
          color:        AppColors.border,
          borderRadius: BorderRadius.circular(r),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color:        AppColors.border,
                borderRadius: const BorderRadius.only(
                  topLeft:    Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _rect(42, 42, r: 10),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _rect(double.infinity, 13),
                              const SizedBox(height: 6),
                              _rect(100, 11),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing:    6,
                      runSpacing: 6,
                      children: [
                        _rect(60, 22, r: 6),
                        _rect(70, 22, r: 6),
                        _rect(65, 22, r: 6),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool          conFiltros;
  final VoidCallback? onLimpiar;
  const _EmptyState({required this.conFiltros, this.onLimpiar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:  80,
              height: 80,
              decoration: BoxDecoration(
                color:        AppColors.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                conFiltros
                    ? Icons.search_off_rounded
                    : Icons.work_off_outlined,
                size:  36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              conFiltros ? 'Sin resultados' : 'Pronto habrá vacantes',
              style: const TextStyle(
                fontSize:   18,
                fontWeight: FontWeight.bold,
                color:      AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              conFiltros
                  ? 'Prueba con otras palabras o quita los filtros activos.'
                  : 'Se publican nuevas oportunidades cada día. Vuelve pronto.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13,
                  color:    AppColors.textSecondary,
                  height:   1.5),
            ),
            if (onLimpiar != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onLimpiar,
                icon:  const Icon(Icons.filter_alt_off_outlined, size: 16),
                label: const Text('Limpiar filtros'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Modal de filtros (solo modalidad) ─────────────────────────
class _FiltroModal extends StatefulWidget {
  final List<String>                     filtrosModalidades;
  final List<String>                     modalidades;
  final void Function(List<String> mods) onAplicar;
  final VoidCallback                     onCancelar;

  const _FiltroModal({
    required this.filtrosModalidades,
    required this.modalidades,
    required this.onAplicar,
    required this.onCancelar,
  });

  @override
  State<_FiltroModal> createState() => _FiltroModalState();
}

class _FiltroModalState extends State<_FiltroModal> {
  late final List<String> _mods;

  @override
  void initState() {
    super.initState();
    _mods = List.from(widget.filtrosModalidades);
  }

  Widget _chip(String label, bool sel, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: sel ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: sel ? AppColors.primary : AppColors.border,
                width: sel ? 0 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sel) ...[
                const Icon(Icons.check_rounded,
                    size: 14, color: Colors.white),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color:      sel ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24,
          MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width:  40,
              height: 4,
              decoration: BoxDecoration(
                color:        AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Text('Modalidad de trabajo',
                  style: TextStyle(
                      fontSize:   17,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.textPrimary)),
              const Spacer(),
              if (_mods.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _mods.clear()),
                  style: TextButton.styleFrom(
                    padding:         EdgeInsets.zero,
                    minimumSize:     Size.zero,
                    foregroundColor: AppColors.error,
                  ),
                  child: const Text('Limpiar',
                      style: TextStyle(fontSize: 13)),
                ),
            ],
          ),
          const SizedBox(height: 14),

          Wrap(
            spacing:    8,
            runSpacing: 8,
            children: widget.modalidades.map((m) {
              final sel = _mods.contains(m);
              return _chip(m, sel, () => setState(
                  () => sel ? _mods.remove(m) : _mods.add(m)));
            }).toList(),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancelar,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape:   RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => widget.onAplicar(_mods),
                  style: ElevatedButton.styleFrom(
                    padding:   const EdgeInsets.symmetric(vertical: 13),
                    shape:     RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text(_mods.isEmpty ? 'Ver todas' : 'Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
