import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../data/models/vacante.dart';
import '../../data/repositories/vacante_repository.dart';
import '../../data/repositories/usuario_repository.dart';
import 'vacante_detalle_screen.dart';

class VacantesListScreen extends StatefulWidget {
  const VacantesListScreen({super.key});

  @override
  State<VacantesListScreen> createState() => _VacantesListScreenState();
}

class _VacantesListScreenState extends State<VacantesListScreen> {
  final _repo         = VacanteRepository();
  final _usuarioRepo  = UsuarioRepository();
  final _searchCtrl   = TextEditingController();
  final _searchFocus  = FocusNode();
  Timer? _debounce;

  List<Vacante> _vacantes        = [];
  bool          _cargando        = true;
  String        _busqueda        = '';
  String?       _nombreUsuario;

  // null = "Todos", String = categoría seleccionada
  String? _categoriaSeleccionada;

  final List<String> _filtrosModalidades = [];

  static const _categorias = [
    'ventas', 'gastronomía', 'logística', 'servicios', 'construcción',
  ];
  static const _modalidades = ['presencial', 'virtual', 'híbrida'];

  static const _catMeta = {
    'ventas':       {'icono': Icons.storefront_outlined,     'bg': Color(0xFFE3F2FD), 'ac': Color(0xFF1565C0)},
    'gastronomía':  {'icono': Icons.restaurant_outlined,     'bg': Color(0xFFFFF3E0), 'ac': Color(0xFFE65100)},
    'logística':    {'icono': Icons.local_shipping_outlined, 'bg': Color(0xFFE8F5E9), 'ac': Color(0xFF2E7D32)},
    'servicios':    {'icono': Icons.support_agent_outlined,  'bg': Color(0xFFF3E5F5), 'ac': Color(0xFF6A1B9A)},
    'construcción': {'icono': Icons.construction_outlined,   'bg': Color(0xFFFBE9E7), 'ac': Color(0xFFBF360C)},
  };

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
    _cargar();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _cargarNombreUsuario() async {
    final authId = SupabaseService.currentAuthId;
    if (authId == null) return;
    try {
      final usuario = await _usuarioRepo.obtenerActual();
      if (mounted && usuario?.nombreCompleto != null) {
        setState(() => _nombreUsuario = usuario!.nombreCompleto);
      }
    } catch (_) {}
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    _vacantes = await _repo.obtenerTodas(
      busqueda:    _busqueda.isEmpty ? null : _busqueda,
      categorias:  _categoriaSeleccionada != null
                       ? [_categoriaSeleccionada!]
                       : null,
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

  void _seleccionarCategoria(String? cat) {
    setState(() => _categoriaSeleccionada = cat);
    _cargar();
  }

  bool get _hayFiltros =>
      _categoriaSeleccionada != null || _filtrosModalidades.isNotEmpty;

  bool get _hayAlgunFiltroActivo => _hayFiltros || _busqueda.isNotEmpty;

  void _limpiarTodo() {
    setState(() {
      _categoriaSeleccionada = null;
      _filtrosModalidades.clear();
    });
    _cargar();
  }

  void _mostrarFiltrosModal() {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
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

  // ── Saludo según hora del día ─────────────────────────────────
  String get _saludo {
    final h = DateTime.now().hour;
    if (h < 12) return '¡Buenos días!';
    if (h < 19) return '¡Buenas tardes! 👋';
    return '¡Buenas noches! 🌙';
  }

  // ── Primera letra de cada palabra del nombre ──────────────────
  String _iniciales(String nombre) {
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────
            _Header(
              saludo:           _saludo,
              nombreUsuario:    _nombreUsuario,
              iniciales:        _nombreUsuario != null
                                    ? _iniciales(_nombreUsuario!)
                                    : '?',
              busqueda:         _busqueda,
              searchCtrl:       _searchCtrl,
              searchFocus:      _searchFocus,
              onChanged:        _onBusquedaChanged,
              onClear:          _limpiarBusqueda,
              hayFiltroModal:   _filtrosModalidades.isNotEmpty,
              onMostrarFiltros: _mostrarFiltrosModal,
            ),

            // ── Chips de categoría ────────────────────────────────
            _CategoriasRail(
              categorias:         _categorias,
              catMeta:            _catMeta,
              seleccionada:       _categoriaSeleccionada,
              onSeleccionar:      _seleccionarCategoria,
            ),

            // ── Contador + limpiar ────────────────────────────────
            if (!_cargando)
              _ResultadosBar(
                total:      _vacantes.length,
                hayFiltros: _hayAlgunFiltroActivo,
                onLimpiar:  _hayAlgunFiltroActivo ? _limpiarTodo : null,
              ),

            // ── Lista ─────────────────────────────────────────────
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
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                            itemCount:        _vacantes.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
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

// ─────────────────────────────────────────────────────────────
// Header — fondo blanco, saludo + nombre + avatar + búsqueda
// ─────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String  saludo;
  final String? nombreUsuario;
  final String  iniciales;
  final String  busqueda;
  final TextEditingController searchCtrl;
  final FocusNode             searchFocus;
  final ValueChanged<String>  onChanged;
  final VoidCallback          onClear;
  final bool                  hayFiltroModal;
  final VoidCallback          onMostrarFiltros;

  const _Header({
    required this.saludo,
    required this.nombreUsuario,
    required this.iniciales,
    required this.busqueda,
    required this.searchCtrl,
    required this.searchFocus,
    required this.onChanged,
    required this.onClear,
    required this.hayFiltroModal,
    required this.onMostrarFiltros,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Saludo + avatar ────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      saludo,
                      style: const TextStyle(
                        fontSize:   13,
                        color:      AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nombreUsuario ?? 'Bienvenido',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize:   20,
                        fontWeight: FontWeight.bold,
                        color:      AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Avatar con iniciales + botón filtros
              Row(
                children: [
                  // Botón filtros de modalidad
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: onMostrarFiltros,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:        AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border:       Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.tune_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                      ),
                      if (hayFiltroModal)
                        Positioned(
                          top: -3, right: -3,
                          child: Container(
                            width: 10, height: 10,
                            decoration: const BoxDecoration(
                                color: AppColors.warning,
                                shape: BoxShape.circle),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  // Avatar
                  Container(
                    width:  42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:        AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        iniciales,
                        style: const TextStyle(
                          fontSize:   15,
                          fontWeight: FontWeight.bold,
                          color:      Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Barra de búsqueda ──────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color:        AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller:      searchCtrl,
              focusNode:       searchFocus,
              onChanged:       onChanged,
              textInputAction: TextInputAction.search,
              style:           const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar vacantes...',
                hintStyle: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 20),
                suffixIcon: busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textSecondary),
                        onPressed: onClear,
                      )
                    : null,
                border:         InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Rail de categorías — "Todos" + categorías, selección única
// ─────────────────────────────────────────────────────────────
class _CategoriasRail extends StatelessWidget {
  final List<String>         categorias;
  final Map<String, dynamic> catMeta;
  final String?              seleccionada;    // null = Todos
  final ValueChanged<String?> onSeleccionar;

  const _CategoriasRail({
    required this.categorias,
    required this.catMeta,
    required this.seleccionada,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // ── Chip "Todos" ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSeleccionar(null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: seleccionada == null
                        ? AppColors.primary
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Todos',
                    style: TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w700,
                      color: seleccionada == null
                          ? Colors.white
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

            // ── Chips por categoría ───────────────────────────────
            ...categorias.map((cat) {
              final meta  = catMeta[cat] ?? {};
              final bg    = meta['bg']    as Color? ?? AppColors.primaryLight;
              final ac    = meta['ac']    as Color? ?? AppColors.primary;
              final sel   = seleccionada == cat;
              final label = cat[0].toUpperCase() + cat.substring(1);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSeleccionar(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color:        sel ? ac : bg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize:   13,
                        fontWeight: FontWeight.w600,
                        color:      sel ? Colors.white : ac,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Barra de resultados
// ─────────────────────────────────────────────────────────────
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
      color:   AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
      child: Row(
        children: [
          Text(
            total == 0
                ? 'Sin resultados'
                : '$total ${total == 1 ? 'vacante disponible' : 'vacantes disponibles'}',
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
                padding:        const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                minimumSize:    Size.zero,
                tapTargetSize:  MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Limpiar',
                  style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tarjeta — layout del mockup con tema claro
// ─────────────────────────────────────────────────────────────
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

  // ── Iniciales de la empresa ───────────────────────────────────
  String _inicialesEmpresa(String nombre) {
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  // ── "Cierra en X días" ────────────────────────────────────────
  String? _cierreEnDias(String? fechaStr) {
    if (fechaStr == null) return null;
    try {
      final fecha = DateTime.parse(fechaStr);
      final hoy   = DateTime.now();
      final diff  = fecha.difference(DateTime(hoy.year, hoy.month, hoy.day)).inDays;
      if (diff < 0)  return 'Cerrada';
      if (diff == 0) return 'Cierra hoy';
      if (diff == 1) return 'Cierra mañana';
      return 'Cierra en $diff días';
    } catch (_) {
      return fechaStr;
    }
  }

  // ── Color del avatar de empresa ───────────────────────────────
  Color _colorEmpresa(String nombre) {
    const paleta = [
      Color(0xFF1565C0),
      Color(0xFF2E7D32),
      Color(0xFFE65100),
      Color(0xFF6A1B9A),
      Color(0xFFBF360C),
      Color(0xFF00695C),
      Color(0xFF283593),
    ];
    return paleta[nombre.hashCode.abs() % paleta.length];
  }

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
      maxLines: 2,
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
    final cat         = vacante.categoria?.toLowerCase() ?? '';
    final meta        = catMeta[cat] ?? {};
    final acCat       = meta['ac'] as Color? ?? AppColors.primary;
    final bgCat       = meta['bg'] as Color? ?? AppColors.primaryLight;
    final empresa     = vacante.empresa ?? '';
    final colorEmp    = _colorEmpresa(empresa);
    final iniciales   = _inicialesEmpresa(empresa);
    final cierreTexto = _cierreEnDias(vacante.fechaCierre);

    return Material(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(16),
            border:       Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset:     const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Fila superior: título + avatar empresa ──────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título + empresa
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _resaltado(
                          vacante.titulo,
                          terminoBusqueda,
                          const TextStyle(
                            fontSize:   16,
                            fontWeight: FontWeight.bold,
                            color:      AppColors.textPrimary,
                            height:     1.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        _resaltado(
                          empresa,
                          terminoBusqueda,
                          const TextStyle(
                            fontSize:   13,
                            color:      AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Avatar empresa
                  Container(
                    width:  44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:        colorEmp,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        iniciales,
                        style: const TextStyle(
                          fontSize:   15,
                          fontWeight: FontWeight.bold,
                          color:      Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Chips: categoría (coloreada) + modalidad + jornada
              Wrap(
                spacing:    6,
                runSpacing: 6,
                children: [
                  // Categoría — chip con fondo de color
                  if (vacante.categoria != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color:        bgCat,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        vacante.categoria![0].toUpperCase() +
                            vacante.categoria!.substring(1),
                        style: TextStyle(
                          fontSize:   11,
                          fontWeight: FontWeight.w700,
                          color:      acCat,
                        ),
                      ),
                    ),
                  // Modalidad — chip neutro
                  if (vacante.modalidad != null)
                    _ChipNeutro(vacante.modalidad!),
                  // Jornada — chip neutro
                  if (vacante.jornada != null)
                    _ChipNeutro(vacante.jornada!),
                ],
              ),

              // ── Footer: salario + cierre ────────────────────────
              if (vacante.salarioReferencial != null ||
                  cierreTexto != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (vacante.salarioReferencial != null)
                      Flexible(
                        child: Text(
                          vacante.salarioReferencial!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize:   14,
                            fontWeight: FontWeight.w700,
                            color:      AppColors.success,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (cierreTexto != null)
                      Text(
                        cierreTexto,
                        style: TextStyle(
                          fontSize:   12,
                          color:      cierreTexto == 'Cerrada'
                              ? AppColors.error
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Chip neutro para modalidad y jornada
class _ChipNeutro extends StatelessWidget {
  final String label;
  const _ChipNeutro(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:        AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: AppColors.border),
        ),
        child: Text(
          label[0].toUpperCase() + label.substring(1),
          style: const TextStyle(
            fontSize:   11,
            fontWeight: FontWeight.w500,
            color:      AppColors.textSecondary,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// Skeleton loading
// ─────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding:          const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount:        5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder:      (_, __) => const _SkeletonCard(),
      );
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _rect(double.infinity, 14),
                      const SizedBox(height: 6),
                      _rect(140, 11),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _rect(44, 44, r: 12),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                _rect(70, 24, r: 20),
                _rect(80, 24, r: 20),
                _rect(90, 24, r: 20),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            Row(
              children: [
                _rect(120, 13),
                const Spacer(),
                _rect(90, 11),
              ],
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool          conFiltros;
  final VoidCallback? onLimpiar;
  const _EmptyState({required this.conFiltros, this.onLimpiar});

  @override
  Widget build(BuildContext context) => Center(
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
                    ? 'Prueba con otras palabras o cambia los filtros.'
                    : 'Se publican nuevas oportunidades cada día.',
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
                    shape:   RoundedRectangleBorder(
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

// ─────────────────────────────────────────────────────────────
// Modal de filtros de modalidad
// ─────────────────────────────────────────────────────────────
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

  Widget _chip(String label, bool sel, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color:        sel ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border:       Border.all(
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
  Widget build(BuildContext context) => Container(
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
                width: 40, height: 4,
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
                        foregroundColor: AppColors.error),
                    child: const Text('Limpiar',
                        style: TextStyle(fontSize: 13)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8, runSpacing: 8,
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
