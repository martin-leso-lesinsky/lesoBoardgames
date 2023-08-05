import 'package:flutter/foundation.dart';
import 'package:leso_board_games/services/get_hra.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/hra_model.dart';

String bgUserName = '';
String gamesCount = '';
String expansionsCount = '';
String playsCount = '';

class HrasDatabase {
  static final HrasDatabase instance = HrasDatabase._init();

  static Database? _database;

  HrasDatabase._init();
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('hras.db');
    return _database!;
  }

  bool newGameAdded = false;
  bool newExpansionAdded = false;
  bool newPlaysAdded = false;

  void setNewGameAdded() {
    newGameAdded = true;
  }

  void setNewExpansionAdded() {
    newExpansionAdded = true;
  }

  void setNewPlaysAdded() {
    newPlaysAdded = true;
  }

  void resetNewFlags() {
    newGameAdded = false;
    newExpansionAdded = false;
    newPlaysAdded = false;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const textType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE $tableHras (
      ${HraFields.objectId} $integerType,
      ${HraFields.subtype} $textType,
      ${HraFields.collId} $textType,
      ${HraFields.name} $textType,
      ${HraFields.yearPublished} $textType,
      ${HraFields.image} $textType,
      ${HraFields.thumbnail} $textType,
      ${HraFields.statusOwn} $integerType,
      ${HraFields.numPlays} $integerType,
      ${HraFields.gameValue} INTEGER DEFAULT 0,
      ${HraFields.obtainDate} TEXT DEFAULT "1900"
    )
  ''');
  }

  Future<Hra> create(Hra hra) async {
    final db = await instance.database;
    final objectId = await db.insert(tableHras, hra.toJson());
    return hra.copy(objectId: objectId);
  }

  Future<Hra?> readHra(int id) async {
    final db = await instance.database;

    final maps = await db.query(tableHras,
        columns: HraFields.values,
        where: '${HraFields.objectId}=?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Hra.fromJson(maps.first);
    } else {
      /// throw Exception('ID $id not found')
      return null;
    }
  }

  Future<List<Hra>> readAllHra() async {
    final db = await instance.database;

    const orderBy = '${HraFields.objectId} ASC';

    final result = await db.query(tableHras, orderBy: orderBy);

    return result.map((json) => Hra.fromJson(json)).toList();
  }

  Future<int> update(Hra hra) async {
    final db = await instance.database;

    return db.update(
      tableHras,
      hra.toJson(),
      where: '${HraFields.objectId} = ?',
      whereArgs: [hra.objectId],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableHras,
      where: '${HraFields.objectId} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

  /// Get total Value from Games
  Future<List<String>> getAllGamesValue() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT gameValue FROM hras WHERE subtype = ?', ['boardgame']);
    return List.generate(maps.length, (i) {
      return maps[i]['gameValue'] as String;
    });
  }

  /// Get total Value from Expansions
  Future<List<String>> getAllExpansionsValue() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT gameValue FROM hras WHERE subtype = ?', ['boardgameexpansion']);
    return List.generate(maps.length, (i) {
      return maps[i]['gameValue'] as String;
    });
  }

  /// POpulate Db for User
  Future<void> populateDatabaseFromApi(bgUserName) async {
    /// Fetch the games from the API using get_hra.dart
    final dbPath = await getDatabasesPath();
    final dbFilePath = join(dbPath, 'hras.db');

    final expList =
        await fetchGamesFromApi(bgUserName, 'subtype=boardgameexpansion');
    if (kDebugMode) {
      print("Fetch Expansions Complete");
      expansionsCount = (expList.length).toString();
      print(expansionsCount);
    }

    final hraList = await fetchGamesFromApi(
        bgUserName, 'subtype=boardgame&excludesubtype=boardgameexpansion');
    if (kDebugMode) {
      print("Fetch Games Complete");
      gamesCount = (hraList.length).toString();

      /// Calculate the sum of all plays
      int totalPlays = 0;
      for (final hra in hraList) {
        totalPlays += hra.numPlays;
      }
      playsCount = totalPlays.toString();

      print(gamesCount);
      print(playsCount);
    }

    /// Insert the fetched data into the database if it doesn't already exist
    final db = await instance.database;

    bool newGameAdded = false;
    for (final hra in hraList) {
      /// Check if the Game with the same objectId already exists in the database
      final existingHra = await readHra(hra.objectId);
      if (existingHra == null) {
        await db.insert(tableHras, hra.toJson());
        newGameAdded = true;
      }
    }
    if (newGameAdded == true) {
      print("Added new Games");
    } else {
      print("Games are OK");
    }

    bool newExpansionAdded = false;
    for (final hra in expList) {
      /// Check if the Expansion with the same objectId already exists in the database
      final existingExpansion = await readHra(hra.objectId);
      if (existingExpansion == null) {
        await db.insert(tableHras, hra.toJson());
        newExpansionAdded = true;
      }
    }
    if (newExpansionAdded == true) {
      print("Added new Expansion");
    } else {
      print("Expansions are OK");
    }
  }

  /// get Hras Count
  Future<int?> getHrasCount() async {
    final db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableHras'));
  }

  /// Delete Data
  Future<void> deleteData() async {
    final db = await instance.database;

    await db.delete('hras');
  }
}
