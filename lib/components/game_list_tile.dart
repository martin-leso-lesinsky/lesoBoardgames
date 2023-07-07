import 'package:flutter/material.dart';
import 'package:leso_board_games/components/constants.dart';
import 'package:leso_board_games/models/game_model.dart';

DateTime dt1 = DateTime.now();

class GameListTile extends StatelessWidget {
  final Game game;

  const GameListTile({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
              child: SizedBox(
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
                      game.yearPublished.toString(),
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
                      child: Image.network(game.image),
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
                    game.name,
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
              child: Row(
                children: [
                  const Text(
                    "Played: ",
                    style: TextStyle(
                        fontWeight: FontWeight.normal, color: basicLightGrey),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: game.numPlays == 0
                          ? const Color.fromARGB(255, 255, 154, 147)
                          : const Color.fromARGB(255, 100, 255, 255),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: Text(
                          "${game.numPlays}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: darkGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                            "PPP ratio: ",
                            style: TextStyle(
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
                                fontSize: 25,
                                color: Color.fromARGB(255, 115, 248, 188)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                            "Value:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: normalGrey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "125 €",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
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
}
