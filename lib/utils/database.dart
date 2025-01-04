import 'dart:io' show Directory;
import 'package:circuito/objects/car.dart';
import 'package:circuito/objects/circuit.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;

class DatabaseHelper {
  static const _databaseName = "circuito.db";
  static const _databaseVersion = 1;

  static const carsTable = 'cars';
  static const circuitsTable = 'circuits';

  static const carId = 'id';
  static const carName = 'name';
  static const carYear = 'year';
  static const carImage = 'image';

  static const circuitId = 'id';
  static const circuitName = 'name';
  static const circuitCountry = 'country';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreateTables, onConfigure: _onConfigure);
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // SQL code to create the database table
  Future _onCreateTables(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $carsTable (
            $carId INTEGER PRIMARY KEY,
            $carName TEXT NOT NULL,
            $carYear INTEGER NOT NULL,
            $carImage TEXT NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE $circuitsTable (
            $circuitId INTEGER PRIMARY KEY,
            $circuitName TEXT NOT NULL,
            $circuitCountry TEXT NOT NULL
          )
          ''');
  }

  Future<int> insertCar(Car car) async {
    Database? db = await database;
    return await db!.insert(carsTable, car.toMap());
  }

  Future<int> insertCircuit(Circuit circuit) async {
    Database? db = await database;
    return await db!.insert(circuitsTable, circuit.toMap());
  }

  Future<List<Car>> getCars() async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(carsTable);

    return List.generate(maps.length, (i) {
      return Car(
        id: maps[i]['id'],
        name: maps[i]['name'],
        year: maps[i]['year'],
        image: maps[i]['image'],
      );
    });
  }

  Future<List<Circuit>> getCircuits() async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(circuitsTable);

    return List.generate(maps.length, (i) {
      return Circuit(
        id: maps[i]['id'],
        name: maps[i]['name'],
        country: maps[i]['country'],
      );
    });
  }
}
