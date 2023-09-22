import 'package:flutter/material.dart';
import 'package:leso_board_games/components/constants.dart';
import 'package:leso_board_games/models/hra_model.dart';
import 'package:leso_board_games/pages/hra_detail_page.dart';
import 'package:leso_board_games/db/hras_database.dart';

class HraListTile extends StatelessWidget {
  final String bgUserName;
  final String objectId;
  final String name;
  final String gameValue;
  final String yearPublished;
  final String thumbnail;
  final String numPlays;
  final String subtype;
  final List<Hra> hras;

  const HraListTile({
    super.key,
    required this.bgUserName,
    required this.objectId,
    required this.name,
    required this.gameValue,
    required this.yearPublished,
    required this.thumbnail,
    required this.numPlays,
    required this.subtype,
    required this.hras,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _navigateToHraDetail(context);
      },
      child: Container(
        color: darkGrey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),

          /// one Game Tile
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              /// ROW 1 ==> Game Published
              Row(
                children: [
                  Center(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                          child: Row(
                            children: [
                              Text(
                                yearPublished,
                                textAlign: TextAlign.left,
                                style: const TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /// ROW 2 ==> Game Thumbnail
              SizedBox(
                height: 150,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 20, 18, 18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(thumbnail),
                      ),
                    ),
                  ),
                ),
              ),

              /// ROW 3 ==> Game Name
              Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                child: SizedBox(
                  height: 35,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: lightBlue, fontSize: 16),
                    ),
                  ),
                ),
              ),

              /// ROW 4 ==> Game Played / not yet played / Expansion [should be removed for the future]
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 2, 10),
                    child: numPlays != '0'
                        ? Row(
                            children: [
                              const Text(
                                "Played: ",
                                style: TextStyle(
                                  // fontWeight: FontWeight.normal,
                                  color: Colors.white24,
                                ),
                              ),
                              Container(
                                width: 28,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1),
                                    child: Text(
                                      numPlays,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: darkGrey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            alignment: Alignment.bottomCenter,
                            child: subtype != 'boardgameexpansion'
                                ? const Text(
                                    "not yet Played",
                                    style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white24),
                                  )
                                : const Text('Expansion'),
                          ),
                  ),
                ],
              ),

              /// ROW 5 ==> Game PPR / Value
              subtype == 'boardgame'
                  ? Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 18, 18, 20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: subtype == 'boardgame'
                                ? Column(
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "PPPR: ",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: normalGrey,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "0.56",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color.fromARGB(255, 115, 248, 188)),
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 18, 18, 20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    "Value:",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: normalGrey, fontSize: 10),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    "$gameValue €",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color.fromARGB(255, 248, 246, 115)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 18, 18, 20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "Value:",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: normalGrey, fontSize: 10),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      "$gameValue €",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color.fromARGB(255, 248, 246, 115)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to particular detail of selected Item
  void _navigateToHraDetail(BuildContext context) async {
    final int parsedObjectId = int.parse(objectId);
    final retrievedHra = await HrasDatabase.instance.getItemByObjectId(parsedObjectId);

    if (retrievedHra != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HraDetail(
            hraData: retrievedHra.toJson(),
            bgUserName: bgUserName,
            objectId: retrievedHra.objectId,
          ),
        ),
      );
    }
  }
}
