import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/empresa_viewmodel.dart';
import '../../viewmodels/vacante_empresa_viewmodel.dart';
import '../../data/models/vacante_empresa_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/etiqueta_inclusion_chip.dart';

class PublicarVacanteScreen extends StatefulWidget {
  const PublicarVacanteScreen({super.key});

  @override
  State<PublicarVacanteScreen> createState() =>
      _PublicarVacanteScreenState();
}

class _PublicarVacanteScreenState extends State<PublicarVacanteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _salarioCtrl = TextEditingController();

  String _sector = 'Ventas y comercio';
  String _modalidad = 'Presencial';
  String _jornada = 'Tiempo completo';
  String? _zonaPortal;
  DateTime? _fechaCierre;

  bool _aceptaInformal = false;
  bool _aceptaPepPpt = false;
  bool _horarioFlexible = false;
  bool _incluyeFormacion = false;

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
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _salarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 15)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) setState(() => _fechaCierre = fecha);
  }

  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaCierre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha de cierre')),
      );
      return;
    }

    final empresaId =
        context.read<EmpresaViewModel>().empresaActual!.id!;

    final vacante = VacanteEmpresaModel(
      empresaId: empresaId,
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      sector: _sector,
      modalidad: _modalidad,
      jornada: _jornada,
      salarioReferencial: _salarioCtrl.text.trim().isEmpty
          ? null
          : _salarioCtrl.text.trim(),
      fechaCierre: _fechaCierre!.toIso8601String(),
      aceptaExperienciaInformal: _aceptaInformal,
      aceptaPepPpt: _aceptaPepPpt,
      horarioFlexible: _horarioFlexible,
      zonaPortal: _zonaPortal,
      incluyeFormacion: _incluyeFormacion,
      fechaPublicacion: DateTime.now().toIso8601String(),
    );

    final ok =
        await context.read<VacanteEmpresaViewModel>().publicar(vacante);

    if (ok && mounted) {
      context.push(
        '/empresa/publicar-confirmacion',
        extra: _tituloCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VacanteEmpresaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar vacante'),
        // ── Botón retroceder ──────────────────────────────────
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/empresa/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información de la vacante',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _tituloCtrl,
                decoration:
                    const InputDecoration(labelText: 'Título del cargo'),
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
                decoration: const InputDecoration(labelText: 'Sector'),
                items: _sectores
                    .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _sector = v!),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _modalidad,
                decoration:
                    const InputDecoration(labelText: 'Modalidad'),
                items: _modalidades
                    .map((m) =>
                        DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _modalidad = v!),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _jornada,
                decoration:
                    const InputDecoration(labelText: 'Jornada'),
                items: _jornadas
                    .map((j) =>
                        DropdownMenuItem(value: j, child: Text(j)))
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
                    .map((p) =>
                        DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _zonaPortal = v),
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
              const Text(
                'Etiquetas de inclusión',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Marca las condiciones que aplican. Esto ayuda a los '
                'candidatos a identificar si la vacante es adecuada '
                'para su situación.',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
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
                        () => _incluyeFormacion = !_incluyeFormacion),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              if (vm.errorMensaje != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vm.errorMensaje!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.cargando ? null : _publicar,
                  child: vm.cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Publicar vacante'),
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

// ── Pantalla de confirmación ──────────────────────────────────────────────────
class VacantePublicadaScreen extends StatelessWidget {
  final String titulo;
  const VacantePublicadaScreen({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF2E7D32).withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF2E7D32),
                    size: 44,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '¡Vacante registrada!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '"$titulo"',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFCC02)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.access_time_outlined,
                        color: Color(0xFFE65100), size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pendiente de validación',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Esta vacante aún no será visible para los '
                            'candidatos en la sección de Vacantes. '
                            'Estará disponible una vez que tu empresa '
                            'sea validada por el equipo de Formalia.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6D4C41),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Puedes ver tus vacantes registradas en la '
                        'sección "Mis vacantes" de tu perfil de empresa.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () => context.go(
                  '/empresa/publicar',
                  extra: DateTime.now().millisecondsSinceEpoch.toString(),
                ),
                child: const Text('Publicar otra vacante'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/empresa/dashboard'),
                child: const Text('Volver al inicio'),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
