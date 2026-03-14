import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, 'vendedores_tm.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombreCompleto TEXT,
        correoOTelefono TEXT NOT NULL UNIQUE,
        contrasenaHash TEXT NOT NULL,
        aceptoPolitica INTEGER NOT NULL DEFAULT 0,
        fechaRegistro TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE perfiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarioId INTEGER NOT NULL UNIQUE,
        nivelEducativo TEXT,
        experienciaLaboral TEXT,
        habilidades TEXT,
        areasInteres TEXT,
        modalidadPreferida TEXT,
        jornadaPreferida TEXT,
        perfilCompleto INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (usuarioId) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE consentimientos_privacidad (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarioId INTEGER NOT NULL,
        fechaAceptacion TEXT NOT NULL,
        versionPolitica TEXT NOT NULL DEFAULT '1.0',
        FOREIGN KEY (usuarioId) REFERENCES usuarios(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE vacantes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL, descripcion TEXT, empresa TEXT,
        categoria TEXT, modalidad TEXT, jornada TEXT,
        salarioReferencial TEXT, requisitos TEXT,
        fechaCierre TEXT, activa INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('CREATE INDEX idx_vacantes_categoria ON vacantes(categoria)');
    await db.execute('CREATE INDEX idx_vacantes_modalidad ON vacantes(modalidad)');
    await db.execute('''
      CREATE TABLE postulaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarioId INTEGER NOT NULL, vacanteId INTEGER NOT NULL,
        fechaPostulacion TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'Enviada',
        UNIQUE(usuarioId, vacanteId),
        FOREIGN KEY (usuarioId) REFERENCES usuarios(id),
        FOREIGN KEY (vacanteId) REFERENCES vacantes(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE vacantes_guardadas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarioId INTEGER NOT NULL, vacanteId INTEGER NOT NULL,
        fechaGuardado TEXT NOT NULL,
        UNIQUE(usuarioId, vacanteId),
        FOREIGN KEY (usuarioId) REFERENCES usuarios(id),
        FOREIGN KEY (vacanteId) REFERENCES vacantes(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE formacion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL, entidad TEXT, modalidad TEXT,
        duracion TEXT, categoria TEXT, descripcion TEXT
      )
    ''');
    await _sembrarVacantes(db);
    await _sembrarFormacion(db);
  }

  Future<void> _sembrarVacantes(Database db) async {
    final datos = [
      {'titulo': 'Vendedor/a punto de venta', 'descripcion': 'Atención al cliente en local comercial del centro de Bogotá.', 'empresa': 'Tiendas Don Alirio', 'categoria': 'ventas', 'modalidad': 'presencial', 'jornada': 'tiempo completo', 'salarioReferencial': '\$1.300.000', 'requisitos': 'Bachiller, experiencia en ventas, disponibilidad inmediata.', 'fechaCierre': '2026-05-30', 'activa': 1},
      {'titulo': 'Auxiliar de cocina', 'descripcion': 'Apoyo en preparación de alimentos y limpieza de cocina.', 'empresa': 'Restaurante El Sabor', 'categoria': 'gastronomía', 'modalidad': 'presencial', 'jornada': 'medio tiempo', 'salarioReferencial': '\$700.000', 'requisitos': 'Sin experiencia requerida, ganas de aprender.', 'fechaCierre': '2026-04-15', 'activa': 1},
      {'titulo': 'Mensajero/a en moto', 'descripcion': 'Entregas de paquetes en zona norte de Bogotá.', 'empresa': 'Domicilios Express', 'categoria': 'logística', 'modalidad': 'presencial', 'jornada': 'por horas', 'salarioReferencial': '\$50.000 por día', 'requisitos': 'Moto propia, licencia A2, responsabilidad.', 'fechaCierre': '2026-04-30', 'activa': 1},
      {'titulo': 'Asesor/a de servicios al cliente', 'descripcion': 'Atención telefónica y presencial a clientes.', 'empresa': 'Contact Center Bogotá', 'categoria': 'servicios', 'modalidad': 'híbrida', 'jornada': 'tiempo completo', 'salarioReferencial': '\$1.400.000', 'requisitos': 'Bachiller, buena comunicación, disponibilidad por turnos.', 'fechaCierre': '2026-06-01', 'activa': 1},
      {'titulo': 'Empacador/a supermercado', 'descripcion': 'Empaque y organización de productos en cadena de supermercados.', 'empresa': 'Supermercados La Canasta', 'categoria': 'ventas', 'modalidad': 'presencial', 'jornada': 'medio tiempo', 'salarioReferencial': '\$650.000', 'requisitos': 'Mayor de edad, puntualidad.', 'fechaCierre': '2026-05-15', 'activa': 1},
      {'titulo': 'Operario/a de aseo', 'descripcion': 'Limpieza de instalaciones de oficinas en el norte de Bogotá.', 'empresa': 'Aseo Total Ltda.', 'categoria': 'servicios', 'modalidad': 'presencial', 'jornada': 'tiempo completo', 'salarioReferencial': '\$1.160.000', 'requisitos': 'Mayor de edad, responsabilidad, experiencia deseable.', 'fechaCierre': '2026-05-01', 'activa': 1},
      {'titulo': 'Auxiliar de bodega', 'descripcion': 'Recepción, almacenamiento y despacho de mercancías.', 'empresa': 'Distribuidora Bogotá S.A.S', 'categoria': 'logística', 'modalidad': 'presencial', 'jornada': 'tiempo completo', 'salarioReferencial': '\$1.250.000', 'requisitos': 'Bachiller, experiencia en bodega o similar.', 'fechaCierre': '2026-06-15', 'activa': 1},
    ];
    for (final v in datos) {
      await db.insert('vacantes', v);
    }
  }

  Future<void> _sembrarFormacion(Database db) async {
    final datos = [
      {'titulo': 'Atención al cliente y ventas', 'entidad': 'SENA', 'modalidad': 'Virtual', 'duracion': '40 horas', 'categoria': 'ventas', 'descripcion': 'Aprende técnicas de servicio al cliente, manejo de quejas y estrategias de ventas efectivas. Certificado por el SENA al finalizar.'},
      {'titulo': 'Manipulación de alimentos', 'entidad': 'SENA', 'modalidad': 'Presencial', 'duracion': '20 horas', 'categoria': 'gastronomía', 'descripcion': 'Normas de higiene, BPM (Buenas Prácticas de Manufactura) y manejo seguro de alimentos para trabajar en el sector gastronómico.'},
      {'titulo': 'Excel básico para el trabajo', 'entidad': 'IPES Bogotá', 'modalidad': 'Presencial', 'duracion': '16 horas', 'categoria': 'herramientas digitales', 'descripcion': 'Manejo de hojas de cálculo, fórmulas básicas y organización de información. Ideal para personas sin experiencia previa en computadores.'},
      {'titulo': 'Emprendimiento e ideas de negocio', 'entidad': 'Cámara de Comercio de Bogotá', 'modalidad': 'Virtual', 'duracion': '30 horas', 'categoria': 'emprendimiento', 'descripcion': 'Cómo identificar oportunidades de negocio, crear un modelo de negocio básico y acceder a créditos para emprendedores.'},
      {'titulo': 'Conducción segura y normas de tránsito', 'entidad': 'Secretaría de Movilidad', 'modalidad': 'Presencial', 'duracion': '12 horas', 'categoria': 'logística', 'descripcion': 'Normas de tránsito, señales viales y conducción defensiva para mensajeros y conductores de reparto en Bogotá.'},
      {'titulo': 'Primeros auxilios básicos', 'entidad': 'Cruz Roja Colombiana', 'modalidad': 'Presencial', 'duracion': '8 horas', 'categoria': 'servicios', 'descripcion': 'RCP, manejo de heridas, quemaduras y emergencias básicas. Certificado reconocido a nivel nacional.'},
      {'titulo': 'Comunicación asertiva en el trabajo', 'entidad': 'IPES Bogotá', 'modalidad': 'Virtual', 'duracion': '10 horas', 'categoria': 'habilidades blandas', 'descripcion': 'Cómo comunicarse de forma clara y efectiva con clientes, compañeros y jefes. Manejo de conflictos y trabajo en equipo.'},
      {'titulo': 'Auxiliar de construcción', 'entidad': 'SENA', 'modalidad': 'Presencial', 'duracion': '80 horas', 'categoria': 'construcción', 'descripcion': 'Mezclas de concreto, manejo de herramientas, seguridad en obras y normas básicas de construcción. Certificación técnica SENA.'},
    ];
    for (final f in datos) {
      await db.insert('formacion', f);
    }
  }
}
