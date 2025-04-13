import 'dart:io' show Directory;
import 'package:circuito/objects/car.dart';
import 'package:circuito/objects/circuit.dart';
import 'package:circuito/objects/lap_result.dart';
import 'package:circuito/objects/race.dart';
import 'package:circuito/objects/timed_challenge.dart';
import 'package:circuito/objects/timed_challenge_result.dart';
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
  static const raceResultsTable = 'race_results';
  static const lapResultsTable = 'lap_results';
  static const timedChallengeTable = 'timed_challenges';
  static const timedRaceSectionsTable = 'timed_race_sections';
  static const timedChallengeResultsTable = 'timed_challenge_results';

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
  static const raceCreatedAt = 'created_at';

  static const raceResultId = 'id';
  static const raceResultRaceId = 'race';
  static const raceResultLapsFastestLap = 'fastest_lap';
  static const raceResultLapsAverageLapTime = 'average_lap_time';
  static const raceResultTimedFinalTime = 'final_time';
  static const raceResultTimedFinalScore = 'final_score';

  static const lapResultId = 'id';
  static const lapResultRaceId = 'race_id';
  static const lapResultLapNumber = 'lap_number';
  static const lapResultCompletionTime = 'completion_time';
  static const lapResultTimeDifference = 'time_difference';
  static const lapResultCreatedAt = 'created_at';

  static const sectionId = 'id';
  static const sectionRaceId = 'race_id';
  static const sectionName = 'name';
  static const sectionResult = 'result';
  static const sectionCompleted = 'completed';

  static const timedChallengeId = 'id';
  static const timedChallengeSectionId = 'section_id';
  static const timedChallengeCompletionTime = 'completion_time';
  static const timedChallengeRank = 'rank';

  static const challengeResultId = 'id';
  static const challengeResultChallengeId = 'challenge_id';
  static const challengeResultCompletionTime = 'completion_time';
  static const challengeResultTimeDifference = 'time_difference';
  static const challengeResultRank = 'rank';
  static const challengeResultCreatedAt = 'created_at';

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
        $raceCreatedAt TEXT NOT NULL,
        FOREIGN KEY ($raceCarId) REFERENCES $carsTable ($carId)
          ON DELETE CASCADE,
        FOREIGN KEY ($raceCircuitId) REFERENCES $circuitsTable ($circuitId)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $raceResultsTable (
        $raceResultId INTEGER PRIMARY KEY AUTOINCREMENT,
        $raceResultRaceId INTEGER NOT NULL,
        $raceResultLapsFastestLap INTEGER,
        $raceResultLapsAverageLapTime INTEGER,
        $raceResultTimedFinalTime INTEGER,
        $raceResultTimedFinalScore INTEGER,
        FOREIGN KEY ($raceResultRaceId) REFERENCES $racesTable ($raceId)
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
        $lapResultCreatedAt TEXT NOT NULL,
        FOREIGN KEY ($lapResultRaceId) REFERENCES $racesTable ($raceId)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $timedRaceSectionsTable (
        $sectionId INTEGER PRIMARY KEY AUTOINCREMENT,
        $sectionRaceId INTEGER NOT NULL,
        $sectionName TEXT NOT NULL,
        $sectionResult INTEGER,
        $sectionCompleted INTEGER DEFAULT 0,
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

    await db.execute('''
      CREATE TABLE $timedChallengeResultsTable (
        $challengeResultId INTEGER PRIMARY KEY AUTOINCREMENT,
        $challengeResultChallengeId INTEGER NOT NULL,
        $challengeResultCompletionTime INTEGER NOT NULL,
        $challengeResultTimeDifference INTEGER NOT NULL,
        $challengeResultCreatedAt TEXT NOT NULL,
        $challengeResultRank INTEGER NOT NULL,
        FOREIGN KEY ($challengeResultChallengeId) REFERENCES $timedChallengeTable ($timedChallengeId)
          ON DELETE CASCADE
      )
    ''');
  }

  /* ----- CARS ----- */

  Future<int> insertCar(Car car) async {
    Database? db = await database;
    return await db!.insert(carsTable, car.toMap());
  }

  Future<List<Car>> getCars() async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(carsTable);

    return List.generate(maps.length, (i) {
      return Car.fromMap(maps[i]);
    });
  }

  /* ----- CIRCUITS ----- */

  Future<int> insertCircuit(Circuit circuit) async {
    Database? db = await database;
    return await db!.insert(circuitsTable, circuit.toMap());
  }

  Future<List<Circuit>> getCircuits() async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(circuitsTable);

    return List.generate(maps.length, (i) {
      return Circuit.fromMap(maps[i]);
    });
  }

  /* ----- RACES ----- */

  Future<int> insertRace(Race race) async {
    Database? db = await database;
    return await db!.insert(racesTable, race.toMap());
  }

  Future<List<Race>> getRaces() async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(racesTable);

    return List.generate(maps.length, (i) {
      return Race.fromMap(maps[i]);
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

  Future<int> deleteRace(int id) async {
    Database? db = await database;
    return await db!.delete(
      racesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> endRace(int id) async {
    Database? db = await database;

    await db!.transaction(
      (txn) async {
        await txn.update(
          racesTable,
          {raceStatus: 1},
          where: '$raceId = ?',
          whereArgs: [id],
        );
      },
    );
  }

  Future<List<Race>> getIncompleteRaces() async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      racesTable,
      where: '$raceStatus = ?',
      whereArgs: [0],
      orderBy: '$raceCreatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Race.fromMap(maps[i]);
    });
  }

  Future<List<Race>> getCompletedRaces() async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      racesTable,
      where: '$raceStatus = ?',
      whereArgs: [1],
      orderBy: '$raceCreatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Race.fromMap(maps[i]);
    });
  }

  /* ----- RACE RESULTS ----- */

  Future<int> insertRaceResult(
    int raceId,
    int? fastestLap,
    int? averageLapTime,
    int? finalTime,
    int? finalScore,
  ) async {
    Database? db = await database;

    return await db!.insert(
      raceResultsTable,
      {
        raceResultRaceId: raceId,
        if (fastestLap != null) raceResultLapsFastestLap: fastestLap,
        if (averageLapTime != null) raceResultLapsAverageLapTime: averageLapTime,
        if (finalTime != null) raceResultTimedFinalTime: finalTime,
        if (finalScore != null) raceResultTimedFinalScore: finalScore,
      },
    );
  }

  Future<Map<String, dynamic>?> getRaceResults(int raceId) async {
    Database? db = await database;

    final results = await db!.query(
      raceResultsTable,
      where: '$raceResultRaceId = ?',
      whereArgs: [raceId],
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  /* ----- LAP RESULTS ----- */

  Future<int> insertLapResult(LapResult lapResult) async {
    Database? db = await database;
    return await db!.insert(lapResultsTable, lapResult.toMap());
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

  /* ----- SECTIONS ----- */

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

  Future<void> markSectionAsCompleted(int id, int raceId, {int? timeDifference}) async {
    Database? db = await database;

    final updateMap = {
      sectionCompleted: 1,
    };

    // Add time difference if provided
    if (timeDifference != null) {
      updateMap[sectionResult] = timeDifference;
    }

    await db!.transaction(
      (txn) async {
        await txn.update(
          timedRaceSectionsTable,
          updateMap,
          where: '$sectionId = ?',
          whereArgs: [id],
        );
      },
    );

    // Update the race results
    if (timeDifference != null) {
      await updateRaceResultsForSection(id, raceId, timeDifference);
    }
  }

  Future<void> updateRaceResultsForSection(int sectionId, int raceId, int timeDifference) async {
    Database? db = await database;
    int totalTimeDifference = 0;

    await db!.transaction((txn) async {
      // Get all sections for this race
      final allSections = await txn.query(
        timedRaceSectionsTable,
        where: '$sectionRaceId = ?',
        whereArgs: [raceId],
      );

      // Check if all sections are completed
      final sections = allSections.map((map) => TimedRaceSection.fromMap(map)).toList();

      // Calculate total time difference across all completed sections
      for (var section in sections) {
        if (section.completed == 1) {
          totalTimeDifference += section.result;
        }
      }

      // Check if race result already exists
      final existingResults = await txn.query(
        raceResultsTable,
        where: '$raceResultRaceId = ?',
        whereArgs: [raceId],
      );

      // Update race results table
      final resultData = {
        raceResultTimedFinalTime: totalTimeDifference,
      };

      if (existingResults.isEmpty) {
        resultData[raceResultRaceId] = raceId;
        await txn.insert(raceResultsTable, resultData);
      } else {
        await txn.update(
          raceResultsTable,
          resultData,
          where: '$raceResultRaceId = ?',
          whereArgs: [raceId],
        );
      }
    });

    await calculateFinalScore(raceId, totalTimeDifference);
  }

  Future<void> calculateFinalScore(int raceId, int totalTime) async {
    Database? db = await database;

    try {
      // Step 1: Get the race to find the car ID
      final race = await getRaceById(raceId);
      final carId = race.car;

      // Step 2: Get the car to find its year
      final cars = await db!.query(
        carsTable,
        where: '$carId = ?',
        whereArgs: [carId],
      );

      if (cars.isEmpty) {
        throw Exception('Car not found');
      }

      final car = Car.fromMap(cars.first);
      final carYear = car.year;

      // Step 4: Calculate coefficient based on car year (year / 100)
      final coefficient = (carYear % 100) / 100 + 1;

      // Step 5: Calculate final score
      // Multiply time by 100, then by coefficient
      final finalScore = ((totalTime / 10) * coefficient).round();

      // Step 6: Update race results with the final score
      await db.update(
        raceResultsTable,
        {raceResultTimedFinalScore: finalScore},
        where: '$raceResultRaceId = ?',
        whereArgs: [raceId],
      );
    } catch (e) {
      throw Exception('Failed to calculate final score: $e');
    }
  }

  Future<List<TimedRaceSection>> getSectionsByRaceId(int raceId) async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      timedRaceSectionsTable,
      where: '$sectionRaceId = ?',
      whereArgs: [raceId],
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

  /* ----- TIMED CHALLENGES ----- */

  Future<int> insertTimedChallengeResult(TimedChallengeResult result) async {
    Database? db = await database;
    return await db!.insert(timedChallengeResultsTable, result.toMap());
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

  Future<List<TimedChallenge>> getChallengesBySectionId(int raceId) async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      timedChallengeTable,
      where: '$timedChallengeSectionId = ?',
      whereArgs: [raceId],
      orderBy: '$timedChallengeRank ASC',
    );

    return List.generate(
      maps.length,
      (i) {
        return TimedChallenge.fromMap(maps[i]);
      },
    );
  }

  Future<List<TimedChallengeResult>> getTimedChallengeResultByChallengeId(int challengeId) async {
    Database? db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db!.query(
        timedChallengeResultsTable,
        where: '$challengeResultChallengeId = ?',
        whereArgs: [challengeId],
        orderBy: '$challengeResultCreatedAt DESC',
      );

      return List.generate(
        maps.length,
        (i) {
          return TimedChallengeResult.fromMap(maps[i]);
        },
      );
    } catch (e) {
      throw Exception('Failed to get challenge results: $e');
    }
  }
}
