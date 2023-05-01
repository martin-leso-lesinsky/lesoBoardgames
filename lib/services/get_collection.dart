import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../models/game_model.dart';

class GetCollection {
  static const _baseUrl = 'https://api.geekdo.com/xmlapi2/collection';

  static Future<List<Game>> fetchGames(String username) async {
    final response = await http.get(Uri.parse('$_baseUrl?username=$username'));
    final xmlDocument = xml.parse(response.body);

    final games = xmlDocument
        .findAllElements('item')
        .where((item) => item.getAttribute('objecttype') == 'thing')
        .where((item) =>
            (item.findElements('status').first.getAttribute('own') == "1"))
        .map((item) {
      final numplays =
          int.tryParse(item.findElements('numplays').first.text) ?? 0;
      final yearpublished =
          int.tryParse(item.findElements('yearpublished').first.text) ?? 0;
      return Game(
        objectId: item.getAttribute('objectid') ?? '',
        collId: item.getAttribute('collid') ?? '',
        name: item.findElements('name').first.text,
        image: item.findElements('image').first.text,
        thumbnail: item.findElements('thumbnail').first.text,
        statusOwn: true,
        numPlays: numplays,
        yearPublished: yearpublished,
      );
    }).toList();

    print(games.length);
    return games;
  }
}
