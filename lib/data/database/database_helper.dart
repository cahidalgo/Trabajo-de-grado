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
    final path = join(dbPath, 'vendedores_tm.db');
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
        titulo TEXT NOT NULL,
        descripcion TEXT,
        empresa TEXT,
        categoria TEXT,
        modalidad TEXT,
        jornada TEXT,
        salarioReferencial TEXT,
        requisitos TEXT,
        fechaCierre TEXT,
        activa INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('CREATE INDEX idx_vacantes_categoria ON vacantes(categoria)');
    await db.execute('CREATE INDEX idx_vacantes_modalidad ON vacantes(modalidad)');

    await db.execute('''
      CREATE TABLE postulaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarioId INTEGER NOT NULL,
        vacanteId INTEGER NOT NULL,
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
        usuarioId INTEGER NOT NULL,
        vacanteId INTEGER NOT NULL,
        fechaGuardado TEXT NOT NULL,
        UNIQUE(usuarioId, vacanteId),
        FOREIGN KEY (usuarioId) REFERENCES usuarios(id),
        FOREIGN KEY (vacanteId) REFERENCES vacantes(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE formacion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        entidad TEXT,
        modalidad TEXT,
        duracion TEXT,
        categoria TEXT,
        descripcion TEXT
      )
    ''');

    await _sembrarDatos(db);
  }

  // Datos de prueba para vacantes (sin API externa aún)
  Future<void> _sembrarDatos(Database db) async {
    final vacantes = [
      {
        'titulo': 'Vendedor/a punto de venta',
        'descripcion': 'Atención al cliente en local comercial del centro de Bogotá.',
        'empresa': 'Tiendas Don Alirio',
        'categoria': 'ventas',
        'modalidad': 'presencial',
        'jornada': 'tiempo completo',
        'salarioReferencial': '1.300.000',
        'requisitos': 'Bachiller, experiencia en ventas, disponibilidad inmediata.',
        'fechaCierre': '2026-05-30',
        'activa': 1,
      },
      {
        'titulo': 'Auxiliar de cocina',
        'descripcion': 'Apoyo en preparación de alimentos en restaurante.',
        'empresa': 'Restaurante El Sabor',
        'categoria': 'gastronomía',
        'modalidad': 'presencial',
        'jornada': 'medio tiempo',
        'salarioReferencial': '700.000',
        'requisitos': 'Sin experiencia requerida, ganas de aprender.',
        'fechaCierre': '2026-04-15',
        'activa': 1,
      },
      {
        'titulo': 'Mensajero/a en moto',
        'descripcion': 'Entregas de paquetes en zona norte de Bogotá.',
        'empresa': 'Domicilios Express',
        'categoria': 'logística',
        'modalidad': 'presencial',
        'jornada': 'por horas',
        'salarioReferencial': '50.000 por día',
        'requisitos': 'Moto propia, licencia A2, responsabilidad.',
        'fechaCierre': '2026-04-30',
        'activa': 1,
      },
      {
        'titulo': 'Asesor/a de servicios al cliente',
        'descripcion': 'Atención telefónica y presencial a clientes.',
        'empresa': 'Contact Center Bogotá',
        'categoria': 'servicios',
        'modalidad': 'híbrida',
        'jornada': 'tiempo completo',
        'salarioReferencial': '1.400.000',
        'requisitos': 'Bachiller, buena comunicación, disponibilidad turnos.',
        'fechaCierre': '2026-06-01',
        'activa': 1,
      },
      {
        'titulo': 'Empacador/a supermercado',
        'descripcion': 'Empaque y organización de productos en cadena de supermercados.',
        'empresa': 'Supermercados La Canasta',
        'categoria': 'ventas',
        'modalidad': 'presencial',
        'jornada': 'medio tiempo',
        'salarioReferencial': '650.000',
        'requisitos': 'Mayor de edad, puntualidad.',
        'fechaCierre': '2026-05-15',
        'activa': 1,
      },
    ];

    for (final v in vacantes) {
      await db.insert('vacantes', v);
    }
  }
}
