import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_ui.dart';
import '../../viewmodels/postulacion_viewmodel.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostulacionViewModel>().cargarHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PostulacionViewModel>();

    final novedades = vm.historial.where((p) {
      final e = p['estado'] as String? ?? '';
      return e == 'Aceptada' || e == 'Rechazada';
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis postulaciones',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<PostulacionViewModel>().cargarHistorial(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: vm.state == PostulacionState.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.historial.isEmpty
              ? const AppEmptyState(
                  icon: Icons.list_alt_outlined,
                  title: 'Aún no te has postulado',
                  description:
                      'Explora las vacantes disponibles y postúlate. '
                      'Aquí verás el seguimiento de cada proceso.',
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<PostulacionViewModel>().cargarHistorial(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: vm.historial.length +
                        (novedades.isNotEmpty ? 2 : 1),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      if (index == 0) {
                        return _BannerInfo(
                            conNovedades: novedades.isNotEmpty,
                            totalNovedades: novedades.length);
                      }

                      if (novedades.isNotEmpty && index == 1) {
                        return _BannerNovedades(novedades: novedades);
                      }

                      final offset = novedades.isNotEmpty ? 2 : 1;
                      final postulacion = vm.historial[index - offset];
                      return _TarjetaPostulacion(
                          postulacion: postulacion);
                    },
                  ),
                ),
    );
  }
}

// ── Banner info ───────────────────────────────────────────────
class _BannerInfo extends StatelessWidget {
  final bool conNovedades;
  final int totalNovedades;
  const _BannerInfo(
      {required this.conNovedades, required this.totalNovedades});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.track_changes_outlined,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              conNovedades
                  ? 'Tienes $totalNovedades ${totalNovedades == 1 ? 'respuesta nueva' : 'respuestas nuevas'} de empresas. Revísalas abajo.'
                  : 'Aquí puedes seguir el estado de cada proceso en el que participas.',
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banner de novedades (aceptadas / rechazadas) ──────────────
class _BannerNovedades extends StatelessWidget {
  final List<Map<String, dynamic>> novedades;
  const _BannerNovedades({required this.novedades});

  @override
  Widget build(BuildContext context) {
    final aceptadas =
        novedades.where((p) => p['estado'] == 'Aceptada').toList();
    final rechazadas =
        novedades.where((p) => p['estado'] == 'Rechazada').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.notifications_active_outlined,
                  size: 16, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'Novedades',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3),
              ),
            ],
          ),
        ),
        ...aceptadas.map((p) => _ChipNovedad(
              postulacion: p,
              aceptada: true,
            )),
        ...rechazadas.map((p) => _ChipNovedad(
              postulacion: p,
              aceptada: false,
            )),
        const SizedBox(height: 8),
        const _Separador(texto: 'Todas las postulaciones'),
      ],
    );
  }
}

class _ChipNovedad extends StatelessWidget {
  final Map<String, dynamic> postulacion;
  final bool aceptada;
  const _ChipNovedad(
      {required this.postulacion, required this.aceptada});

  @override
  Widget build(BuildContext context) {
    final color = aceptada ? AppColors.success : AppColors.error;
    final titulo = postulacion['titulo'] as String? ?? '';
    final empresa = postulacion['empresa'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              aceptada ? Icons.check_circle : Icons.cancel,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aceptada
                      ? '¡Tu postulación fue aceptada!'
                      : 'Tu postulación no avanzó',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$titulo · $empresa',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Separador extends StatelessWidget {
  final String texto;
  const _Separador({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(texto,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

// ── Tarjeta individual de postulación ─────────────────────────
class _TarjetaPostulacion extends StatelessWidget {
  final Map<String, dynamic> postulacion;
  const _TarjetaPostulacion({required this.postulacion});

  String get _estado =>
      postulacion['estado'] as String? ?? 'Enviada';

  Color get _colorEstado {
    switch (_estado) {
      case 'Aceptada':  return AppColors.success;
      case 'Rechazada': return AppColors.error;
      case 'Vista':     return AppColors.warning;
      default:          return AppColors.primary;
    }
  }

  IconData get _iconoEstado {
    switch (_estado) {
      case 'Aceptada':  return Icons.check_circle_rounded;
      case 'Rechazada': return Icons.cancel_rounded;
      case 'Vista':     return Icons.visibility_rounded;
      default:          return Icons.send_rounded;
    }
  }

  String get _mensajeEstado {
    switch (_estado) {
      case 'Aceptada':
        return '¡Felicitaciones! La empresa aceptó tu postulación. Usa los datos de contacto de abajo para coordinar los siguientes pasos.';
      case 'Rechazada':
        return 'La empresa decidió no avanzar con tu candidatura en este proceso.';
      case 'Vista':
        return 'La empresa ya revisó tu postulación. Pronto sabrás la respuesta.';
      default:
        return 'Tu postulación fue enviada y está en revisión.';
    }
  }

  String _formatFecha(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  // Normaliza un número colombiano para WhatsApp (agrega 57 si no lo tiene)
  String _normalizarTelefono(String raw) {
    var tel = raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (tel.startsWith('+')) tel = tel.substring(1);
    if (tel.startsWith('57') && tel.length >= 11) return tel;
    if (tel.startsWith('3') && tel.length == 10) return '57$tel';
    return tel;
  }

  Future<void> _abrirWhatsApp(String telefono, String nombreEmpresa) async {
    final tel = _normalizarTelefono(telefono);
    final titulo = postulacion['titulo'] as String? ?? 'la vacante';
    final mensaje = Uri.encodeComponent(
      'Hola, te escribimos de $nombreEmpresa por tu postulación a "$titulo" en Formalia.',
    );
    final uri = Uri.parse('https://wa.me/$tel?text=$mensaje');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _abrirCorreo(String correo) async {
    final titulo = postulacion['titulo'] as String? ?? 'la vacante';
    final asunto = Uri.encodeComponent('Postulación a "$titulo" en Formalia');
    final uri = Uri.parse('mailto:$correo?subject=$asunto');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titulo     = postulacion['titulo'] as String? ?? '';
    final empresa    = postulacion['empresa'] as String? ?? '';
    final categoria  = postulacion['categoria'] as String? ?? '';
    final modalidad  = postulacion['modalidad'] as String? ?? '';
    final fecha      = _formatFecha(
        postulacion['fechaPostulacion'] as String? ?? '');

    // Datos de contacto de la empresa (solo presentes si estado == Aceptada)
    final empresaCorreo    = postulacion['empresa_correo'] as String?;
    final empresaTelefono  = postulacion['empresa_telefono'] as String?;
    final tieneContacto    = _estado == 'Aceptada' &&
        (empresaCorreo != null || empresaTelefono != null);

    final bool destacada =
        _estado == 'Aceptada' || _estado == 'Rechazada';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: destacada
              ? _colorEstado.withOpacity(0.35)
              : AppColors.border,
          width: destacada ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _colorEstado.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(_iconoEstado,
                      color: _colorEstado, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        empresa,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.primary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                // Badge estado
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _colorEstado.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _estado,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _colorEstado,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Chips de info ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (categoria.isNotEmpty)
                  _InfoChip(Icons.category_outlined, categoria),
                if (modalidad.isNotEmpty)
                  _InfoChip(Icons.laptop_outlined, modalidad),
                _InfoChip(Icons.calendar_today_outlined, fecha),
              ],
            ),
          ),

          // ── Mensaje de estado ────────────────────────────
          Container(
            margin: EdgeInsets.fromLTRB(16, 12, 16, tieneContacto ? 0 : 14),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _colorEstado.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: _colorEstado.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  destacada
                      ? (_estado == 'Aceptada'
                          ? Icons.celebration_outlined
                          : Icons.info_outline)
                      : Icons.info_outline,
                  size: 15,
                  color: _colorEstado,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _mensajeEstado,
                    style: TextStyle(
                      fontSize: 12,
                      color: _colorEstado,
                      height: 1.4,
                      fontWeight: destacada
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Contacto de empresa (solo cuando Aceptada) ───
          if (tieneContacto)
            _SeccionContactoEmpresa(
              nombreEmpresa: empresa,
              correo: empresaCorreo,
              telefono: empresaTelefono,
              onWhatsApp: empresaTelefono != null
                  ? () => _abrirWhatsApp(empresaTelefono, empresa)
                  : null,
              onCorreo: empresaCorreo != null
                  ? () => _abrirCorreo(empresaCorreo)
                  : null,
            ),
        ],
      ),
    );
  }
}

// ── Sección de contacto de la empresa ────────────────────────
class _SeccionContactoEmpresa extends StatelessWidget {
  final String nombreEmpresa;
  final String? correo;
  final String? telefono;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onCorreo;

  const _SeccionContactoEmpresa({
    required this.nombreEmpresa,
    this.correo,
    this.telefono,
    this.onWhatsApp,
    this.onCorreo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.success.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de sección
          Row(
            children: [
              const Icon(Icons.contact_phone_outlined,
                  size: 15, color: AppColors.success),
              const SizedBox(width: 6),
              Text(
                'Contacto de $nombreEmpresa',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Datos de contacto
          if (telefono != null)
            _FilaContacto(
                icono: Icons.phone_outlined,
                valor: telefono!),
          if (correo != null) ...[
            if (telefono != null) const SizedBox(height: 4),
            _FilaContacto(
                icono: Icons.email_outlined,
                valor: correo!),
          ],

          const SizedBox(height: 12),

          // Botones de acción
          Row(
            children: [
              if (onWhatsApp != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onWhatsApp,
                    icon: const Icon(Icons.chat_rounded, size: 16),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              if (onWhatsApp != null && onCorreo != null)
                const SizedBox(width: 8),
              if (onCorreo != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCorreo,
                    icon: const Icon(Icons.mail_outline, size: 16),
                    label: const Text('Correo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                          color: AppColors.primary.withOpacity(0.4)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
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

class _FilaContacto extends StatelessWidget {
  final IconData icono;
  final String valor;
  const _FilaContacto({required this.icono, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Info chip ─────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _InfoChip(this.icono, this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(texto,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
