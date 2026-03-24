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
            // ── Encabezado ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.privacy_tip_outlined,
                      color: Colors.white, size: 36),
                  SizedBox(height: 12),
                  Text(
                    'Política de Privacidad',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Formalia MVP — Versión 1.0',
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
            const SizedBox(height: 20),

            // ── Aviso legal ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFCC02)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.gavel_outlined,
                      color: Color(0xFFE65100), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Elaborada en cumplimiento de la Ley 1581 de 2012 '
                      '(Ley de Protección de Datos Personales) y el '
                      'Decreto 1377 de 2013 de la República de Colombia.',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF6D4C41)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Secciones ───────────────────────────────────────────
            _PoliticaSeccion(
              numero: '1',
              titulo: 'Responsable del tratamiento',
              contenido:
                  'Responsables: Andrés Gómez Cardona, Carlos Andrés Hidalgo Bolaños\n\n'
                  'Domicilio: Bogotá D.C., Colombia\n\n'
                  'Contacto:\n'
                  '• agomez35@ucatolica.edu.co\n'
                  '• cahidalgo18@ucatolica.edu.co',
            ),
            _PoliticaSeccion(
              numero: '2',
              titulo: 'Objeto',
              contenido:
                  'La presente Política de Privacidad tiene por objeto informar a las '
                  'personas usuarias de la aplicación sobre la recolección, almacenamiento, '
                  'uso, circulación, actualización y supresión de sus datos personales, así '
                  'como sobre los mecanismos disponibles para ejercer sus derechos.',
            ),
            _PoliticaSeccion(
              numero: '3',
              titulo: 'Alcance',
              contenido:
                  'Esta política aplica al tratamiento de los datos personales de las '
                  'personas que usan la aplicación Formalia, especialmente aquellas que se '
                  'registran para crear un perfil, consultar vacantes, postularse a '
                  'oportunidades laborales o recibir información asociada a formación y '
                  'empleabilidad.',
            ),
            _PoliticaSeccion(
              numero: '4',
              titulo: 'Datos personales que se pueden recolectar',
              contenido:
                  'a. Datos de identificación y contacto\n'
                  '• Nombres y apellidos\n'
                  '• Tipo y número de documento\n'
                  '• Número de teléfono\n'
                  '• Correo electrónico\n'
                  '• Ciudad o localidad\n\n'
                  'b. Datos del perfil laboral\n'
                  '• Nivel educativo\n'
                  '• Experiencia laboral u ocupacional\n'
                  '• Habilidades\n'
                  '• Intereses laborales\n'
                  '• Hoja de vida o información equivalente\n'
                  '• Estado de postulaciones\n\n'
                  'c. Datos técnicos de uso\n'
                  '• Información básica del dispositivo\n'
                  '• Fecha y hora de acceso\n'
                  '• Registros de interacción con funcionalidades del MVP\n'
                  '• Errores técnicos o de funcionamiento\n\n'
                  'd. Datos opcionales\n'
                  '• Fotografía de perfil\n'
                  '• Ubicación aproximada, únicamente si la funcionalidad es activada por la persona usuaria\n'
                  '• Documentos adjuntos para procesos de postulación, cuando aplique',
            ),
            _PoliticaSeccion(
              numero: '5',
              titulo: 'Finalidades del tratamiento',
              contenido:
                  '• Crear y administrar la cuenta de usuario.\n'
                  '• Permitir la construcción y actualización del perfil laboral.\n'
                  '• Facilitar la consulta de vacantes, oportunidades de formación o procesos de empleabilidad.\n'
                  '• Permitir la postulación a ofertas laborales y el seguimiento de dichas postulaciones.\n'
                  '• Validar información registrada por la persona usuaria dentro del MVP.\n'
                  '• Brindar soporte técnico, atención a solicitudes, consultas o reclamos.\n'
                  '• Mejorar la usabilidad, accesibilidad y funcionamiento del MVP.\n'
                  '• Generar estadísticas o reportes académicos o de mejora del sistema, procurando que no identifiquen indebidamente a personas concretas.\n'
                  '• Cumplir obligaciones legales o requerimientos de autoridad competente, cuando sea procedente.',
            ),
            _PoliticaSeccion(
              numero: '6',
              titulo: 'Tratamiento de datos sensibles',
              contenido:
                  'La aplicación no solicitará datos sensibles salvo que ello resulte '
                  'estrictamente necesario para una finalidad legítima, específica e informada. '
                  'En caso de llegar a requerirse datos sensibles, su entrega será facultativa '
                  'y se informará previamente a la persona titular la finalidad concreta del tratamiento.',
            ),
            _PoliticaSeccion(
              numero: '7',
              titulo: 'Autorización del titular',
              contenido:
                  'Mediante la aceptación de la presente política y/o el registro en la '
                  'aplicación, la persona usuaria autoriza de manera previa, expresa e '
                  'informada el tratamiento de sus datos personales para las finalidades '
                  'aquí descritas.\n\n'
                  'La persona usuaria declara que la información suministrada es veraz, '
                  'completa y actualizada, y se compromete a reportar cualquier cambio relevante.',
            ),
            _PoliticaSeccion(
              numero: '8',
              titulo: 'Almacenamiento y seguridad',
              contenido:
                  'El proyecto adoptará medidas técnicas, humanas y administrativas '
                  'razonables para proteger los datos personales contra acceso no autorizado, '
                  'pérdida, uso indebido, alteración o divulgación no autorizada.\n\n'
                  'En la versión actual del MVP, parte de la información podrá almacenarse '
                  'localmente en el dispositivo o en entornos controlados de prueba. '
                  'Si en futuras versiones se incorporan servidores, servicios en la nube '
                  'o integraciones con terceros, esta política deberá actualizarse.',
            ),
            _PoliticaSeccion(
              numero: '9',
              titulo: 'Circulación y entrega de datos a terceros',
              contenido:
                  'Como regla general, los datos personales no serán vendidos, '
                  'comercializados ni cedidos a terceros ajenos a la finalidad del proyecto.\n\n'
                  'Los datos solo podrán ser compartidos en los siguientes casos:\n'
                  '• Con autorización previa del titular.\n'
                  '• Cuando sea necesario para ejecutar una funcionalidad autorizada por la persona usuaria.\n'
                  '• Cuando exista obligación legal o requerimiento de autoridad competente.\n'
                  '• Con proveedores tecnológicos o aliados bajo deberes de confidencialidad, si llegaren a intervenir en versiones futuras.',
            ),
            _PoliticaSeccion(
              numero: '10',
              titulo: 'Derechos de los titulares',
              contenido:
                  'La persona titular de los datos personales podrá ejercer los derechos de:\n\n'
                  '• Conocer qué datos personales están siendo tratados.\n'
                  '• Solicitar actualización o rectificación de la información.\n'
                  '• Solicitar prueba de la autorización otorgada.\n'
                  '• Ser informada sobre el uso dado a sus datos.\n'
                  '• Solicitar la supresión de los datos cuando proceda.\n'
                  '• Revocar la autorización, cuando proceda.\n'
                  '• Presentar consultas o reclamos ante el responsable del tratamiento.\n'
                  '• Acudir ante la Superintendencia de Industria y Comercio (SIC), '
                  'una vez agotado el trámite directo ante el responsable.',
            ),
            _PoliticaSeccion(
              numero: '11',
              titulo: 'Procedimiento para consultas y reclamos',
              contenido:
                  'Las consultas, solicitudes o reclamos podrán presentarse al correo:\n'
                  'cahidalgo18@ucatolica.edu.co\n\n'
                  'Indicando como mínimo:\n'
                  '• Nombre completo del titular\n'
                  '• Medio de contacto\n'
                  '• Descripción clara de la solicitud\n'
                  '• Documentos o soportes, si aplican\n\n'
                  'Los tiempos de respuesta se manejarán conforme a la normativa colombiana vigente.',
            ),
            _PoliticaSeccion(
              numero: '12',
              titulo: 'Conservación de la información',
              contenido:
                  'Los datos personales serán conservados únicamente durante el tiempo '
                  'necesario para cumplir las finalidades descritas en esta política, '
                  'para atender obligaciones legales, académicas, técnicas o de soporte, '
                  'y posteriormente podrán ser eliminados, anonimizados o bloqueados '
                  'según corresponda.',
            ),
            _PoliticaSeccion(
              numero: '13',
              titulo: 'Datos de niños, niñas y adolescentes',
              contenido:
                  'La aplicación no está dirigida de manera principal a niños, niñas o '
                  'adolescentes. En caso de tratar información de menores de edad, ello '
                  'solo se realizará cuando sea legalmente procedente y con las '
                  'autorizaciones correspondientes. La ley colombiana restringe el '
                  'tratamiento de datos personales de menores, salvo ciertos datos '
                  'de naturaleza pública.',
            ),
            _PoliticaSeccion(
              numero: '14',
              titulo: 'Uso con fines académicos y de mejora',
              contenido:
                  'Dado que este MVP se desarrolla en el marco de un proyecto académico '
                  'y tecnológico, cierta información podrá ser utilizada para análisis '
                  'de funcionamiento, validación del prototipo, evaluación de usabilidad, '
                  'mejora de experiencia de usuario y documentación del proyecto, siempre '
                  'bajo criterios de confidencialidad y minimización del dato.',
            ),
            _PoliticaSeccion(
              numero: '15',
              titulo: 'Cambios a esta política',
              contenido:
                  'El responsable podrá modificar la presente Política de Privacidad '
                  'cuando sea necesario para ajustarla a cambios normativos, funcionales '
                  'o técnicos del MVP. Cuando los cambios sean sustanciales, se informará '
                  'oportunamente a las personas usuarias por los medios disponibles dentro '
                  'de la aplicación o a través del canal de contacto registrado.',
            ),

            const SizedBox(height: 16),

            // ── Footer ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Icon(Icons.account_balance_outlined,
                      color: AppColors.textSecondary, size: 22),
                  SizedBox(height: 8),
                  Text(
                    'Superintendencia de Industria y Comercio (SIC)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Entidad de vigilancia y control en Colombia\nwww.sic.gov.co',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Sección expandible ────────────────────────────────────────────────────────
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              numero,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          title: Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              contenido,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}