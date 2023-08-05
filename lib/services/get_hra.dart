import 'package:http/http.dart' as http;
import 'package:leso_board_games/models/hra_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

void _saveLastBgSync(String lastPub) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('lastBgSync', lastPub);
}

Future<List<Hra>> fetchGamesFromApi(String bgUserName, String option) async {
  final url = Uri.parse(
      'https://boardgamegeek.com/xmlapi2/collection?username=$bgUserName&$option');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseBody = response.body;

      // Check if the response contains the "Please try again later" message
      if (responseBody
          .contains('Your request for this collection has been accepted')) {
        // Display a message to the user
        print('Please wait 1 minute. Your data will be fetched shortly.');

        // Wait for 60 seconds
        await Future.delayed(const Duration(seconds: 10));

        // Call the fetchGamesFromApi function again
        return fetchGamesFromApi(bgUserName, option);
      }

      final xmlDocument = xml.parse(responseBody);

      /// Save the last publication date
      final lastPub =
          xmlDocument.findAllElements('items').first.getAttribute('pubdate') ??
              '';
      _saveLastBgSync(lastPub);

      final hry = xmlDocument
          .findAllElements('item')
          .where((item) => item.getAttribute('objecttype') == 'thing')
          .map((item) {
        final objectId = int.tryParse(item.getAttribute('objectid') ?? '') ?? 0;
        final subtype = item.getAttribute('subtype') ?? '';
        final collId = item.getAttribute('collid') ?? '';
        final name = item.findElements('name').first.text;
        final yearPublishedElement = item.findElements('yearpublished').first;
        final yearPublished = int.tryParse(yearPublishedElement.text) ?? 0;
        final image = item.findElements('image').first.text;
        final thumbnail = item.findElements('thumbnail').first.text;
        final statusOwn = item
                .findElements('status')
                .first
                .getAttribute('own')
                ?.toLowerCase() ==
            '1';
        final numPlays =
            int.tryParse(item.findElements('numplays').first.text) ?? 0;

        return Hra(
          objectId: objectId,
          subtype: subtype,
          collId: collId,
          name: name,
          yearPublished: yearPublished.toString(),
          image: image,
          thumbnail: thumbnail,
          statusOwn: statusOwn,
          numPlays: numPlays,
        );
      }).toList();

      return List<Hra>.from(hry); // Cast hry to List<Hra>
    } else {
      print('Failed to fetch games from API');
      return [];
    }
  } catch (e) {
    print('Error while fetching games from API: $e');
    return [];
  }
}
