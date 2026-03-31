import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/etiqueta_inclusion_chip.dart';
import '../../data/models/vacante_empresa_model.dart';
import '../../viewmodels/vacante_empresa_viewmodel.dart';

class EditarVacanteScreen extends StatefulWidget {
  final VacanteEmpresaModel vacante;
  const EditarVacanteScreen({super.key, required this.vacante});

  @override
  State<EditarVacanteScreen> createState() =>
      _EditarVacanteScreenState();
}

class _EditarVacanteScreenState
    extends State<EditarVacanteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _salarioCtrl;

  late String _sector;
  late String _modalidad;
  late String _jornada;
  String? _zonaPortal;
  DateTime? _fechaCierre;

  late bool _aceptaInformal;
  late bool _aceptaPepPpt;
  late bool _horarioFlexible;
  late bool _incluyeFormacion;

  final _sectores = [
    'Ventas y comercio', 'Logística', 'Gastronomía',
    'Servicios', 'Administrativo', 'Tecnología', 'Otro',
  ];
  final _modalidades = ['Presencial', 'Virtual', 'Híbrida'];
  final _jornadas = [
    'Tiempo completo', 'Medio tiempo', 'Por horas', 'Turnos',
  ];
  final _portales = [
    'Portal Usme', 'Portal El Tunal', 'Portal Norte',
    'Portal Américas', 'Portal 80', 'Otro',
  ];

  @override
  void initState() {
    super.initState();
    final v = widget.vacante;
    _tituloCtrl = TextEditingController(text: v.titulo);
    _descripcionCtrl = TextEditingController(text: v.descripcion);
    _salarioCtrl =
        TextEditingController(text: v.salarioReferencial ?? '');
    _sector = v.sector;
    _modalidad = v.modalidad;
    _jornada = v.jornada;
    _zonaPortal = v.zonaPortal;
    _aceptaInformal = v.aceptaExperienciaInformal;
    _aceptaPepPpt = v.aceptaPepPpt;
    _horarioFlexible = v.horarioFlexible;
    _incluyeFormacion = v.incluyeFormacion;
    try {
      _fechaCierre = DateTime.parse(v.fechaCierre);
    } catch (_) {
      _fechaCierre = null;
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _salarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate:
          _fechaCierre ?? DateTime.now().add(const Duration(days: 15)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) setState(() => _fechaCierre = fecha);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaCierre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecciona una fecha de cierre')),
      );
      return;
    }

    final actualizada = VacanteEmpresaModel(
      id: widget.vacante.id,
      empresaId: widget.vacante.empresaId,
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      sector: _sector,
      modalidad: _modalidad,
      jornada: _jornada,
      salarioReferencial: _salarioCtrl.text.trim().isEmpty
          ? null
          : _salarioCtrl.text.trim(),
      fechaCierre: _fechaCierre!.toIso8601String(),
      activa: widget.vacante.activa,
      aceptaExperienciaInformal: _aceptaInformal,
      aceptaPepPpt: _aceptaPepPpt,
      horarioFlexible: _horarioFlexible,
      zonaPortal: _zonaPortal,
      incluyeFormacion: _incluyeFormacion,
      fechaPublicacion: widget.vacante.fechaPublicacion,
    );

    await context
        .read<VacanteEmpresaViewModel>()
        .actualizarVacante(actualizada);

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VacanteEmpresaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar vacante'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Información de la vacante',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(
                    labelText: 'Título del cargo'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Descripción del cargo'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _sector,
                decoration:
                    const InputDecoration(labelText: 'Sector'),
                items: _sectores
                    .map((s) => DropdownMenuItem(
                        value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _sector = v!),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _modalidad,
                decoration:
                    const InputDecoration(labelText: 'Modalidad'),
                items: _modalidades
                    .map((m) => DropdownMenuItem(
                        value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _modalidad = v!),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _jornada,
                decoration:
                    const InputDecoration(labelText: 'Jornada'),
                items: _jornadas
                    .map((j) => DropdownMenuItem(
                        value: j, child: Text(j)))
                    .toList(),
                onChanged: (v) => setState(() => _jornada = v!),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _salarioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Salario o rango (opcional)',
                  hintText: 'Ej: \$1.300.000 - \$1.500.000',
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _zonaPortal,
                decoration: const InputDecoration(
                    labelText: 'Portal/zona cercana (opcional)'),
                items: _portales
                    .map((p) => DropdownMenuItem(
                        value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _zonaPortal = v),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: _seleccionarFecha,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 20,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        _fechaCierre == null
                            ? 'Seleccionar fecha de cierre'
                            : 'Cierre: ${_fechaCierre!.day}/${_fechaCierre!.month}/${_fechaCierre!.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _fechaCierre == null
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 32),
              const Text('Etiquetas de inclusión',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text(
                'Marca las condiciones que aplican.',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  EtiquetaInclusionChip(
                    label: 'Acepta experiencia informal',
                    icon: Icons.handshake_outlined,
                    seleccionado: _aceptaInformal,
                    onTap: () => setState(
                        () => _aceptaInformal = !_aceptaInformal),
                  ),
                  EtiquetaInclusionChip(
                    label: 'Acepta PEP / PPT',
                    icon: Icons.assignment_ind_outlined,
                    seleccionado: _aceptaPepPpt,
                    onTap: () => setState(
                        () => _aceptaPepPpt = !_aceptaPepPpt),
                  ),
                  EtiquetaInclusionChip(
                    label: 'Horario flexible',
                    icon: Icons.schedule_outlined,
                    seleccionado: _horarioFlexible,
                    onTap: () => setState(
                        () => _horarioFlexible = !_horarioFlexible),
                  ),
                  EtiquetaInclusionChip(
                    label: 'Incluye formación',
                    icon: Icons.school_outlined,
                    seleccionado: _incluyeFormacion,
                    onTap: () => setState(
                        () =>
                            _incluyeFormacion = !_incluyeFormacion),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.cargando ? null : _guardar,
                  child: vm.cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white))
                      : const Text('Guardar cambios'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
