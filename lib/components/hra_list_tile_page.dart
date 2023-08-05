import 'package:flutter/material.dart';
import 'package:leso_board_games/components/constants.dart';
import 'package:leso_board_games/models/hra_model.dart';
import 'package:leso_board_games/pages/hra_detail_page.dart';

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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              height: 15, // height based on 3 lines of text
              child: Row(
                children: [
                  const Text(
                    "Published: ",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    yearPublished,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 20, 18, 18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(thumbnail),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: SizedBox(
                child: Container(
                  height: 60, // height based on 3 lines of text
                  decoration: BoxDecoration(
                    // color: Color.fromARGB(0, 5, 0, 5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: lightBlue, fontSize: 18),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
              child: numPlays != '0'
                  ? Row(
                      children: [
                        const Text(
                          "Played: ",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: basicLightGrey),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 100, 255, 255),
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
                      alignment: Alignment.centerLeft,

                      /// if its expansion its not displayed number of plays
                      child: subtype != 'boardgameexpansion'
                          ? const Text(
                              "not yet Played",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: darkGrey),
                            )
                          : const Text(''),
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    // width: 120,
                    // height: 100,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 18, 18, 20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color.fromARGB(255, 115, 248, 188)),
                          ),
                        ),
                      ],
                    ),
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: normalGrey,
                                fontSize: 10),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "$gameValue €",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color.fromARGB(255, 248, 246, 115)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHraDetail(BuildContext context) async {
    final hra = hras.firstWhere((hra) => hra.objectId.toString() == objectId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HraDetail(
          hraData: hra.toJson(),
          bgUserName: bgUserName,
        ), // Keep this if needed
      ),
    );
  }
}
