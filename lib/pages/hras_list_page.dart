import 'package:flutter/material.dart';
import 'package:leso_board_games/components/constants.dart';
import 'package:leso_board_games/db/hras_database.dart';
import 'package:leso_board_games/models/hra_model.dart';
import 'package:leso_board_games/components/hra_list_tile_page.dart';
import 'package:leso_board_games/pages/hra_start_page.dart';
import 'package:leso_board_games/pages/hra_statistic_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ENUMS area
enum SortingOption {
  byPlays,
  byGameValue,
  byName,
  byPublished,
}

enum SubtypeFilter {
  games,
  expansions,
}

enum ExistenceFilter {
  own,
  preordered,
}

enum KnowledgeFilter {
  known,
  unKnown,
}

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
  int _itemCount = 0;

  int totalValueGames = 0;
  int totalCountGames = 0;
  int totalCountPlaysGames = 0;
  int totalValueExpansions = 0;
  int totalCountExpansions = 0;
  int totalCountOrderedGames = 0;
  int totalCountOrderedExpansions = 0;

  int totalCountKnownItems = 0;
  int totalCountUnKnownItems = 0;

  /// 1. Default switcher for Games/Expansion and Own/Preordered
  SubtypeFilter _selectedSubtype = SubtypeFilter.games;
  ExistenceFilter _selectedExistence = ExistenceFilter.own;
  KnowledgeFilter _selectedKnowledge = KnowledgeFilter.known;

  /// 2. determine sorting options also reverse mode
  SortingOption _sortingOption = SortingOption.byPlays;
  final Map<SortingOption, bool> _sortOrder = {
    SortingOption.byPlays: true,
    SortingOption.byGameValue: true,
    SortingOption.byName: true,
    SortingOption.byPublished: true,
  };

  /// 3. update global items Values
  Future<void> _updateTotalValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalValueGames = prefs.getInt('totalValueGames') ?? 0;
      totalCountGames = prefs.getInt('totalCountGames') ?? 0;
      totalCountPlaysGames = prefs.getInt('totalCountPlaysGames') ?? 0;
      totalValueExpansions = prefs.getInt('totalValueExpansions') ?? 0;
      totalCountExpansions = prefs.getInt('totalCountExpansions') ?? 0;

      totalCountOrderedGames = prefs.getInt('totalCountOrderedGames') ?? 0;
      totalCountOrderedExpansions = prefs.getInt('totalCountOrderedExpansions') ?? 0;
    });
  }

  Future<void> getCount() async {
    final totalCountKnownItemsData = await HrasDatabase.instance.countAllItemsKnown();
    final totalCountUnKnownItemsData = await HrasDatabase.instance.countAllItemsUnknown();
    setState(() {
      totalCountKnownItems = totalCountKnownItemsData;
      totalCountUnKnownItems = totalCountUnKnownItemsData;
    });
  }

  /// 4. initState
  @override
  void initState() {
    super.initState();
    getCount();
    _hrasFuture = _loadHras();
    _updateTotalValues();

    /// Default values for SubTypeFilter and ExistenceFilter
    _selectedSubtype = SubtypeFilter.games;
    _selectedExistence = ExistenceFilter.own;
    _selectedKnowledge = KnowledgeFilter.known;

    /// Default sorting Order by Name and ASC
    _sortingOption = SortingOption.byName;
    _sortOrder[SortingOption.byName] = true;
  }

  /// 5. Filtering games /Expansions + Own / Preordered
  Future<List<Hra>> _loadHras() async {
    final database = HrasDatabase.instance;

    /// Filter SubType based on selected filter
    List<Hra> subtypeFilteredHras = [];
    if (_selectedSubtype == SubtypeFilter.games) {
      subtypeFilteredHras = await database.getBoardGames();
    } else if (_selectedSubtype == SubtypeFilter.expansions) {
      subtypeFilteredHras = await database.getAllBoardGamesAndExpansions();
    }

    /// Filter existence based on selected filter
    List<Hra> existenceFilteredHras = [];
    if (_selectedExistence == ExistenceFilter.own) {
      existenceFilteredHras = await database.getOwnItems();
    } else if (_selectedExistence == ExistenceFilter.preordered) {
      existenceFilteredHras = await database.getPreorderedItems();
    }

    /// Filter knowledge based on selected filter
    List<Hra> knowledgeFilteredHras = [];
    if (_selectedKnowledge == KnowledgeFilter.known) {
      knowledgeFilteredHras = await database.showAllItemsUnknown();
    } else if (_selectedKnowledge == KnowledgeFilter.unKnown) {
      knowledgeFilteredHras = await database.showAllItemsKnown();
    }

    /// Combine the three filtered lists
    if (filterKnownItemsButton == false) {
      _filteredHras = subtypeFilteredHras.where((hra) => existenceFilteredHras.any((filteredHra) => hra.objectId == filteredHra.objectId)).toList();
    } else {
      _filteredHras = knowledgeFilteredHras.where((hra) => knowledgeFilteredHras.any((filteredHra) => hra.objectId == filteredHra.objectId)).toList();
    }

    /// Update the gameValue for each Hra in the filtered list
    final updatedHras = <Hra>[];
    for (var hra in _filteredHras) {
      final updatedHra = await database.getItemByObjectId(hra.objectId);
      if (updatedHra != null) {
        updatedHras.add(
          Hra(
            objectId: hra.objectId,
            name: hra.name,
            gameValue: updatedHra.gameValue, // Update gameValue
            yearPublished: hra.yearPublished,
            thumbnail: hra.thumbnail,
            numPlays: hra.numPlays,
            subtype: hra.subtype, collId: hra.collId, image: hra.image,
            statusOwn: hra.statusOwn,
          ),
        );
      } else {
        updatedHras.add(hra);
      }
    }
    _filteredHras = updatedHras;

    /// Initialize the item count with the total number of items
    _itemCount = _filteredHras.length;

    return _filteredHras;
  }

  /// 6. Sorting Method - sort displayed items  Name / Year Published / game Value / name
  Future<void> _sortHras(SortingOption option) async {
    setState(() {
      if (_sortingOption == option) {
        /// Toggle the order for the selected sorting option
        _sortOrder[option] = !_sortOrder[option]!;
      } else {
        _sortingOption = option;

        /// Reset order for other sorting options
        _sortOrder.forEach((key, value) {
          _sortOrder[key] = key == option;
        });
      }

      /// Sort the filtered list based on the selected option and order
      switch (option) {
        case SortingOption.byPlays:
          _filteredHras.sort((a, b) => _sortOrder[option]! ? a.numPlays.compareTo(b.numPlays) : b.numPlays.compareTo(a.numPlays));
          break;
        case SortingOption.byGameValue:
          _filteredHras.sort((a, b) => _sortOrder[option]! ? a.gameValue.compareTo(b.gameValue) : b.gameValue.compareTo(a.gameValue));
          break;
        case SortingOption.byName:
          _filteredHras.sort((a, b) => _sortOrder[option]! ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
          break;
        case SortingOption.byPublished:
          _filteredHras.sort((a, b) => _sortOrder[option]! ? a.yearPublished.compareTo(b.yearPublished) : b.yearPublished.compareTo(a.yearPublished));
          break;
      }
    });
    await _loadHras();
  }

  /// 7. Search Method - filter displayed items based on search query
  Future<void> _searchHras(String query) async {
    setState(() {
      // Create a copy of the current filtered list based on subtype and existence filters
      List<Hra> currentFilteredList = List.from(_filteredHras);

      if (query.isNotEmpty) {
        // Apply text search filter to the current filtered list
        _filteredHras = currentFilteredList.where((hra) => hra.name.toLowerCase().contains(query.toLowerCase())).toList();
      } else {
        // If query is empty, reset the filtered list to the current filtered list
        _filteredHras = List.from(currentFilteredList);
      }
    });
    _itemCount = _filteredHras.length;
    await _loadHras();
  }

  Future<void> _refreshData() async {
    await _loadHras();
    setState(() {});
  }

  bool filterKnownItemsButton = false; // Initial state of Filtering
  bool filterEnabledButton = false; // Initial state of Filtering

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 60, 60, 60),
        // 1 ROW ===>  number of actual items / Search for item / active BG user name / user settings
        title: Row(
          children: [
            /// COLUMN 1 ==> Filter switcher
            GestureDetector(
              onTap: () {
                setState(() {
                  // Toggle the value of filterEnabled
                  filterEnabledButton = !filterEnabledButton;
                  getCount();
                });
              },
              child: Icon(
                filterEnabledButton ? Icons.filter_list : Icons.filter_list_off, // Your filter icon
                color: filterEnabledButton ? Colors.greenAccent : Colors.grey, // Change color based on filterEnabled
              ),
            ),

            /// COLUMN 2 ==> number of actual items
            Container(
              width: 25,
              alignment: Alignment.centerRight,
              child: Text(
                _itemCount.toString(), // Display the item count
                style: const TextStyle(fontSize: 10, color: Colors.yellow),
              ),
            ),

            /// COLUMN 3 ==> Search Bar
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: tenPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _searchHras, // Call _searchHras on text change
                        decoration: const InputDecoration(
                          hintText: 'Search game...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Color.fromARGB(255, 118, 118, 118)),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Clear the text input when the "X" button is tapped
                        _searchController.clear();
                        _refreshData();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close,
                          color: normalGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),

            /// COLUMN 4 ==> Active BG User
            Text(
              widget.bgUserName,
              style: const TextStyle(fontSize: 16, color: Colors.lightBlue),
            ),
          ],
        ),

        /// user settings Icon
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: IconButton(
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
              color: Colors.lightBlue,
            ),
          ),
        ],

        /// Filters row operated by  "filterEnabled" icon
        bottom: PreferredSize(
          preferredSize: filterEnabledButton == true ? const Size.fromHeight(170.0) : const Size.fromHeight(50.0),
          child: Column(
            children: [
              /// 2 ROW ===>  Short Stats (Games[this will alternate with switch Games/Expansions] / plays / Value /  + Switchers
              Column(
                children: filterEnabledButton == true
                    ? [
                        Container(
                          color: Colors.black26,
                          child: SizedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /// 0 ==> Stats Part - Check Box to filter
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        filterKnownItemsButton = !filterKnownItemsButton;
                                        _loadHras();
                                      });
                                    },
                                    child: Icon(
                                      // filterKnownItemsButton ? Icons.arrow_circle_right_sharp : Icons.arrow_circle_up, // Your filter icon
                                      filterKnownItemsButton ? Icons.check_box : Icons.check_box_outline_blank, // Your filter icon
                                      color: filterKnownItemsButton ? Colors.greenAccent : Colors.grey, // Change color based on filterEnabled
                                    ),
                                  ),
                                  Container(
                                    width: 150,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: filterKnownItemsButton == false
                                          ? [
                                              const Text(
                                                'Check for filter by:\nKnown / Unknown items',
                                                style: TextStyle(
                                                  color: normalGrey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ]
                                          : [
                                              const Text(
                                                'Uncheck for filter by:\nOwn / SubType',
                                                style: TextStyle(
                                                  color: normalGrey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                    ),
                                  ),
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
                                          ),
                                        ),
                                      );
                                    },

                                    /// 1 ==> Stats Part - Games
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Items',
                                            style: TextStyle(
                                              color: Colors.lightBlueAccent,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            (totalCountGames + totalCountExpansions).toString(),
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  /// 2 ==> Stats Part - Plays
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Column(
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
                                          totalCountPlaysGames.toString(),
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// 3 ==> Stats Part - Value
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Value',
                                          style: TextStyle(
                                            color: Colors.lightBlueAccent,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          (totalValueGames + totalValueExpansions).toString(),
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        /// 2.5 ROW ===>  known Stats (show items who are known [they have filled obtainData and gameValue] and who are unknown.
                        Container(
                          color: Colors.black26,
                          child: SizedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /// Switchers area - Ordered/Own + Expansions/Games
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Column(
                                      children: filterKnownItemsButton == false
                                          ? [
                                              /// Switch Ordered/Own
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(0),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(15),
                                                      child: Container(
                                                        height: 30,
                                                        constraints: const BoxConstraints(maxWidth: 120),
                                                        color: _selectedExistence == ExistenceFilter.own ? Colors.greenAccent : Colors.deepPurple,
                                                        child: Row(
                                                          mainAxisAlignment: _selectedExistence == ExistenceFilter.own
                                                              ? MainAxisAlignment.start
                                                              : MainAxisAlignment.end,
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed: () async {
                                                                setState(
                                                                  () {
                                                                    _selectedExistence = (_selectedExistence == ExistenceFilter.own
                                                                        ? ExistenceFilter.preordered
                                                                        : ExistenceFilter.own);
                                                                  },
                                                                );
                                                                await _refreshData();
                                                              },
                                                              style:
                                                                  ElevatedButton.styleFrom(shape: const StadiumBorder(), backgroundColor: buttonGrey),
                                                              child: Text(
                                                                textAlign: TextAlign.center,
                                                                _selectedExistence == ExistenceFilter.own ? "Own" : "Ordered",
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
                                            ]
                                          : [],
                                    ),
                                  ),

                                  /// Switch Expansions/Games
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: filterKnownItemsButton == false
                                          ? [
                                              Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(15),
                                                  child: Container(
                                                    height: 30,
                                                    constraints: const BoxConstraints(maxWidth: 120),
                                                    color: _selectedSubtype == SubtypeFilter.games ? Colors.greenAccent : Colors.yellowAccent,
                                                    //Here
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          _selectedSubtype == SubtypeFilter.games ? MainAxisAlignment.start : MainAxisAlignment.end,
                                                      children: [
                                                        /// condition to display number of filtered Expansions
                                                        if (_selectedSubtype == SubtypeFilter.expansions)
                                                          Container(
                                                            alignment: Alignment.centerLeft,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(right: 10),
                                                              child: _selectedExistence == ExistenceFilter.own
                                                                  ? Text(
                                                                      (() {
                                                                        try {
                                                                          return (gamesCount + expansionsCount).toString();
                                                                        } catch (e) {
                                                                          print('Error parsing gamesCount or expansionsCount: $e');
                                                                          return 'N/A'; // Provide a fallback value
                                                                        }
                                                                      })(),
                                                                      style: const TextStyle(
                                                                        color: Colors.amber,
                                                                        fontSize: 14,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    )
                                                                  : Text(
                                                                      (totalCountOrderedExpansions + totalCountOrderedGames).toString(),
                                                                      style: const TextStyle(
                                                                        color: Colors.amber,
                                                                        fontSize: 14,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                            ),
                                                          ),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            setState(
                                                              () {
                                                                _selectedSubtype = (_selectedSubtype == SubtypeFilter.games
                                                                    ? SubtypeFilter.expansions
                                                                    : SubtypeFilter.games);
                                                              },
                                                            );
                                                            await _refreshData();
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            shape: const StadiumBorder(),
                                                            backgroundColor: buttonGrey,
                                                          ),
                                                          child: Text(
                                                            _selectedSubtype == SubtypeFilter.games ? 'Games' : 'All',
                                                            style: const TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),

                                                        /// condition to display number of filtered Games
                                                        if (_selectedSubtype == SubtypeFilter.games)
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 10),
                                                            child: _selectedExistence == ExistenceFilter.own
                                                                ? Text(
                                                                    gamesCount.toString(),
                                                                    style: const TextStyle(
                                                                      color: Colors.green,
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    totalCountOrderedGames.toString(),
                                                                    style: const TextStyle(
                                                                      color: Colors.green,
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]
                                          : [],
                                    ),
                                  ),

                                  /// Switch known/Unknown filter
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: filterKnownItemsButton == true
                                        ? [
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(15),
                                                child: Container(
                                                  height: 30,
                                                  constraints: const BoxConstraints(maxWidth: 170),
                                                  color: _selectedKnowledge == KnowledgeFilter.known ? Colors.redAccent : Colors.cyanAccent,
                                                  //Here
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        _selectedKnowledge == KnowledgeFilter.known ? MainAxisAlignment.start : MainAxisAlignment.end,
                                                    children: [
                                                      /// condition to display number of filtered Expansions
                                                      if (_selectedKnowledge == KnowledgeFilter.unKnown)
                                                        Container(
                                                          alignment: Alignment.centerLeft,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(right: 10),
                                                            child: _selectedExistence == KnowledgeFilter.known
                                                                ? Text(
                                                                    (() {
                                                                      try {
                                                                        return totalCountKnownItems.toString();
                                                                      } catch (e) {
                                                                        print('Error parsing gamesCount or expansionsCount: $e');
                                                                        return 'N/A'; // Provide a fallback value
                                                                      }
                                                                    })(),
                                                                    style: const TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    totalCountKnownItems.toString(),
                                                                    style: const TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                          ),
                                                        ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          setState(
                                                            () {
                                                              _selectedKnowledge = (_selectedKnowledge == KnowledgeFilter.known
                                                                  ? KnowledgeFilter.unKnown
                                                                  : KnowledgeFilter.known);
                                                            },
                                                          );
                                                          await _refreshData();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          shape: const StadiumBorder(),
                                                          backgroundColor: buttonGrey,
                                                        ),
                                                        child: Text(
                                                          _selectedKnowledge == KnowledgeFilter.known ? 'UnKnown Items' : 'Known Items',
                                                          style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),

                                                      /// condition to display number of filtered Games
                                                      if (_selectedKnowledge == KnowledgeFilter.known)
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 10),
                                                          child: _selectedExistence == KnowledgeFilter.known
                                                              ? Text(
                                                                  totalCountUnKnownItems.toString(),
                                                                  style: const TextStyle(
                                                                    color: Colors.blue,
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                )
                                                              : Text(
                                                                  totalCountUnKnownItems.toString(),
                                                                  style: const TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]
                                        : [],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]
                    : [],
              ),

              /// 3 ROW ===>  Sorting by Plays / Game Value / Published / Name
              Container(
                color: Colors.black54,
                child: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// [1] Sorting by Number of Plays
                        TextButton(
                          onPressed: () => _sortHras(SortingOption.byPlays),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: darkGrey,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _sortingOption == SortingOption.byPlays
                                          ? _sortOrder[SortingOption.byPlays]!
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward
                                          : Icons.arrow_downward,
                                      color: _sortingOption == SortingOption.byPlays ? Colors.lightBlueAccent : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                'Plays',
                                style: TextStyle(
                                  color: basicLightGrey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// [2] Sorting by Game Value
                        TextButton(
                          onPressed: () => _sortHras(SortingOption.byGameValue),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: darkGrey,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _sortingOption == SortingOption.byGameValue
                                          ? _sortOrder[SortingOption.byGameValue]!
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward
                                          : Icons.arrow_downward,
                                      color: _sortingOption == SortingOption.byGameValue ? Colors.lightBlueAccent : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                'Game Value',
                                style: TextStyle(
                                  color: basicLightGrey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// [3] Sorting by Game Name
                        TextButton(
                          onPressed: () => _sortHras(SortingOption.byName),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: darkGrey,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _sortingOption == SortingOption.byName
                                          ? _sortOrder[SortingOption.byName]!
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward
                                          : Icons.arrow_downward,
                                      color: _sortingOption == SortingOption.byName ? Colors.lightBlueAccent : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                'Name',
                                style: TextStyle(
                                  color: basicLightGrey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// [4] Sorting by Game Year of Published
                        TextButton(
                          onPressed: () => _sortHras(SortingOption.byPublished),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: darkGrey,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _sortingOption == SortingOption.byPublished
                                          ? _sortOrder[SortingOption.byPublished]!
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward
                                          : Icons.arrow_downward,
                                      color: _sortingOption == SortingOption.byPublished ? Colors.lightBlueAccent : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                'Year',
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
      backgroundColor: tileDarkGrey,
      body: RefreshIndicator(
        onRefresh: _refreshData, // Define the refresh callback
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: FutureBuilder<List<Hra>>(
            future: _hrasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading data'));
              } else {
                final hras = snapshot.data;
                if (hras != null && hras.isNotEmpty) {
                  /// Apply filters
                  List<Hra> filteredList = _filteredHras;

                  /// Apply search filter
                  if (_searchController.text.isNotEmpty) {
                    filteredList = filteredList.where((hra) => hra.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
                  }

                  // return GridView
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.37,
                      mainAxisSpacing: fivePadding,
                      crossAxisSpacing: fivePadding,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return HraListTile(
                        objectId: _filteredHras[index].objectId.toString(),
                        name: _filteredHras[index].name,
                        gameValue: _filteredHras[index].gameValue.toString(),
                        yearPublished: _filteredHras[index].yearPublished.toString(),
                        thumbnail: _filteredHras[index].thumbnail,
                        numPlays: _filteredHras[index].numPlays.toString(),
                        subtype: _filteredHras[index].subtype,
                        hras: _filteredHras,
                        bgUserName: widget.bgUserName,
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No HRAs found'));
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
