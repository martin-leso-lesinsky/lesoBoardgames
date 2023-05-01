import 'package:flutter/material.dart';
import 'package:leso_board_games/components/constants.dart';
import 'package:leso_board_games/models/game_model.dart';

class GameDetailPage extends StatelessWidget {
  final Game game;

  const GameDetailPage({required this.game, required Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
          ),
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 900),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Container(
                  height: 150,
                  alignment: Alignment.center,
                  child: Text(
                    game.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 500,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Container(
                        width: 360,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        child: Image.network(
                          game.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          width: 450,
                          color: darkGrey,
                          padding: const EdgeInsets.fromLTRB(50, 50, 50, 100),
                          alignment: Alignment.topLeft,
                          child: Container(
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        color: Colors.white),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Published: ",
                                      style: TextStyle(
                                        color: basicLightGrey,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "${game.yearPublished}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.vpn_key,
                                        color: Colors.white),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Object Id: ",
                                      style: const TextStyle(
                                        color: basicLightGrey,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "${game.objectId}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.collections_bookmark,
                                        color: Colors.white),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Collection Id: ",
                                      style: const TextStyle(
                                        color: basicLightGrey,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "${game.collId}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.play_arrow,
                                        color: Colors.white),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Num Plays: ",
                                      style: const TextStyle(
                                        color: basicLightGrey,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "${game.numPlays}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Icon(Icons.today, color: Colors.white),
                                    SizedBox(width: 10),
                                    Text(
                                      "Obtained on: ",
                                      style: TextStyle(
                                        color: basicLightGrey,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "26.12.2019",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Icon(Icons.access_time,
                                        color: Colors.white),
                                    SizedBox(width: 10),
                                    Text(
                                      "Days in collection: ",
                                      style: TextStyle(
                                        color: basicLightGrey,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "132 days",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    /// Price per ration box
                    Expanded(
                      child: Container(
                        width: 80,
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
                                "Price Per Play ratio: ",
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
                    const SizedBox(width: 20),

                    /// Played games box
                    Expanded(
                      child: Container(
                        width: 80,
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
                                "Played games: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: normalGrey,
                                ),
                              ),
                            ),
                            Text(
                              "18",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 115, 215, 248)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
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
                                "Cost per game: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: normalGrey,
                                ),
                              ),
                            ),
                            Text(
                              "12 €",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 213, 115, 248)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    /// value in euro
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
