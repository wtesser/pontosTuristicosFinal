import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import '../model/pontos_turisticos.dart';

class DatabaseProvider {
  static const _dbName = 'cadastro_tarefasV1.db';
  static const _dbVersion = 1;

  DatabaseProvider._init();
  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _database;


  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = '$databasesPath/$_dbName';
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE ${PontosTuristicos.NOME_TABELA} (
        ${PontosTuristicos.CAMPO_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${PontosTuristicos.CAMPO_DESCRICAO} TEXT NOT NULL,
        ${PontosTuristicos.CAMPO_NOME} TEXT,
        ${PontosTuristicos.CAMPO_DIFERENCIAIS} TEXT,
        ${PontosTuristicos.CAMPO_INCLUSAO} TEXT,
        ${PontosTuristicos.CAMPO_LATITUDE} TEXT,
        ${PontosTuristicos.CAMPO_LONGITUDE} TEXT,
        ${PontosTuristicos.CAMPO_CEP} TEXT
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {

  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
