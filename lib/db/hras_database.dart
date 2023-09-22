import 'package:flutter/foundation.dart';
import 'package:leso_board_games/models/expansion_model.dart';
import 'package:leso_board_games/services/get_hra.dart';
import 'package:leso_board_games/services/get_hra_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/hra_model.dart';

String bgUserName = '';

/// remove when all will work
int gamesCount = 0;

/// remove when all will work
int expansionsCount = 0;

/// remove when all will work
int playsCount = 0;

enum GameSubtype {
  all,
  boardgame,
  accessories,
  boardgameexpansion,
}

class YearlyGameData {
  final int year;
  final num sumValue;
  final int barCounterValue;

  YearlyGameData(this.year, this.sumValue, this.barCounterValue);
}

class HrasDatabase {
  static final HrasDatabase instance = HrasDatabase._init();

  static Database? _database;

  HrasDatabase._init();
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('hras.db');
    return _database!;
  }

  /// Calculate and store total values for games and expansions in shared preferences
  Future<void> calculateAndStoreTotalValues() async {
    final db = await instance.database;

    /// Get the total gameValue, count, and total number of plays for games from the database
    final gamesValueAndCount = await db.rawQuery(
      'SELECT SUM(gameValue) AS totalValue, COUNT(*) AS totalCount, SUM(numPlays) AS totalPlays FROM $tableHras WHERE subtype = ?',
      ['boardgame'],
    );

    /// Get the total gameValue, count, and total number of plays for expansions from the database
    final expansionsValueAndCount = await db.rawQuery(
      'SELECT SUM(gameValue) AS totalValue, COUNT(*) AS totalCount, SUM(numPlays) AS totalPlays FROM $tableHras WHERE subtype = ?',
      ['boardgameexpansion'],
    );

    // Calculate total values and counts
    num totalValueGames = 0;
    int totalCountGames = 0;
    int totalCountPlaysGames = 0;
    if (gamesValueAndCount.isNotEmpty && gamesValueAndCount[0]['totalValue'] != null) {
      totalValueGames = gamesValueAndCount[0]['totalValue'] as num;
      totalCountGames = gamesValueAndCount[0]['totalCount'] as int;
      totalCountPlaysGames = gamesValueAndCount[0]['totalPlays'] as int;
    }

    num totalValueExpansions = 0;
    int totalCountExpansions = 0;
    if (expansionsValueAndCount.isNotEmpty && expansionsValueAndCount[0]['totalValue'] != null) {
      totalValueExpansions = expansionsValueAndCount[0]['totalValue'] as num;
      totalCountExpansions = expansionsValueAndCount[0]['totalCount'] as int;
    }

    /// Calculate and store total ordered counts based on StatusOwn
    int totalCountOrderedGames = 0;
    int totalCountOrderedExpansions = 0;

    final ownGames = await db.rawQuery(
      'SELECT COUNT(*) AS totalCount FROM $tableHras WHERE subtype = ? AND statusOwn = ?',
      ['boardgame', 0],
    );

    final ownExpansions = await db.rawQuery(
      'SELECT COUNT(*) AS totalCount FROM $tableHras WHERE subtype = ? AND statusOwn = ?',
      ['boardgameexpansion', 0],
    );

    if (ownGames.isNotEmpty) {
      totalCountOrderedGames = ownGames[0]['totalCount'] as int;
    }

    if (ownExpansions.isNotEmpty) {
      totalCountOrderedExpansions = ownExpansions[0]['totalCount'] as int;
    }

    /// Store total values and counts in shared preferences
    final prefs = await SharedPreferences.getInstance();

    /// 0. ===> Total ordered counts in shared preferences
    prefs.setInt('totalCountOrderedGames', totalCountOrderedGames);
    prefs.setInt('totalCountOrderedExpansions', totalCountOrderedExpansions);

    /// 1. ===> Total Count of Games From DB From DB vs New Sync
    prefs.setInt('totalCountGames', totalCountGames);
    print('* TotalCountGames: [$totalCountGames] VS new Sync: [$gamesCount]');

    /// 2. ===> Total Count of Expansions  From DB vs New Sync
    prefs.setInt('totalCountExpansions', totalCountExpansions);
    print('* TotalCountExpansions: [$totalCountExpansions] VS new Sync: [$expansionsCount]');

    /// 3. ===> Total SUM of Plays From DB vs New Sync
    prefs.setInt('totalCountPlaysGames', totalCountPlaysGames);
    print('* TotalCountPlaysGames: [$totalCountPlaysGames] VS new Sync: [$playsCount]');

    /// 4. ===> Total SUM of Games Value From DB
    prefs.setInt('totalValueGames', totalValueGames.toInt());
    print('* TotalValueGames: [$totalValueGames]');

    /// 5. ===> Total SUM of Expansions Value From DB
    prefs.setInt('totalValueExpansions', totalValueExpansions.toInt());
    print('* TotalValueExpansions: [$totalValueExpansions]');
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
      ${HraFields.gameValue} DECIMAL(5, 2) DEFAULT 0.00,
      ${HraFields.obtainDate} TEXT DEFAULT "N/A",
      ${HraFields.parentGameId} INTEGER DEFAULT 0
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

    final maps = await db.query(tableHras, columns: HraFields.values, where: '${HraFields.objectId}=?', whereArgs: [id]);

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

  Future<Hra?> getItemByObjectId(int objectId) async {
    final db = await instance.database;

    final maps = await db.query(
      tableHras,
      where: '${HraFields.objectId} = ?',
      whereArgs: [objectId],
    );

    if (maps.isNotEmpty) {
      return Hra.fromJson(maps.first);
    } else {
      return null;
    }
  }

  /// populate DB for the first time - then verify if plays  games and expansions or in db - message about new
  Future<void> populateDatabaseFromApi(String bgUserName) async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = join(dbPath, 'hras.db');

    final expList = await fetchGamesFromApi(bgUserName, 'subtype=boardgameexpansion');
    if (kDebugMode) {
      print("Fetch Expansions Complete");
      expansionsCount = (expList.length);
    }

    final hraList = await fetchGamesFromApi(bgUserName, 'subtype=boardgame&excludesubtype=boardgameexpansion');
    if (kDebugMode) {
      print("Fetch Games Complete");
      gamesCount = (hraList.length);

      /// Calculate the sum of all plays
      int totalPlays = 0;
      for (final hra in hraList) {
        totalPlays += hra.numPlays;
      }
      playsCount = totalPlays;
    }

    final db = await instance.database;

    bool newGameAdded = false;
    bool newExpansionAdded = false;
    bool newPlaysAdded = false;

    for (final hra in hraList) {
      final existingHra = await readHra(hra.objectId);
      if (existingHra == null) {
        await db.insert(tableHras, hra.toJson());
        newGameAdded = true;
      } else if (existingHra.numPlays != hra.numPlays) {
        // Update numPlays if it has changed
        await db.update(
          tableHras,
          hra.toJson(),
          where: 'objectId = ?',
          whereArgs: [hra.objectId],
        );
        newPlaysAdded = true;
      }
    }

    for (final hra in expList) {
      final existingExpansion = await readHra(hra.objectId);
      if (existingExpansion == null) {
        await db.insert(tableHras, hra.toJson());
        newExpansionAdded = true;
      } else if (existingExpansion.numPlays != hra.numPlays) {
        // Update numPlays if it has changed
        await db.update(
          tableHras,
          hra.toJson(),
          where: 'objectId = ?',
          whereArgs: [hra.objectId],
        );
        newPlaysAdded = true;
      }
    }

    if (newGameAdded) {
      print("Added new Games");
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('newGameAdded', true); // Set the flag in SharedPreferences
    } else {
      print("Games are OK");
    }

    if (newExpansionAdded) {
      print("Added new Expansion");
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('newExpansionAdded', true); // Set the flag in SharedPreferences
    } else {
      print("Expansions are OK");
    }

    if (newPlaysAdded) {
      print("New Plays added");
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('newPlaysAdded', true); // Set the flag in SharedPreferences
    } else {
      print("Plays are OK");
    }

    // Refresh total values and counts in shared preferences
    await calculateAndStoreTotalValues();
  }

  /// Get total value, count, and total number of plays for board games
  Future<Map<String, dynamic>> getBoardGamesStats() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT SUM(gameValue) AS totalValue, COUNT(*) AS totalCount, SUM(numPlays) AS totalPlays FROM $tableHras WHERE subtype = ?', ['boardgame']);

    return result.isNotEmpty ? result.first : {'totalValue': 0, 'totalCount': 0, 'totalPlays': 0};
  }

  /// get Hras Count
  Future<int?> getHrasCount() async {
    final db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableHras'));
  }

  /// Delete Data
  Future<void> deleteData() async {
    final db = await instance.database;

    await db.delete('hras');
  }

  Future<List<Hra>> getItemsBySubtype(String subtype) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHras,
      where: 'subtype = ?',
      whereArgs: [subtype],
    );

    return List.generate(maps.length, (i) {
      return Hra(
        name: maps[i]['name'],
        collId: maps[i]['collId'],
        image: maps[i]['image'],
        numPlays: maps[i]['numPlays'],
        objectId: maps[i]['objectId'],
        statusOwn: maps[i]['statusOwn'] == 1,
        subtype: maps[i]['subtype'],
        thumbnail: maps[i]['thumbnail'],
        yearPublished: maps[i]['yearPublished'],
      );
    });
  }

  Future<List<Hra>> getBoardGames() async {
    return await getItemsBySubtype('boardgame');
  }

  Future<List<Hra>> getBoardGameExpansions() async {
    return await getItemsBySubtype('boardgameexpansion');
  }

  Future<List<Hra>> getAllBoardGamesAndExpansions() async {
    final boardGames = await readAllHra();
    // final boardGameExpansions = await getItemsBySubtype('boardgameexpansion');

    // Combine and return the results
    // return [...boardGames, ...boardGameExpansions];
    return [...boardGames];
  }

  /// Get All by Status OWn
  Future<List<Hra>> getItemsByStatusOwn(bool statusOwn) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHras,
      where: 'statusOwn = ?',
      whereArgs: [statusOwn ? 1 : 0],
    );

    return List.generate(maps.length, (i) {
      return Hra(
        name: maps[i]['name'],
        collId: maps[i]['collId'],
        image: maps[i]['image'],
        numPlays: maps[i]['numPlays'],
        objectId: maps[i]['objectId'],
        statusOwn: maps[i]['statusOwn'] == 1,
        subtype: maps[i]['subtype'],
        thumbnail: maps[i]['thumbnail'],
        yearPublished: maps[i]['yearPublished'],
      );
    });
  }

  /// Get Own / Preordered items
  Future<List<Hra>> getOwnItems() async {
    return await getItemsByStatusOwn(true);
  }

  Future<List<Hra>> getPreorderedItems() async {
    return await getItemsByStatusOwn(false);
  }

  /// Update parent game in boardgameExpansion
  Future<void> updateParentGameForExpansion(int expansionId, List<String?> expansionIds) async {
    try {
      final db = await instance.database;

      for (String? parentObjectId in expansionIds) {
        if (parentObjectId != null) {
          // Check if the parent game ID is already set to the parent object ID
          final List<Map<String, dynamic>> existingExpansion = await db.query(
            tableHras,
            columns: [HraFields.parentGameId],
            where: '${HraFields.objectId} = ? AND ${HraFields.parentGameId} = ?',
            whereArgs: [expansionId, parentObjectId],
          );

          if (existingExpansion.isEmpty) {
            // Update the parent game ID for the expansion
            await db.update(
              tableHras,
              {HraFields.parentGameId: parentObjectId},
              where: '${HraFields.objectId} = ?',
              whereArgs: [expansionId],
            );
            print('Parent game ID updated for expansion $expansionId');
          } else {
            print('Expansion $expansionId is already in DB');
          }
        }
      }
    } catch (e) {
      print('Error updating parent game IDs for expansions: $e');
    }
  }

  Future<void> updateParentGameAndFetchExpansionIds(int parentObjectId) async {
    // Fetch the expansion IDs and update parent game for expansions
    final expansionIds = await getExpansionIds(parentObjectId.toString());

    // Access the HrasDatabase instance and call updateParentGameForExpansion
    await updateParentGameForExpansion(parentObjectId, expansionIds);
  }

  Future<int> getDetailGameExpansionCount(int objectId) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM $tableHras WHERE ${HraFields.parentGameId} = ?',
      [objectId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Calculates and SUM all expansions related to Boardgame  and also Boardgame itself into total value.
  Future<num> getTotalGameValueByParentGameId(int parentGameId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(gameValue) as totalGameValue
    FROM $tableHras
    WHERE parentGameId = ? OR objectId = ?
  ''', [parentGameId, parentGameId]);

    final totalGameValue = result.first['totalGameValue'] ?? 0;
    return totalGameValue;
  }

  Future<List<YearlyGameData>> getSumOfGameValueForEachYear(GameSubtype subtype) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> queryResult = await db.query(tableHras);

    List<Hra> games = queryResult.map((row) => Hra.fromJson(row)).toList();

    Map<int, YearlyGameData> yearDataMap = {};

    for (var game in games) {
      switch (subtype) {
        case GameSubtype.boardgame:
          if (game.subtype == 'boardgame' &&
              game.obtainDate != null &&
              game.obtainDate!.isNotEmpty &&
              game.gameValue != null &&
              game.gameValue != 0) {
            DateTime? parsedDate = DateTime.tryParse(game.obtainDate ?? '');
            if (parsedDate != null) {
              int year = parsedDate.year;
              num gameValue = game.gameValue.toDouble();

              if (yearDataMap.containsKey(year)) {
                YearlyGameData existingData = yearDataMap[year]!;
                yearDataMap[year] = YearlyGameData(year, existingData.sumValue + gameValue, existingData.barCounterValue + 1);
              } else {
                yearDataMap[year] = YearlyGameData(year, gameValue, 1);
              }
            }
          }
          break;
        case GameSubtype.accessories:
          if (game.subtype == 'accessories' &&
              game.obtainDate != null &&
              game.obtainDate!.isNotEmpty &&
              game.gameValue != null &&
              game.gameValue != 0) {
            DateTime? parsedDate = DateTime.tryParse(game.obtainDate ?? '');
            if (parsedDate != null) {
              int year = parsedDate.year;
              num gameValue = game.gameValue;

              if (yearDataMap.containsKey(year)) {
                YearlyGameData existingData = yearDataMap[year]!;
                yearDataMap[year] = YearlyGameData(year, existingData.sumValue + gameValue, existingData.barCounterValue + 1);
              } else {
                yearDataMap[year] = YearlyGameData(year, gameValue, 1);
              }
            }
          }
          break;
        case GameSubtype.boardgameexpansion:
          if (game.subtype == 'boardgameexpansion' &&
              game.obtainDate != null &&
              game.obtainDate!.isNotEmpty &&
              game.gameValue != null &&
              game.gameValue != 0) {
            DateTime? parsedDate = DateTime.tryParse(game.obtainDate ?? '');
            if (parsedDate != null) {
              int year = parsedDate.year;
              num gameValue = game.gameValue;

              if (yearDataMap.containsKey(year)) {
                YearlyGameData existingData = yearDataMap[year]!;
                yearDataMap[year] = YearlyGameData(year, existingData.sumValue + gameValue, existingData.barCounterValue + 1);
              } else {
                yearDataMap[year] = YearlyGameData(year, gameValue, 1);
              }
            }
          }
          break;
        case GameSubtype.all:
          if (game.obtainDate != null && game.obtainDate!.isNotEmpty && game.gameValue != null && game.gameValue != 0) {
            DateTime? parsedDate = DateTime.tryParse(game.obtainDate ?? '');
            if (parsedDate != null) {
              int year = parsedDate.year;
              num gameValue = game.gameValue;

              if (yearDataMap.containsKey(year)) {
                YearlyGameData existingData = yearDataMap[year]!;
                yearDataMap[year] = YearlyGameData(year, existingData.sumValue + gameValue, existingData.barCounterValue + 1);
              } else {
                yearDataMap[year] = YearlyGameData(year, gameValue, 1);
              }
            }
          }
          break;
      }
    }

    return yearDataMap.values.toList();
  }

  Future<List<ExpansionModel>> getExpansionsByParentGameId(int parentGameId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expansions',
      where: 'parent_game_id = ?',
      whereArgs: [parentGameId],
    );

    return List.generate(maps.length, (i) {
      return ExpansionModel(
        // Map database columns to your ExpansionModel fields here
        objectId: maps[i]['objectId'],
        name: maps[i]['name'],
        thumbnail: maps[i]['thumbnail'],
        gameValue: maps[i]['gameValue'],
      );
    });
  }

  /// Function to fetch all objects with subtype == boardgame
  Future<List<Hra>> getBoardGamesFromDatabase() async {
    final db = await instance.database;
    final boardGames = await db.query(
      tableHras,
      where: 'subtype = ?',
      whereArgs: ['boardgame'],
    );
    return boardGames.map((data) => Hra.fromJson(data)).toList();
  }

  /// Function to populate the database with expansions for all boardgames
  Future<void> populateDatabaseWithExpansions() async {
    final boardGames = await getBoardGamesFromDatabase();

    for (final boardGame in boardGames) {
      final expansionIds = await getExpansionIds(boardGame.objectId.toString());

      // Call getExpansionData for each expansion and update the database
      for (final expansionId in expansionIds) {
        await updateParentGameForExpansion(int.parse(expansionId!), [boardGame.objectId.toString()]);
      }

      // After processing all expansions, update the parent game ID
      await updateParentGameAndFetchExpansionIds(boardGame.objectId);
    }
  }

  /// fetch only games which are statusOwn ==1 and value and obtained date are filled in
  Future<List<Hra>> showAllItemsKnown() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHras,
      where: 'statusOwn = ? AND gameValue IS NOT 0 AND obtainDate IS NOT NULL',
      whereArgs: [1], // Assuming 1 represents known status
    );

    return List.generate(maps.length, (i) {
      return Hra(
        name: maps[i]['name'],
        collId: maps[i]['collId'],
        image: maps[i]['image'],
        numPlays: maps[i]['numPlays'],
        objectId: maps[i]['objectId'],
        statusOwn: maps[i]['statusOwn'] == 1,
        subtype: maps[i]['subtype'],
        thumbnail: maps[i]['thumbnail'],
        yearPublished: maps[i]['yearPublished'],
      );
    });
  }

  /// fetch only games which are statusOwn ==1 and value and obtained date are empty
  Future<List<Hra>> showAllItemsUnknown() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHras,
      where: 'statusOwn = ? AND gameValue = 0 AND obtainDate IS NULL',
      whereArgs: [1], // Assuming 1 represents known status
    );

    return List.generate(maps.length, (i) {
      return Hra(
        name: maps[i]['name'],
        collId: maps[i]['collId'],
        image: maps[i]['image'],
        numPlays: maps[i]['numPlays'],
        objectId: maps[i]['objectId'],
        statusOwn: maps[i]['statusOwn'] == 1,
        subtype: maps[i]['subtype'],
        thumbnail: maps[i]['thumbnail'],
        yearPublished: maps[i]['yearPublished'],
      );
    });
  }

  Future<int> countAllItemsKnown() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      // 'SELECT COUNT(*) AS count FROM $tableHras WHERE statusOwn = 1 AND (parentGameId IS NOT NULL AND obtainDate IS NOT NULL)',
      'SELECT COUNT(*) AS count FROM $tableHras WHERE statusOwn = 1 AND (gameValue != 0 AND obtainDate IS NOT NULL)',
    );

    print('countAllItemsKnown SQL: ${result[0]['count']}'); // Debug print

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countAllItemsUnknown() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $tableHras WHERE statusOwn = 1 AND (gameValue = 0 AND obtainDate IS NULL)',
    );

    print('countAllItemsUnknown SQL: ${result[0]['count']}'); // Debug print

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
