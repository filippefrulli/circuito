import 'dart:io' show Directory;
import 'package:circuito/objects/car.dart';
import 'package:circuito/objects/circuit.dart';
import 'package:circuito/objects/lap_result.dart';
import 'package:circuito/objects/race.dart';
import 'package:circuito/objects/timed_challenge.dart';
import 'package:circuito/objects/timed_race_section.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;

class DatabaseHelper {
  static const _databaseName = "circuito.db";
  static const _databaseVersion = 1;

  static const carsTable = 'cars';
  static const circuitsTable = 'circuits';
  static const racesTable = 'races';
  static const lapResultsTable = 'lap_results';
  static const timedChallengeTable = 'timed_challenges';
  static const timedRaceSectionsTable = 'timed_race_sections';

  static const carId = 'id';
  static const carName = 'name';
  static const carYear = 'year';
  static const carImage = 'image';

  static const circuitId = 'id';
  static const circuitName = 'name';

  static const raceId = 'id';
  static const raceName = 'name';
  static const raceCarId = 'car';
  static const raceCircuitId = 'circuit';
  static const raceType = 'type';
  static const raceStatus = 'status';
  static const raceTimestamp = 'timestamp';

  static const lapResultId = 'id';
  static const lapResultRaceId = 'race_id';
  static const lapResultLapNumber = 'lap_number';
  static const lapResultCompletionTime = 'completion_time';
  static const lapResultTimeDifference = 'time_difference';
  static const lapResultTimestamp = 'timestamp';

  static const sectionId = 'id';
  static const sectionRaceId = 'race_id';
  static const sectionName = 'name';

  static const timedChallengeId = 'id';
  static const timedChallengeSectionId = 'section_id';
  static const timedChallengeCompletionTime = 'completion_time';
  static const timedChallengeRank = 'rank';

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
            $circuitName TEXT NOT NULL
          )
          ''');

    await db.execute('''
      CREATE TABLE $racesTable (
        $raceId INTEGER PRIMARY KEY AUTOINCREMENT,
        $raceName TEXT NOT NULL,
        $raceCarId INTEGER NOT NULL,
        $raceCircuitId INTEGER NOT NULL,
        $raceType INTEGER NOT NULL,
        $raceStatus INTEGER DEFAULT 0,
        $raceTimestamp TEXT NOT NULL,
        FOREIGN KEY ($raceCarId) REFERENCES $carsTable ($carId)
          ON DELETE CASCADE,
        FOREIGN KEY ($raceCircuitId) REFERENCES $circuitsTable ($circuitId)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $lapResultsTable (
        $lapResultId INTEGER PRIMARY KEY AUTOINCREMENT,
        $lapResultRaceId INTEGER NOT NULL,
        $lapResultLapNumber INTEGER NOT NULL,
        $lapResultCompletionTime INTEGER NOT NULL,
        $lapResultTimeDifference INTEGER NOT NULL,
        $lapResultTimestamp TEXT NOT NULL,
        FOREIGN KEY ($lapResultRaceId) REFERENCES $racesTable ($raceId)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $timedRaceSectionsTable (
        $sectionId INTEGER PRIMARY KEY AUTOINCREMENT,
        $sectionRaceId INTEGER NOT NULL,
        $sectionName TEXT NOT NULL,
        FOREIGN KEY ($sectionRaceId) REFERENCES $racesTable ($raceId)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $timedChallengeTable (
        $timedChallengeId INTEGER PRIMARY KEY AUTOINCREMENT,
        $timedChallengeSectionId INTEGER NOT NULL,
        $timedChallengeCompletionTime INTEGER NOT NULL,
        $timedChallengeRank INTEGER NOT NULL,
        FOREIGN KEY ($timedChallengeSectionId) REFERENCES $timedRaceSectionsTable ($sectionId)
          ON DELETE CASCADE,
        UNIQUE($timedChallengeSectionId, $timedChallengeRank)
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

  Future<int> insertRace(Race race) async {
    Database? db = await database;
    return await db!.insert(racesTable, race.toMap());
  }

  Future<int> insertLapResult(LapResult lapResult) async {
    Database? db = await database;
    return await db!.insert(lapResultsTable, lapResult.toMap());
  }

  Future<int> insertSection(TimedRaceSection section) async {
    Database? db = await database;
    return await db!.insert(timedRaceSectionsTable, section.toMap());
  }

  Future<int> getNextRankForSection(int sectionId) async {
    Database? db = await database;

    try {
      final result = await db!.rawQuery('''
      SELECT COALESCE(MAX($timedChallengeRank), 0) + 1 as nextRank 
      FROM $timedChallengeTable 
      WHERE $timedChallengeSectionId = ?
    ''', [sectionId]);

      return Sqflite.firstIntValue(result) ?? 1;
    } catch (e) {
      throw Exception('Failed to get next rank: $e');
    }
  }

  Future<int> insertTimedChallenge(TimedChallenge challenge) async {
    Database? db = await database;

    try {
      final nextRank = await getNextRankForSection(challenge.sectionId!);
      final challengeMap = challenge.toMap();
      challengeMap[timedChallengeRank] = nextRank;

      return await db!.insert(timedChallengeTable, challengeMap);
    } catch (e) {
      throw Exception('Failed to insert challenge: $e');
    }
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
      );
    });
  }

  Future<List<Race>> getRaces() async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(racesTable);

    return List.generate(maps.length, (i) {
      return Race(
        id: maps[i][raceId],
        name: maps[i][raceName],
        car: maps[i][raceCarId],
        circuit: maps[i][raceCircuitId],
        type: maps[i][raceType],
        status: maps[i][raceStatus],
        timestamp: maps[i][raceTimestamp],
      );
    });
  }

  Future<Race> getRaceById(int id) async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      racesTable,
      where: '$raceId = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw Exception('Race not found');
    }

    return Race.fromMap(maps.first);
  }

  Future<List<LapResult>> getLapResultsByRaceId(int raceId) async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      lapResultsTable,
      where: '$lapResultRaceId = ?',
      whereArgs: [raceId],
      orderBy: '$lapResultLapNumber ASC',
    );

    return List.generate(maps.length, (i) {
      return LapResult.fromMap(maps[i]);
    });
  }

  Future<List<TimedRaceSection>> getSectionsByRaceId(int raceId) async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      timedRaceSectionsTable,
      where: '$sectionRaceId = ?',
      whereArgs: [raceId],
      orderBy: '$sectionName ASC',
    );

    return List.generate(maps.length, (i) {
      return TimedRaceSection.fromMap(maps[i]);
    });
  }

  Future<TimedRaceSection> getSectionById(int id) async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      timedRaceSectionsTable,
      where: '$sectionId = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw Exception('Section not found');
    }

    return TimedRaceSection.fromMap(maps.first);
  }

  Future<List<TimedChallenge>> getChallengesBySectionId(int raceId) async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      timedChallengeTable,
      where: '$timedChallengeSectionId = ?',
      whereArgs: [raceId],
      orderBy: '$timedChallengeRank ASC',
    );

    return List.generate(maps.length, (i) {
      return TimedChallenge.fromMap(maps[i]);
    });
  }

  Future<void> updateChallengeRanks(List<TimedChallenge> challenges) async {
    Database? db = await database;

    await db!.transaction(
      (txn) async {
        // First update all ranks to temporary negative values
        for (var i = 0; i < challenges.length; i++) {
          await txn.update(
            timedChallengeTable,
            {timedChallengeRank: -(i + 1)},
            where: '$timedChallengeId = ?',
            whereArgs: [challenges[i].id],
          );
        }

        // Then update to final positive values
        for (var i = 0; i < challenges.length; i++) {
          await txn.update(
            timedChallengeTable,
            {timedChallengeRank: i + 1},
            where: '$timedChallengeId = ?',
            whereArgs: [challenges[i].id],
          );
        }
      },
    );
  }
}
