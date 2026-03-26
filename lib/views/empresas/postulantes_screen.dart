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

class _PostulantesScreenState extends State<PostulantesScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<VacanteEmpresaViewModel>()
        .cargarPostulantes(widget.vacante.id!);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VacanteEmpresaViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Postulantes')),
      body: vm.cargando
          ? const Center(child: CircularProgressIndicator())
          : vm.postulantes.isEmpty
              ? AppEmptyState(
                  icon: Icons.people_outline,
                  title: 'Aún no hay postulantes',
                  description:
                      'Cuando personas interesadas se postulen a "${widget.vacante.titulo}", las verás aquí.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: vm.postulantes.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return AppPageIntro(
                        title: widget.vacante.titulo,
                        subtitle:
                            'Consulta los datos básicos de cada persona interesada y el estado actual de su postulación.',
                        icon: Icons.group_outlined,
                      );
                    }

                    final postulante = vm.postulantes[index - 1];
                    return AppSurfaceCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  postulante['nombre'] ?? 'Sin nombre',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  postulante['correo_o_celular'] ?? '',
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
                                    AppTag(
                                      label:
                                          'Estado: ${postulante['estado'] ?? 'Enviada'}',
                                      color: AppColors.primary,
                                    ),
                                    AppTag(
                                      label:
                                          'Nivel: ${postulante['nivel_educativo'] ?? '-'}',
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
