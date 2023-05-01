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
    //Duration diff = dt1.difference("TO DO : game.ownDate");
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                height: 200,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 20, 18, 18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: basicPadding, vertical: basicPadding),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(game.image),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 90, // height based on 3 lines of text
                child: Text(
                  game.name,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: basicLightGrey, fontSize: 22),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
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
                            ? Color.fromARGB(255, 255, 154, 147)
                            : Color.fromARGB(255, 100, 255, 255),
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
              Container(
                width: 300,
                padding: EdgeInsets.all(basicPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: 120,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 18, 18, 20),
                          borderRadius: BorderRadius.circular(15),
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
                            Text(
                              "0.56",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 115, 248, 188)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        width: 120,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 18, 18, 20),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Value: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: normalGrey,
                                ),
                              ),
                            ),
                            Text(
                              "125 €",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 248, 246, 115)),
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
}
