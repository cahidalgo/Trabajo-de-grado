import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PoliticaPrivacidadScreen extends StatelessWidget {
  const PoliticaPrivacidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de privacidad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Encabezado ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.privacy_tip_outlined, color: Colors.white, size: 36),
                  SizedBox(height: 12),
                  Text(
                    'Política de Privacidad',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Versión 1.0 — Vendedores TM',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Última actualización: marzo de 2026',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Aviso de ley ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFB300)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.gavel_outlined, color: Color(0xFFE65100), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Esta política está elaborada en cumplimiento de la Ley 1581 de 2012 '
                      '(Ley de Protección de Datos Personales) y el Decreto 1377 de 2013 '
                      'de la República de Colombia.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6D4C41)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Secciones ───────────────────────────────────────────────
            _PoliticaSeccion(
              numero: '1',
              titulo: 'Responsable del tratamiento',
              contenido:
                  'REEMPLAZA ESTE TEXTO con el nombre de tu institución/proyecto, '
                  'NIT o documento de identificación, dirección, correo electrónico '
                  'de contacto y teléfono del responsable del tratamiento de datos.',
            ),
            _PoliticaSeccion(
              numero: '2',
              titulo: 'Datos personales que recopilamos',
              contenido:
                  'La aplicación Vendedores TM recopila los siguientes datos personales:\n\n'
                  '• Nombre completo\n'
                  '• Número de celular o correo electrónico\n'
                  '• Nivel educativo\n'
                  '• Experiencia laboral\n'
                  '• Habilidades personales\n'
                  '• Áreas de interés laboral\n'
                  '• Preferencias de modalidad y jornada de trabajo\n\n'
                  'No recopilamos datos sensibles como origen racial, '
                  'orientación sexual, datos biométricos ni información financiera.',
            ),
            _PoliticaSeccion(
              numero: '3',
              titulo: 'Finalidad del tratamiento',
              contenido:
                  'Los datos recopilados se utilizarán exclusivamente para:\n\n'
                  '• Crear y gestionar tu cuenta de usuario\n'
                  '• Conectarte con oportunidades de empleo formal\n'
                  '• Personalizar el listado de vacantes según tu perfil\n'
                  '• Registrar y hacer seguimiento a tus postulaciones\n'
                  '• Sugerirte cursos y programas de formación pertinentes\n\n'
                  'Tus datos NO serán usados para publicidad, '
                  'vendidos a terceros ni compartidos sin tu consentimiento expreso.',
            ),
            _PoliticaSeccion(
              numero: '4',
              titulo: 'Almacenamiento y seguridad',
              contenido:
                  'Tus datos se almacenan de forma local en tu dispositivo '
                  'mediante una base de datos SQLite cifrada. Las contraseñas '
                  'se almacenan usando el algoritmo SHA-256 y nunca en texto plano.\n\n'
                  'En versiones futuras que incluyan sincronización en la nube, '
                  'se aplicarán medidas de seguridad adicionales y se actualizará '
                  'esta política.',
            ),
            _PoliticaSeccion(
              numero: '5',
              titulo: 'Tus derechos (Ley 1581 de 2012)',
              contenido:
                  'Como titular de tus datos personales, tienes derecho a:\n\n'
                  '• Conocer los datos que tenemos sobre ti\n'
                  '• Actualizarlos o corregirlos desde "Mi perfil"\n'
                  '• Solicitar su eliminación cerrando tu cuenta\n'
                  '• Revocar la autorización de tratamiento en cualquier momento\n'
                  '• Presentar quejas ante la Superintendencia de Industria y Comercio (SIC)\n\n'
                  'Para ejercer estos derechos, escríbenos a: '
                  'REEMPLAZA CON TU CORREO DE CONTACTO',
            ),
            _PoliticaSeccion(
              numero: '6',
              titulo: 'Consentimiento',
              contenido:
                  'Al marcar la casilla "He leído y acepto la política de privacidad" '
                  'durante el registro, otorgas tu consentimiento libre, previo, '
                  'expreso e informado para el tratamiento de tus datos personales '
                  'según los términos descritos en esta política.',
            ),
            _PoliticaSeccion(
              numero: '7',
              titulo: 'Menores de edad',
              contenido:
                  'Esta aplicación está dirigida a personas mayores de 18 años. '
                  'No recopilamos datos de menores de edad de forma intencional. '
                  'Si detectamos que un menor ha creado una cuenta, procederemos '
                  'a eliminarla de inmediato.',
            ),
            _PoliticaSeccion(
              numero: '8',
              titulo: 'Cambios a esta política',
              contenido:
                  'Nos reservamos el derecho de actualizar esta política. '
                  'Cualquier cambio relevante será notificado mediante un aviso '
                  'visible dentro de la aplicación antes de entrar en vigencia. '
                  'La versión actual siempre estará disponible en esta sección.',
            ),
            _PoliticaSeccion(
              numero: '9',
              titulo: 'Contacto',
              contenido:
                  'Para cualquier consulta, solicitud o reclamo relacionado con '
                  'el tratamiento de tus datos personales, comunícate con nosotros:\n\n'
                  '📧 REEMPLAZA CON TU CORREO\n'
                  '📞 REEMPLAZA CON TU TELÉFONO\n'
                  '🏢 REEMPLAZA CON TU DIRECCIÓN',
            ),

            const SizedBox(height: 16),
            // ── Footer ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Superintendencia de Industria y Comercio (SIC)\n'
                'Entidad de vigilancia y control en Colombia\n'
                'www.sic.gov.co',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PoliticaSeccion extends StatelessWidget {
  final String numero;
  final String titulo;
  final String contenido;
  const _PoliticaSeccion({
    required this.numero,
    required this.titulo,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(numero,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          title: Text(titulo,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(contenido,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
          ],
        ),
      ),
    );
  }
}
