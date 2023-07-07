import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leso_board_games/pages/detail_page.dart';
import 'package:leso_board_games/pages/statistic_page.dart';
import '../models/game_model.dart';
import '../services/get_collection.dart';
import 'package:leso_board_games/components/game_list_tile.dart';
import 'package:leso_board_games/components/constants.dart';

dynamic totalGamesCount;
dynamic totalNumPlays;
var gameExistence = "own=1"; //default
var gamesOnly = '&excludesubtype=boardgameexpansion'; //default

enum Existence {
  own,
  preordered,
}

enum GamesOnly {
  yes,
  no,
}

enum Status {
  all,
  own,
}

enum SortingOption {
  numPlays19,
  numPlays91,
  nameAZ,
  nameZA,
  yearPublished19,
  yearPublished91,
}

class MyCollectionPage extends StatefulWidget {
  const MyCollectionPage({super.key});

  @override
  _MyCollectionPageState createState() => _MyCollectionPageState();
}

class _MyCollectionPageState extends State<MyCollectionPage> {
  Future<List<Game>>? _futureGames;
  String _searchText = '';
  final Status _selectedStatus = Status.all;

  @override
  void initState() {
    super.initState();
    _fetchGames();
    _filterGames([]);
  }

  void _fetchGames() async {
    final gamesData =
        await GetCollection.fetchGames('lesiak', gameExistence, gamesOnly);
    var filteredGames = gamesData.games.toList();
    setState(() {
      totalNumPlays =
          filteredGames.fold<int>(0, (sum, game) => sum + game.numPlays);
      totalGamesCount = gamesData.gamesCount;
      _futureGames = Future.value(filteredGames);
    });
  }

  ///default sort by max num plays
  SortingOption _sortingOption = SortingOption.numPlays91;
  SortingOption _lastSortingOption = SortingOption.numPlays91;

  List<Game> sortGames(List<Game> games, SortingOption option) {
    switch (option) {
      case SortingOption.numPlays19:
        games.sort((a, b) => a.numPlays.compareTo(b.numPlays));
        break;
      case SortingOption.numPlays91:
        games.sort((a, b) => b.numPlays.compareTo(a.numPlays));
        break;
      case SortingOption.nameAZ:
        games.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortingOption.nameZA:
        games.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortingOption.yearPublished19:
        games.sort(
            (a, b) => a.yearPublished?.compareTo(b.yearPublished ?? 0) ?? -1);
        break;
      case SortingOption.yearPublished91:
        games.sort(
            (a, b) => b.yearPublished?.compareTo(a.yearPublished ?? 0) ?? 1);
        break;
    }
    return games;
  }

  List<Game> _getSortedGames(List<Game> games) {
    return sortGames(games, _sortingOption);
  }

  void _onSortByNumPlaysPressed() {
    setState(() {
      _lastSortingOption = _sortingOption;
      if (_sortingOption == SortingOption.numPlays91) {
        _sortingOption = SortingOption.numPlays19;
      } else {
        _sortingOption = SortingOption.numPlays91;
      }
    });
  }

  void _onSortByYearPublishedPressed() {
    setState(() {
      _lastSortingOption = _sortingOption;
      if (_sortingOption == SortingOption.yearPublished19) {
        _sortingOption = SortingOption.yearPublished91;
      } else {
        _sortingOption = SortingOption.yearPublished19;
      }
    });
  }

  void _onSortByNamePressed() {
    setState(() {
      _lastSortingOption = _sortingOption;
      if (_sortingOption == SortingOption.nameAZ) {
        _sortingOption = SortingOption.nameZA;
      } else {
        _sortingOption = SortingOption.nameAZ;
      }
    });
  }

  /// switcher between own and preordered games
  Existence _gameExistence = Existence.own;
  Existence _lastGameExistence = Existence.preordered;
  void _gameExistenceState() {
    _lastGameExistence = _gameExistence;
    if (_gameExistence == Existence.own) {
      _gameExistence = Existence.preordered;
      gameExistence = "preordered=1"; //set parameter for get_collection API
    } else {
      _gameExistence = Existence.own;
      gameExistence = "own=1"; //set parameter for get_collection API
    }
    _fetchGames();
  }

  /// switcher between only games and games + expansions
  GamesOnly _gamesOnly = GamesOnly.yes;
  GamesOnly _lastGamesOnly = GamesOnly.no;
  void _gamesOnlyState() {
    _lastGamesOnly = _gamesOnly;
    if (_gamesOnly == GamesOnly.yes) {
      _gamesOnly = GamesOnly.no;
      gamesOnly = ''; //set parameter for get_collection API
    } else {
      _gamesOnly = GamesOnly.yes;
      gamesOnly =
          '&excludesubtype=boardgameexpansion'; //set parameter for get_collection API
    }
    _fetchGames();
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
    int columnCount = (screenWidth > 1440 ? 4 : (screenWidth > 1080 ? 3 : 2));
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Scaffold(
        /// App / Search Bar
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 60, 60, 60),
          title: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: tenPadding),
                  child: TextField(
                    onChanged: _filterList,
                    decoration: const InputDecoration(
                      hintText: 'Search game...',
                      border: InputBorder.none,
                      hintStyle:
                          TextStyle(color: Color.fromARGB(255, 118, 118, 118)),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 35, 35, 35),

        /// Body
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StatisticPage()),
                );
              },

              /// Top Statistic Container
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                color: const Color.fromARGB(255, 40, 40, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Games',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalGamesCount != null ? '$totalGamesCount' : '',
                          // gamesData.gamesCount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Plays',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalNumPlays != null ? '$totalNumPlays' : '',
                          // '206',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  height: 30,
                                  constraints:
                                      const BoxConstraints(maxWidth: 100),
                                  color: gameExistence == "preordered=1"
                                      ? Colors.lightBlueAccent
                                      : Colors.greenAccent,
                                  child: Row(
                                    mainAxisAlignment:
                                        gameExistence == "preordered=1"
                                            ? MainAxisAlignment.start
                                            : MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: _gameExistenceState,
                                        style: ElevatedButton.styleFrom(
                                            shape: const StadiumBorder(),
                                            backgroundColor: buttonGrey),
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          gameExistence == "preordered=1"
                                              ? "Ordered"
                                              : "Own",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              height: 30,
                              constraints: const BoxConstraints(maxWidth: 100),
                              color: gamesOnly == ""
                                  ? Colors.yellowAccent
                                  : Colors.greenAccent,
                              child: Row(
                                mainAxisAlignment: gamesOnly == ""
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: _gamesOnlyState,
                                    style: ElevatedButton.styleFrom(
                                      shape: const StadiumBorder(),
                                      backgroundColor: buttonGrey,
                                    ),
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      gamesOnly == "" ? "All" : "Games",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            /// Filter Bar
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _onSortByNumPlaysPressed,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: darkGrey,
                            ),
                            child: Center(
                              child: Icon(
                                  _sortingOption == SortingOption.numPlays91
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward),
                            ),
                          ),
                        ),
                        const Text(
                          'Sort by Plays',
                          style: TextStyle(
                            color: basicLightGrey,
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _onSortByYearPublishedPressed,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: darkGrey,
                            ),
                            child: Center(
                              child: Icon(_sortingOption ==
                                      SortingOption.yearPublished91
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward),
                            ),
                          ),
                        ),
                        const Text(
                          'Sort by Published',
                          style: TextStyle(
                            color: basicLightGrey,
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _onSortByNamePressed,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: darkGrey,
                            ),
                            child: Center(
                              child: Icon(_sortingOption == SortingOption.nameAZ
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward),
                            ),
                          ),
                        ),
                        const Text(
                          'Sort by Name',
                          style: TextStyle(
                            color: basicLightGrey,
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// main LIst view
            Expanded(
              // Row B
              child: FutureBuilder<List<Game>>(
                future: _futureGames,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final games = snapshot.data!;
                    var sortedGames = _getSortedGames(_filterGames(games));
                    return GridView.count(
                      childAspectRatio: kIsWeb == true ? 0.78 : 0.47,
                      crossAxisCount: columnCount,
                      mainAxisSpacing: tenPadding,
                      crossAxisSpacing: tenPadding,
                      children: sortedGames.map((game) {
                        return Container(
                          color: const Color.fromARGB(255, 50, 50, 50),
                          padding: const EdgeInsets.all(tenPadding),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
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
          ],
        ),
      ),
    );
  }
}
