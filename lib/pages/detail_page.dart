import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leso_board_games/components/constants.dart';
import 'package:leso_board_games/models/game_model.dart';
import 'package:leso_board_games/pages/edit_game_page.dart';
import 'package:leso_board_games/pages/expansion_list_page.dart';
import 'package:url_launcher/url_launcher.dart';

class GameDetailPage extends StatelessWidget {
  final Game game;

  const GameDetailPage({required this.game, required Key? key})
      : super(key: key);

  /// button BGG link to selected game
  _launchURLGame() async {
    final Uri url =
        Uri.parse('https://boardgamegeek.com/boardgame/${game.objectId}');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          children: [
            /// GAME title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 720, maxHeight: 80),
                alignment: Alignment.center,
                child: Text(
                  game.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            /// GAME pic and stats
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
              child: Container(
                constraints: const BoxConstraints(
                    maxWidth: 720, maxHeight: kIsWeb == true ? 600 : 450),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Detail game picture column
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            constraints: const BoxConstraints(
                                maxWidth: kIsWeb == true ? 380 : 160,
                                maxHeight: 300),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                game.image,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),

                      /// Detail game info column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 130, maxHeight: 110),

                                /// verify if its game or an expansion - currently is numplays is set as trigger
                                color: game.numPlays > 5
                                    ? Colors.greenAccent
                                    : Colors.yellow[400],
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,

                                  /// verify if its game or an expansion - currently is numplays is set as trigger
                                  children: game.numPlays > 5
                                      ? [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Image.asset(
                                                'assets/images/dice2.png',
                                                height: 18,
                                                fit: BoxFit.fill),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            "Game",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ]
                                      : [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Image.asset(
                                                'assets/images/expansion.png',
                                                height: 18,
                                                fit: BoxFit.fill),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            "Expansion",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                ),
                              ),
                            ),
                          ),

                          /// game info field
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    color: const Color.fromARGB(75, 75, 75, 75),
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 20, 10, 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                color: Colors.white),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "Published: ",
                                              style: TextStyle(
                                                color: basicLightGrey,
                                              ),
                                            ),
                                            Text(
                                              "${game.yearPublished}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.vpn_key,
                                                color: Colors.white),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "Object Id: ",
                                              style: TextStyle(
                                                color: basicLightGrey,
                                              ),
                                            ),
                                            Text(
                                              game.objectId,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                                Icons.collections_bookmark,
                                                color: Colors.white),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "Collection Id: ",
                                              style: TextStyle(
                                                color: basicLightGrey,
                                              ),
                                            ),
                                            Text(
                                              game.collId,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Icon(Icons.access_time,
                                                color: Colors.white),
                                            SizedBox(width: 10),
                                            Text(
                                              "In collection: ",
                                              style: TextStyle(
                                                color: basicLightGrey,
                                              ),
                                            ),
                                            Text(
                                              "132 days",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          /// Editable value and obtained value field
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: kIsWeb == true ? 200 : 190,
                                    color: Colors.blue[900],
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 10),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            // children: const [
                                            // Icon(Icons.edit,
                                            //     color: Colors.blueAccent),
                                            children: [
                                              ElevatedButton(
                                                child: const Text('edit'),
                                                onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditGamePage(
                                                      game: game,
                                                      key: ValueKey(
                                                          game.objectId),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            // ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Icon(Icons.today,
                                                  color: Colors.white),
                                              SizedBox(width: 10),
                                              Text(
                                                "Obtained: ",
                                                style: TextStyle(
                                                  color: basicLightGrey,
                                                ),
                                              ),
                                              Text(
                                                "26.12.2019",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Icon(
                                                  Icons
                                                      .monetization_on_outlined,
                                                  color: Colors.white),
                                              SizedBox(width: 10),
                                              Text(
                                                "Core game Value: ",
                                                style: TextStyle(
                                                  color: basicLightGrey,
                                                ),
                                              ),
                                              Text(
                                                "125",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]),
              ),
            ),

            /// VALUE of game stats
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 720, maxHeight: 200),
                child: Row(
                  children: [
                    /// Price per ration box
                    Expanded(
                      child: Container(
                        width: 80,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 18, 18, 20),
                          borderRadius: BorderRadius.circular(12),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Padding(
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
                              "${game.numPlays}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Colors.lightBlueAccent),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Padding(
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
                              // '${(125 / game.numPlays).round()} €',
                              // '${(125 / (game.numPlays ?? 1)).round()} €',
                              '${(game.numPlays != 0 ? 125 ~/ game.numPlays : 125).round()} €',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 213, 115, 248)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    //// value in euro
                    Expanded(
                      child: Container(
                        width: 120,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 18, 18, 20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Total Value: ",
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
            ),

            /// BUTTON BGG link to selected game
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
              child: Container(
                alignment: Alignment.topLeft,
                constraints: const BoxConstraints(maxWidth: 720, maxHeight: 81),
                child: Row(
                  children: [
                    Column(children: [
                      TextButton(
                        onPressed: _launchURLGame,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset('assets/images/BGG_icon.png',
                              height: 50, fit: BoxFit.fill),
                        ),
                      ),
                      Text(
                        "BGG link",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                          fontSize: 10,
                        ),
                      ),
                    ]),
                    const SizedBox(width: 15),
                    Column(
                      children: [
                        Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 50,
                                width: 100,
                                color: Colors.amberAccent,
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExpansionListPage(
                                        game: game,
                                        key: ValueKey(game.objectId),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/expansion.png',
                                        height: 26,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "12",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // ),
                          Row(
                            children: [
                              Column(
                                children: const [
                                  Text(
                                    "Expansions list",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amberAccent,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// back BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue[900],
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
