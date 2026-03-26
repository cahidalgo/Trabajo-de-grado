import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    context.read<VacanteEmpresaViewModel>().cargarPostulantes(widget.vacante.id!);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VacanteEmpresaViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text('Postulantes: ${widget.vacante.titulo}')),
      body: vm.cargando
          ? const Center(child: CircularProgressIndicator())
          : vm.postulantes.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text('Aún no hay postulantes para esta vacante.'),
                  ]),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.postulantes.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final p = vm.postulantes[i];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(p['nombre'] ?? 'Sin nombre'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['correo_o_celular'] ?? ''),
                          Text('Nivel educativo: ${p['nivel_educativo'] ?? '-'}'),
                          Text('Estado: ${p['estado'] ?? 'Enviada'}'),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
    );
  }
}
