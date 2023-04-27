import 'package:flutter/cupertino.dart';
import 'package:prova_pm26s/model/turist_spots.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static const _dbName = 'db_turist_spots_test.db';
  static const _dbVersion = 2;

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
      CREATE TABLE ${TuristSpots.TABLE_NAME} (
        ${TuristSpots.FIELD_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TuristSpots.FIELD_NAME} TEXT NOT NULL,
        ${TuristSpots.FIELD_CEP} TEXT NOT NULL,
        ${TuristSpots.FIELD_WORKING_HOURS} TEXT NOT NULL,
        ${TuristSpots.FIELD_DIFFERENTIAL} TEXT,
        ${TuristSpots.FIELD_URL_PHOTO} TEXT,
        ${TuristSpots.FIELD_LATITUDE} TEXT,
        ${TuristSpots.FIELD_LONGITUDE} TEXT,
        ${TuristSpots.FIELD_CREATE_AT} TEXT NOT NULL);
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    switch (oldVersion) {
      // case 1:
      //   await db.execute('''
      //   ALTER TABLE ${TuristSpots.TABLE_NAME}
      //   ADD ${TuristSpots.NEW_FIELD} INTEGER NOT NULL DEFAULT 0;
      //   ''');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
