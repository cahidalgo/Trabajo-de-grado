import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/formacion.dart';
import '../../data/repositories/formacion_repository.dart';

class FormacionScreen extends StatefulWidget {
  const FormacionScreen({super.key});

  @override
  State<FormacionScreen> createState() => _FormacionScreenState();
}

class _FormacionScreenState extends State<FormacionScreen> {
  final _repo = FormacionRepository();
  List<Formacion> _cursos   = [];
  bool            _cargando = true;
  String?         _filtro;

  static const _categorias = [
    'ventas', 'gastronomía', 'logística', 'servicios',
    'herramientas digitales', 'emprendimiento',
    'habilidades blandas', 'construcción',
  ];

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    _cursos = await _repo.obtenerTodas(categoria: _filtro);
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formación')),
      body: Column(
        children: [
          // Filtros de categoría horizontal
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FiltroChip(label: 'Todos', seleccionado: _filtro == null,
                    onTap: () { setState(() => _filtro = null); _cargar(); }),
                ..._categorias.map((c) => _FiltroChip(
                  label: c,
                  seleccionado: _filtro == c,
                  onTap: () { setState(() => _filtro = c); _cargar(); },
                )),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _cursos.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, size: 64, color: AppColors.textSecondary),
                            SizedBox(height: 16),
                            Text('No hay cursos en esta categoría'),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: _cursos.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (_, i) => _TarjetaFormacion(curso: _cursos[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Chip de filtro horizontal ─────────────────────────────────────────────
class _FiltroChip extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;
  const _FiltroChip({required this.label, required this.seleccionado, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: seleccionado ? AppColors.primary : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: seleccionado ? AppColors.primary : const Color(0xFFBDBDBD)),
      ),
      child: Center(
        child: Text(label,
            style: TextStyle(fontSize: 13, color: seleccionado ? Colors.white : AppColors.textPrimary,
                fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal)),
      ),
    ),
  );
}

// ── Tarjeta de curso ─────────────────────────────────────────────────────
class _TarjetaFormacion extends StatelessWidget {
  final Formacion curso;
  const _TarjetaFormacion({required this.curso});

  static const _coloresCat = {
    'ventas':               [Color(0xFFE3F2FD), Color(0xFF1565C0)],
    'gastronomía':          [Color(0xFFFFF3E0), Color(0xFFE65100)],
    'logística':            [Color(0xFFE8F5E9), Color(0xFF2E7D32)],
    'servicios':            [Color(0xFFF3E5F5), Color(0xFF6A1B9A)],
    'herramientas digitales':[Color(0xFFE0F7FA), Color(0xFF00695C)],
    'emprendimiento':       [Color(0xFFFFF9C4), Color(0xFFF57F17)],
    'habilidades blandas':  [Color(0xFFFCE4EC), Color(0xFFC62828)],
    'construcción':         [Color(0xFFFBE9E7), Color(0xFFBF360C)],
  };

  static const _iconosCat = {
    'ventas':               Icons.storefront_outlined,
    'gastronomía':          Icons.restaurant_outlined,
    'logística':            Icons.local_shipping_outlined,
    'servicios':            Icons.support_agent_outlined,
    'herramientas digitales': Icons.computer_outlined,
    'emprendimiento':       Icons.lightbulb_outlined,
    'habilidades blandas':  Icons.people_outline,
    'construcción':         Icons.construction_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final cat    = curso.categoria?.toLowerCase() ?? '';
    final colores = _coloresCat[cat] ?? [const Color(0xFFF5F5F5), AppColors.primary];
    final icono   = _iconosCat[cat] ?? Icons.school_outlined;
    final bgColor = colores[0];
    final acColor = colores[1];

    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: acColor.withOpacity(0.15),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                        Text(curso.titulo,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: acColor),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        if (curso.entidad != null) ...[
                          const SizedBox(height: 2),
                          Text(curso.entidad!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (curso.descripcion != null) ...[
                    Text(curso.descripcion!,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      if (curso.modalidad != null)
                        _PillInfo(Icons.laptop_outlined, curso.modalidad!, acColor),
                      if (curso.duracion != null) ...[
                        const SizedBox(width: 8),
                        _PillInfo(Icons.schedule_outlined, curso.duracion!, acColor),
                      ],
                      const Spacer(),
                      TextButton(
                        onPressed: () => _verDetalle(context),
                        style: TextButton.styleFrom(
                          foregroundColor: acColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                        child: const Text('Ver más', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _verDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(curso.titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (curso.entidad != null) Text(curso.entidad!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 16),
              if (curso.descripcion != null) Text(curso.descripcion!, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 20),
              if (curso.modalidad != null) _DetalleRow('Modalidad', curso.modalidad!),
              if (curso.duracion  != null) _DetalleRow('Duración',  curso.duracion!),
              if (curso.categoria != null) _DetalleRow('Categoría', curso.categoria!),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Inscripción registrada!'))); },
                icon: const Icon(Icons.how_to_reg_outlined),
                label: const Text('Quiero inscribirme'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _PillInfo(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    ],
  );
}

class _DetalleRow extends StatelessWidget {
  final String label;
  final String valor;
  const _DetalleRow(this.label, this.valor);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(valor, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );
}
