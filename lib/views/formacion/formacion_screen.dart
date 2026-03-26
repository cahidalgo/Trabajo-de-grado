import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/category_style.dart';
import '../../core/widgets/app_ui.dart';
import '../../data/models/formacion.dart';
import '../../data/repositories/formacion_repository.dart';

class FormacionScreen extends StatefulWidget {
  const FormacionScreen({super.key});

  @override
  State<FormacionScreen> createState() => _FormacionScreenState();
}

class _FormacionScreenState extends State<FormacionScreen> {
  final _repo = FormacionRepository();
  List<Formacion> _cursos = [];
  bool _cargando = true;
  String? _filtro;

  static const _categorias = [
    'ventas',
    'gastronomía',
    'logística',
    'servicios',
    'herramientas digitales',
    'emprendimiento',
    'habilidades blandas',
    'construcción',
  ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    _cursos = await _repo.obtenerTodas(categoria: _filtro);
    if (mounted) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formación')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              children: [
                const AppPageIntro(
                  title: 'Ruta de formación',
                  subtitle:
                      'Explora cursos cortos y prácticos para fortalecer tu perfil y mejorar tus opciones laborales.',
                  icon: Icons.school_outlined,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FiltroChip(
                        label: 'Todos',
                        seleccionado: _filtro == null,
                        onTap: () {
                          setState(() => _filtro = null);
                          _cargar();
                        },
                      ),
                      ..._categorias.map(
                        (categoria) => _FiltroChip(
                          label: categoria,
                          seleccionado: _filtro == categoria,
                          onTap: () {
                            setState(() => _filtro = categoria);
                            _cargar();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _cursos.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.school_outlined,
                        title: 'No hay cursos en esta categoría',
                        description:
                            'Prueba con otra categoría o vuelve a cargar para ver nuevas opciones.',
                      )
                    : RefreshIndicator(
                        onRefresh: _cargar,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: _cursos.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            if (index == 0) {
                              return AppInfoBanner(
                                title: _filtro == null
                                    ? 'Cursos recomendados'
                                    : 'Filtrado por ${_filtro!}',
                                description:
                                    'Cada curso incluye modalidad, duración y una descripción breve para decidir rápido.',
                                icon: Icons.auto_stories_outlined,
                                color: AppColors.primary,
                              );
                            }

                            return _TarjetaFormacion(curso: _cursos[index - 1]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: seleccionado ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: seleccionado ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: seleccionado ? Colors.white : AppColors.textPrimary,
                fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaFormacion extends StatelessWidget {
  final Formacion curso;

  const _TarjetaFormacion({required this.curso});

  @override
  Widget build(BuildContext context) {
    final style = AppCategoryStyles.resolve(curso.categoria);

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: style.accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(style.icon, color: style.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curso.titulo,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: style.accent,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((curso.entidad ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          curso.entidad!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((curso.descripcion ?? '').trim().isNotEmpty) ...[
                  Text(
                    curso.descripcion!,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if ((curso.modalidad ?? '').trim().isNotEmpty)
                      AppTag(label: curso.modalidad!, color: style.accent),
                    if ((curso.duracion ?? '').trim().isNotEmpty)
                      AppTag(label: curso.duracion!, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => _verDetalle(context),
                    child: const Text('Ver más'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _verDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                curso.titulo,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if ((curso.entidad ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  curso.entidad!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if ((curso.descripcion ?? '').trim().isNotEmpty)
                Text(
                  curso.descripcion!,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              const SizedBox(height: 20),
              if ((curso.modalidad ?? '').trim().isNotEmpty)
                _DetalleRow('Modalidad', curso.modalidad!),
              if ((curso.duracion ?? '').trim().isNotEmpty)
                _DetalleRow('Duración', curso.duracion!),
              if ((curso.categoria ?? '').trim().isNotEmpty)
                _DetalleRow('Categoría', curso.categoria!),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Inscripción registrada!')),
                    );
                  },
                  icon: const Icon(Icons.how_to_reg_outlined),
                  label: const Text('Quiero inscribirme'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetalleRow extends StatelessWidget {
  final String label;
  final String valor;

  const _DetalleRow(this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
