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

    final empresaVm = context.read<EmpresaViewModel>();
    final empresa = empresaVm.empresaActual!;

    final vacante = VacanteEmpresaModel(
      empresaId: empresa.id!,
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

    final ok = await context.read<VacanteEmpresaViewModel>().publicar(vacante);

    if (ok && mounted) {
      context.push('/empresa/publicar-confirmacion', extra: {
        'titulo': _tituloCtrl.text.trim(),
        'validada': empresa.validado,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresa = context.watch<EmpresaViewModel>().empresaActual;
    final vm = context.watch<VacanteEmpresaViewModel>();

    // ── Gate: empresa no validada ─────────────────────────────
    if (empresa != null && !empresa.validado) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Publicar vacante'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.go('/empresa/dashboard'),
          ),
        ),
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFFFFCC02).withOpacity(0.5)),
                  ),
                  child: const Icon(
                    Icons.lock_clock_outlined,
                    color: Color(0xFFE65100),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Empresa pendiente de validación',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Para publicar vacantes tu empresa debe estar validada por el equipo de Formalia.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFCC80)),
                  ),
                  child: const Column(
                    children: [
                      _PasoValidacion(
                        numero: '1',
                        texto: 'Tu empresa fue registrada exitosamente.',
                        completado: true,
                      ),
                      SizedBox(height: 12),
                      _PasoValidacion(
                        numero: '2',
                        texto:
                            'El equipo de Vendedores TM revisará tu información y la validará en un plazo de 1 a 3 días hábiles.',
                        completado: false,
                      ),
                      SizedBox(height: 12),
                      _PasoValidacion(
                        numero: '3',
                        texto:
                            'Una vez validada, podrás publicar vacantes y comenzar a recibir postulantes.',
                        completado: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/empresa/dashboard'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver al inicio'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Formulario normal (empresa validada) ──────────────────
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar vacante'),
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
                  hintText: r'Ej: $1.300.000 - $1.500.000',
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

// ── Widget auxiliar: paso del proceso de validación ───────────
class _PasoValidacion extends StatelessWidget {
  final String numero;
  final String texto;
  final bool completado;

  const _PasoValidacion({
    required this.numero,
    required this.texto,
    required this.completado,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: completado
                ? const Color(0xFF2E7D32)
                : const Color(0xFFE65100).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: completado
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : Text(
                    numero,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              color: completado
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              height: 1.5,
              fontWeight:
                  completado ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Pantalla de confirmación ──────────────────────────────────
class VacantePublicadaScreen extends StatelessWidget {
  final String titulo;
  final bool empresaValidada;

  const VacantePublicadaScreen({
    super.key,
    required this.titulo,
    required this.empresaValidada,
  });

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

              // ── Ícono de éxito ──────────────────────────────
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF2E7D32).withOpacity(0.3),
                        width: 2),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF2E7D32),
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Título ──────────────────────────────────────
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

              // ── Banner de estado: validada vs pendiente ─────
              if (empresaValidada)
                _BannerEstado(
                  icono: Icons.visibility_outlined,
                  iconoColor: const Color(0xFF1565C0),
                  fondo: const Color(0xFFE3F2FD),
                  borde: const Color(0xFF90CAF9),
                  titulo: 'Vacante publicada y visible',
                  cuerpo:
                      'Tu vacante ya está disponible para los candidatos en la sección de Vacantes. Los postulantes podrán encontrarla y postularse de inmediato.',
                  tituloColor: const Color(0xFF1565C0),
                  cuerpoColor: const Color(0xFF37474F),
                )
              else
                _BannerEstado(
                  icono: Icons.lock_clock_outlined,
                  iconoColor: const Color(0xFFE65100),
                  fondo: const Color(0xFFFFF8E1),
                  borde: const Color(0xFFFFCC02),
                  titulo: 'Pendiente: empresa no validada',
                  cuerpo:
                      'Esta vacante quedó guardada pero no será visible para los candidatos hasta que el equipo de Vendedores TM valide tu empresa.',
                  tituloColor: const Color(0xFFE65100),
                  cuerpoColor: const Color(0xFF6D4C41),
                ),

              const SizedBox(height: 14),

              // ── Info adicional ──────────────────────────────
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
                        'Puedes gestionar tus vacantes desde la sección '
                        '"Mis vacantes" en el panel de tu empresa.',
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

              // ── Acciones ────────────────────────────────────
              ElevatedButton.icon(
                onPressed: () => context.go('/empresa/publicar'),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Publicar otra vacante'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/empresa/dashboard'),
                icon: const Icon(Icons.dashboard_outlined),
                label: const Text('Volver al panel'),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Banner de estado reutilizable ─────────────────────────────
class _BannerEstado extends StatelessWidget {
  final IconData icono;
  final Color iconoColor;
  final Color fondo;
  final Color borde;
  final String titulo;
  final String cuerpo;
  final Color tituloColor;
  final Color cuerpoColor;

  const _BannerEstado({
    required this.icono,
    required this.iconoColor,
    required this.fondo,
    required this.borde,
    required this.titulo,
    required this.cuerpo,
    required this.tituloColor,
    required this.cuerpoColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borde),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: iconoColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: tituloColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  cuerpo,
                  style: TextStyle(
                    fontSize: 13,
                    color: cuerpoColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
