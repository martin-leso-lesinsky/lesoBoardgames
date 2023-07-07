import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../models/game_model.dart';

class GamesData {
  final List<Game> games;
  final int gamesCount;

  GamesData(this.games, this.gamesCount);
}

class GetCollection {
  static const _baseUrl = 'https://boardgamegeek.com/xmlapi2/collection';

  static Future<GamesData> fetchGames(
      String username, String gameExistence, String gamesOnly) async {
    final response = await http.get(
        Uri.parse('$_baseUrl?username=$username$gamesOnly&$gameExistence'));
    final xmlDocument = xml.parse(response.body);
    final games = xmlDocument
        .findAllElements('item')
        .where((item) => item.getAttribute('objecttype') == 'thing')
        .map((item) {
      final numplays =
          int.tryParse(item.findElements('numplays').first.text) ?? 0;
      final yearpublished =
          int.tryParse(item.findElements('yearpublished').first.text) ?? 0;
      final game = Game(
        // id: 1,
        objectId: item.getAttribute('objectid') ?? '',
        collId: item.getAttribute('collid') ?? '',
        name: item.findElements('name').first.text,
        image: item.findElements('image').first.text,
        thumbnail: item.findElements('thumbnail').first.text,
        statusOwn: true,
        numPlays: numplays,
        yearPublished: yearpublished,
      );
      return game;
    }).toList();

    if (kDebugMode) {
      print("Games returned from BG Api Get collection: ${games.length}");
    }
    final gamesCount = games.length;
    final gamesData = GamesData(games, gamesCount);
    return gamesData;
  }
}
