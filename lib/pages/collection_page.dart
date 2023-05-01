import 'dart:async';
import 'package:flutter/material.dart';
import 'package:leso_board_games/pages/detail_page.dart';
import 'package:leso_board_games/pages/statistic_page.dart';
import '../models/game_model.dart';
import '../services/get_collection.dart';
import 'package:leso_board_games/components/game_list_tile.dart';
import 'package:leso_board_games/components/constants.dart';

enum Status {
  all,
  own,
}

class MyCollectionPage extends StatefulWidget {
  const MyCollectionPage({super.key});

  @override
  _MyCollectionPageState createState() => _MyCollectionPageState();
}

class _MyCollectionPageState extends State<MyCollectionPage> {
  Future<List<Game>>? _futureGames;
  String _searchText = '';
  Status _selectedStatus = Status.all;

  @override
  void initState() {
    super.initState();
    _fetchGames();
    _filterGames([]);
  }

  void _fetchGames() async {
    final gamesData = await GetCollection.fetchGames('lesiak');
    var filteredGames = gamesData.toList();
    setState(() {
      _futureGames = Future.value(filteredGames as FutureOr<List<Game>>?);
    });
  }

  void _filterList(String searchText) {
    setState(() {
      _searchText = searchText;
    });
  }

  List<Game> _filterGames(List<Game> games) {
    return games.where((game) {
      final nameContainsSearchText =
          game.name.toLowerCase().contains(_searchText.toLowerCase());
      final isOwned = game.statusOwn == true;
      switch (_selectedStatus) {
        case Status.all:
          return nameContainsSearchText;
        case Status.own:
          return isOwned && nameContainsSearchText;
        default:
          return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int columnCount = (screenWidth > 1080 ? 3 : (screenWidth > 800 ? 2 : 1));
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 60, 60, 60),
              title: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: basicPadding),
                      child: TextField(
                        onChanged: _filterList,
                        decoration: const InputDecoration(
                          hintText: 'Search game...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 118, 118, 118)),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 35, 35, 35),
            body: Column(children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StatisticPage()),
                  );
                },
                child: Container(
                  width: 1080,
                  height: 150,
                  color: Color.fromARGB(255, 40, 40, 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Games',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '202',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Plays',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '206',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Value',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '2005 \$',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                // Row B
                child: FutureBuilder<List<Game>>(
                  future: _futureGames,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final games = snapshot.data!;
                      return GridView.count(
                        childAspectRatio: 0.72,
                        crossAxisCount: columnCount,
                        mainAxisSpacing: basicPadding,
                        crossAxisSpacing: basicPadding,
                        // childAspectRatio: 360 / 460,
                        children: _filterGames(games).map((game) {
                          return Container(
                            color: Color.fromARGB(255, 50, 50, 50),
                            padding: const EdgeInsets.all(basicPadding),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                // MaterialPageRoute(
                                //   builder: (context) => DetailGame(
                                //     game: game,
                                //     key: ValueKey(game.objectId),
                                //   ),
                                // ),
                                MaterialPageRoute(
                                  builder: (context) => GameDetailPage(
                                    game: game,
                                    key: ValueKey(game.objectId),
                                  ),
                                ),
                              ),
                              child: SizedBox(
                                child: GameListTile(
                                  game: game,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ])));
  }
}
