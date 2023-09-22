import 'package:http/http.dart' as http;
import 'package:leso_board_games/db/hras_database.dart';
import 'package:leso_board_games/models/hra_model.dart';
import 'package:leso_board_games/models/expansion_model.dart';
import 'package:xml/xml.dart' as xml;

Future<List<String?>> getExpansionIds(String objectId) async {
  final response = await http.get(Uri.parse('https://boardgamegeek.com/xmlapi2/thing?type=boardgame&versions=0&stats=0&id=$objectId'));

  if (response.statusCode == 200) {
    final xmlDoc = xml.parse(response.body);
    final expansionElements = xmlDoc.findAllElements('link').where((element) => element.getAttribute('type') == 'boardgameexpansion');

    final expansionIds = expansionElements.map((element) async {
      final expansionId = element.getAttribute('id');

      // Check if the objectId is already present in the local database
      Hra? existingHra = await HrasDatabase.instance.getItemByObjectId(int.parse(expansionId!));
      if (existingHra != null) {
        // Update the parent game ID for the expansion
        HrasDatabase.instance.updateParentGameForExpansion(int.parse(expansionId), [objectId]);
        return expansionId;
      } else {
        print('Object with ID [$objectId] - is not in DB');
        return null;
      }
    }).toList();

    return expansionIds.whereType<String?>().toList(); // Remove null values from the list
  } else {
    throw Exception('Failed to load data from the API');
  }
}

// Implement the getExpansionData function
Future<List<ExpansionModel>> getExpansionData(String objectId) async {
  final response = await http.get(Uri.parse('https://boardgamegeek.com/xmlapi2/thing?type=boardgame&versions=0&stats=0&id=$objectId'));

  if (response.statusCode == 200) {
    final xmlDoc = xml.parse(response.body);
    final expansionElements = xmlDoc.findAllElements('link').where((element) => element.getAttribute('type') == 'boardgameexpansion');

    final expansionData = await Future.wait(expansionElements.map((element) async {
      final expansionId = element.getAttribute('id');

      Hra? existingHra = await HrasDatabase.instance.getItemByObjectId(int.parse(expansionId!));
      if (existingHra != null) {
        return ExpansionModel(
          objectId: expansionId,
          name: existingHra.name, // Fetch name from existingHra
          thumbnail: existingHra.thumbnail, // Fetch thumbnail from existingHra
          gameValue: existingHra.gameValue, // Fetch gameValue from existingHra
        );
      } else {
        print('Object with ID $expansionId is not in DB');
        return null;
      }
    }).toList());

    return expansionData.whereType<ExpansionModel>().toList();
  } else {
    throw Exception('Failed to load data from the API');
  }
}
