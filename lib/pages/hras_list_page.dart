import 'package:flutter/material.dart';
import 'package:leso_board_games/components/constants.dart';
import 'package:leso_board_games/db/hras_database.dart';
import 'package:leso_board_games/models/hra_model.dart';
import 'package:leso_board_games/components/hra_list_tile_page.dart';
import 'package:leso_board_games/pages/hra_start_page.dart';
import 'package:leso_board_games/pages/hra_statistic_page.dart';

var gameExistence = 'preordered=1';
var gamesOnly = 'All';

class HrasPage extends StatefulWidget {
  final String bgUserName;

  const HrasPage({
    required this.bgUserName,
    Key? key,
  }) : super(key: key);

  @override
  _HrasPageState createState() => _HrasPageState();
}

class _HrasPageState extends State<HrasPage> {
  late Future<List<Hra>> _hrasFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Hra> _filteredHras = [];
  List<Hra> _hras = [];
  int _itemCount = 0; // Variable to hold the count of items

  @override
  void initState() {
    super.initState();
    _loadHras();
    _searchController.addListener(_filterList);
  }

  void _filterList() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredHras = _hras; // Display all items when query is empty
      } else {
        _filteredHras = _hras
            .where((hra) => hra.name.toLowerCase().contains(query))
            .toList();
      }

      // Update the item count based on the filtered list
      _itemCount = _filteredHras.length;
    });
  }

  Future<void> _loadHras() async {
    final database = HrasDatabase.instance;
    _hras = await database.readAllHra();
    _filteredHras = _hras;
    _hrasFuture = Future.value(_hras);

    // Initialize the item count with the total number of items
    _itemCount = _hras.length;

    setState(() {}); // Trigger a rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 60, 60),
        // 1 ROW ===>  Search for application / user settings
        title: Row(
          children: [
            Text(
              '$_itemCount', // Display the item count
              style: const TextStyle(fontSize: 12, color: Colors.yellow),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: tenPadding),
                child: TextField(
                  controller:
                      _searchController, // Call _filterList on text change
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
            Text(
              widget.bgUserName,
              style: const TextStyle(fontSize: 16, color: Colors.lightBlue),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StartPage(
                          bgUserName: widget.bgUserName,
                        )),
              );
            },
            icon: const Icon(Icons.account_circle),
            iconSize: 30,
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120.0),
          child: Column(
            children: [
              /// 2 ROW ===>  Short Stats (Games[this will alternate with switch Games/Expansions] / plays / Value /  + Switchers
              Container(
                color: Colors.black26,
                child: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to hra_statistic_page.dart when tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HraStatisticPage(
                                        expansionsInDatabase: 1,
                                        gamesInDatabase: 2,
                                        totalPlays: 3,
                                        valueForExpansions: 4,
                                        valueForGames: 5,
                                      )),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Games',
                                style: TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                gamesCount,
                                // gamesData.gamesCount,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Plays',
                              style: TextStyle(
                                color: Colors.lightBlueAccent,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              playsCount,
                              // '206',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 18,
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
                                color: Colors.lightBlueAccent,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '120',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
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
                                          constraints: const BoxConstraints(
                                              maxWidth: 100),
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
                                                onPressed: null,
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        const StadiumBorder(),
                                                    backgroundColor:
                                                        buttonGrey),
                                                child: Text(
                                                  textAlign: TextAlign.center,
                                                  gameExistence ==
                                                          "preordered=1"
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
                                  constraints:
                                      const BoxConstraints(maxWidth: 100),
                                  color: gamesOnly == ""
                                      ? Colors.yellowAccent
                                      : Colors.greenAccent,
                                  child: Row(
                                    mainAxisAlignment: gamesOnly == ""
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: null,
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
              ),

              /// 3 ROW ===>  Sorting by Plays / Published (should be replaced by value) / Name
              Container(
                color: Colors.black54,
                child: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: null,
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: darkGrey,
                                  ),
                                  child: const Center(
                                    // Icon(
                                    //   _sortingOption ==
                                    //           SortingOption.yearPublished91
                                    //       ? Icons.arrow_upward
                                    //       : Icons.arrow_downward,
                                    //   color: Colors.white, // Adjust the icon color
                                    // ),
                                    child: Icon(
                                      Icons.arrow_downward,
                                      color: Colors
                                          .lightBlueAccent, // Adjust the icon color
                                    ),
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
                          onPressed: null,
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: darkGrey,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.arrow_downward,
                                      color: Colors
                                          .lightBlueAccent, // Adjust the icon color
                                    ),
                                    // child: Icon(
                                    //   _sortingOption ==
                                    //           SortingOption.yearPublished91
                                    //       ? Icons.arrow_upward
                                    //       : Icons.arrow_downward,
                                    //   color: Colors.white, // Adjust the icon color
                                    // ),
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
                          onPressed: null,
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: darkGrey,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.arrow_downward,
                                      color: Colors
                                          .lightBlueAccent, // Adjust the icon color
                                    ),
                                    // child: Icon(
                                    //   _sortingOption == SortingOption.nameAZ
                                    //       ? Icons.arrow_upward
                                    //       : Icons.arrow_downward,
                                    //   color: Colors.white, // Adjust the icon color
                                    // ),
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
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 35, 35, 35),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: FutureBuilder<List<Hra>>(
          future: _hrasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              /// While waiting for data to load, show a loading indicator
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              /// If there was an error loading data, show an error message
              return const Center(child: Text('Error loading data'));
            } else {
              /// If data was successfully loaded, build the scrollable grid
              final hras = snapshot.data;
              if (hras != null && hras.isNotEmpty) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Two columns
                    childAspectRatio: 0.32,
                    mainAxisSpacing: fivePadding,
                    crossAxisSpacing: fivePadding,
                  ),
                  itemCount: _filteredHras.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: HraListTile(
                        objectId: _filteredHras[index].objectId.toString(),
                        name: _filteredHras[index].name,
                        gameValue: _filteredHras[index].gameValue.toString(),
                        yearPublished:
                            _filteredHras[index].yearPublished.toString(),
                        thumbnail: _filteredHras[index].thumbnail,
                        numPlays: _filteredHras[index].numPlays.toString(),
                        subtype: _filteredHras[index].subtype,
                        hras: _filteredHras,
                        bgUserName: widget.bgUserName,
                      ),
                    );
                  },
                );
              } else {
                /// If there are no Hras in the database, show a message
                return const Center(child: Text('No HRAs found'));
              }
            }
          },
        ),
      ),
    );
  }
}
