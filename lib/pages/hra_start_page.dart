import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:leso_board_games/db/hras_database.dart';
import 'package:leso_board_games/pages/statistic_graph_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leso_board_games/pages/hras_list_page.dart';
import 'package:leso_board_games/components/constants.dart';

late String lastBgSync;

class StartPage extends StatefulWidget {
  final String bgUserName;

  const StartPage({
    required this.bgUserName,
    Key? key,
  }) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final TextEditingController _bgUserNameController = TextEditingController();

  String _lastUsedUser = '';
  String _lastBgSync = '';
  int totalNumPlays = 0;

  int totalValueGames = 0;
  int totalCountGames = 0;
  int totalCountPlaysGames = 0;
  int totalValueExpansions = 0;
  int totalCountExpansions = 0;
  int totalCountOrderedGames = 0;
  int totalCountOrderedExpansions = 0;

  @override
  void initState() {
    super.initState();
    _bgUserNameController.clear();
    _getLastUsedUser();
    _bgUserNameController.addListener(_onUserNameChanged);
    _updateTotalValues();
  }

  /// update shared preferences of global info
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

  void _onUserNameChanged() {
    _getLastUsedUser();
    setState(() {}); // Update the state when the user name changes
  }

  void _getLastUsedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUsedUser = prefs.getString('lastUsedUser') ?? '';
    final lastBgSync = prefs.getString('lastBgSync') ?? '';
    final lastTotalNumPlays = prefs.getInt('totalNumPlays') ?? 0;
    setState(() {
      _lastUsedUser = lastUsedUser;
      _lastBgSync = lastBgSync;
      totalNumPlays = lastTotalNumPlays;
      if (_bgUserNameController.text.isEmpty) {
        _bgUserNameController.text = lastUsedUser;
      }
    });
  }

  void _setLastUsedUser(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('lastUsedUser', userName);
  }

  /// delete last existing user drops database and cleans shared preferences
  Future<void> _deleteUser() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear user-related preferences
    prefs.remove('lastUsedUser');
    _bgUserNameController.clear();
    setState(() {
      _lastUsedUser = '';
    });

    // Clear game-related preferences
    prefs.setInt('totalValueGames', 0);
    prefs.setInt('totalCountGames', 0);
    prefs.setInt('totalCountPlaysGames', 0);
    prefs.setInt('totalValueExpansions', 0);
    prefs.setInt('totalCountExpansions', 0);
    prefs.setInt('totalCountOrderedGames', 0);
    prefs.setInt('totalCountOrderedExpansions', 0);
    _updateTotalValues(); // Update the displayed values

    print('User data and preferences were cleared');

    await HrasDatabase.instance.deleteData();
    print('Db was cleared');
  }

  /// Function to format the date string
  String formatLastBgSync(String dateString) {
    final originalFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
    // final originalFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    // Adjusted format
    final newFormat = DateFormat('dd MMM yyyy HH:mm:ss');

    final dateTime = originalFormat.parse(dateString);
    final formattedString = newFormat.format(dateTime);

    return formattedString;
  }

  Future<int?> _checkDatabaseNotEmpty() async {
    final database = HrasDatabase.instance;
    return await database.getHrasCount();
  }

  @override
  void dispose() {
    _bgUserNameController.removeListener(_onUserNameChanged);
    _bgUserNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 50, 0, 50),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),

              /// page frame Column
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 1 ROW ===> BG selected user
                  Row(
                    children: [
                      const Icon(Icons.account_circle, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _lastUsedUser.isEmpty ? 'Please enter BG user...' : 'BG user:',
                        style: const TextStyle(fontSize: 20, color: Colors.blueGrey),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(
                          _lastUsedUser.isEmpty ? '' : _lastUsedUser,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// 2 ROW ===> Last sync row displayed only if BG user is not empty
                  if (_lastUsedUser.isNotEmpty)
                    Row(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.sync),
                                // Sync icon
                                SizedBox(width: 5),
                                Text(
                                  'Last sync: ', // Display the last sync time here
                                  style: TextStyle(fontSize: 20, color: Colors.blueGrey), // Font size for 'Last sync:'
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 0),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.tealAccent.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    formatLastBgSync(_lastBgSync),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  /// Line Divider
                  if (_lastUsedUser.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Column(
                        children: const [
                          Divider(
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),

                  /// 3 ROW ===>  Sync Button / Delete Button Displayed only if BG user is not empty
                  if (_lastUsedUser.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Sync Button
                        ElevatedButton(
                          onPressed: (_lastUsedUser.isNotEmpty || _bgUserNameController.text.isNotEmpty)
                              ? () async {
                                  final bgUserName = _bgUserNameController.text;
                                  _setLastUsedUser(bgUserName);

                                  /// Show a loading spinner while data is being fetched
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false, // Prevent user from dismissing the dialog
                                    builder: (BuildContext context) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  );

                                  /// Call the populateDatabaseFromApi function here
                                  await HrasDatabase.instance.populateDatabaseFromApi(bgUserName);

                                  /// Call the populateExpansionsData
                                  await HrasDatabase.instance.populateDatabaseWithExpansions();

                                  /// Close the loading spinner dialog
                                  Navigator.pop(context);

                                  /// This stores shared preferences for displaying snack bar if play/ boardgame or expansion was added
                                  final prefs = await SharedPreferences.getInstance();
                                  bool newPlaysAdded = prefs.getBool('newPlaysAdded') ?? false;
                                  bool newGameAdded = prefs.getBool('newGameAdded') ?? false;
                                  bool newExpansionAdded = prefs.getBool('newExpansionAdded') ?? false;

                                  /// if true => display message New plays added
                                  if (newPlaysAdded) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: const [
                                              Icon(
                                                Icons.info_outline_rounded,
                                                color: Colors.black,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'New Plays were Added',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.blueAccent,
                                    ));
                                    // Reset the flag after showing the Snackbar
                                    prefs.setBool('newPlaysAdded', false);
                                  }

                                  /// if true => display message New BoardGame added
                                  if (newGameAdded) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: const [
                                              Icon(
                                                Icons.info_outline_rounded,
                                                color: Colors.black,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'New BoardGame Added',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.greenAccent,
                                    ));
                                    // Reset the flag after showing the Snackbar
                                    prefs.setBool('newGameAdded', false);
                                  }

                                  /// if true => display message New Expansion added
                                  if (newExpansionAdded) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: const [
                                              Icon(
                                                Icons.info_outline_rounded,
                                                color: Colors.black,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'New Expansion Added',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.yellowAccent,
                                    ));
                                    // Reset the flag after showing the Snackbar
                                    prefs.setBool('newExpansionAdded', false);
                                  }

                                  /// update new global values info
                                  _updateTotalValues();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: _lastUsedUser.isNotEmpty ? Colors.greenAccent.shade400 : Colors.orange[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.sync,
                                  color: Colors.black,
                                  size: 26,
                                ),
                                SizedBox(width: 10), // Add some spacing between the icon and text
                                Text(
                                  'Sync',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// Delete User Button
                        Container(
                          alignment: Alignment.topRight,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  /// Alert fo deletion Dialog
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    title: Row(
                                      children: const [
                                        Icon(Icons.warning, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete User & Drop Database'), // Text
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text(
                                          'Do you really want to Delete current User, and drop your current database?',
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(height: 30),
                                        Text(
                                          'All created data and whole Database which are not part of BG-fetch-data-API will be permanently deleted from your device.',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          _deleteUser();
                                          Navigator.of(context).pop(); // Close the dialog

                                          /// Snack Bar  Deleted BG User
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.account_circle),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      '$_lastUsedUser'
                                                      ' - BG user Deleted !',
                                                      style: const TextStyle(color: Colors.black, fontSize: 15),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.yellowAccent,
                                          ));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.redAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the dialog
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.red[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.delete_forever,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  SizedBox(width: 10), // Add some spacing between the icon and text
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  /// Space Divider
                  const SizedBox(height: 20),

                  /// 4 CONTAINER ===>  Set BG user name field - visible if There is no user
                  if (_lastUsedUser.isEmpty)
                    TextFormField(
                      controller: _bgUserNameController,
                      decoration: InputDecoration(
                        hintText: 'enter BG user name...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.yellow,
                            )),
                        filled: true,
                        fillColor: Colors.blueGrey.shade800,
                      ),
                      style: const TextStyle(color: Colors.orange),
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),

                  /// Space Divider
                  const SizedBox(height: 20),

                  /// 5 ROW ===>  SET new user
                  if (_lastUsedUser.isEmpty)
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: (_lastUsedUser.isNotEmpty || _bgUserNameController.text.isNotEmpty)
                              ? () async {
                                  final newBgUserName = _bgUserNameController.text;
                                  if (newBgUserName != _lastUsedUser) {
                                    /// Show a loading spinner while data is being processed
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,

                                      /// Prevent user from dismissing the dialog
                                      builder: (BuildContext context) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    );

                                    /// Clear Database
                                    if (_lastUsedUser.isNotEmpty) {
                                      await HrasDatabase.instance.deleteData();
                                    }

                                    /// Set new user
                                    _setLastUsedUser(newBgUserName);

                                    /// Call the populateDatabaseFromApi for new User
                                    await HrasDatabase.instance.populateDatabaseFromApi(newBgUserName);

                                    /// update global info values
                                    _updateTotalValues();

                                    /// Close the loading spinner dialog
                                    Navigator.pop(context);

                                    /// show snackBar
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.account_circle),
                                              const SizedBox(width: 10),
                                              Text(
                                                '$newBgUserName - BG user Set and Updated',
                                                style: const TextStyle(color: Colors.black, fontSize: 15),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.greenAccent,
                                    ));
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.greenAccent.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text(
                            'Set BG user',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),

                  /// Line Divider
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Column(
                      children: const [
                        Divider(
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  /// 6 ROW ===>  Enter Statistic Graph Button will enters collection without sync online Database
                  if (_lastUsedUser.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          alignment: Alignment.topRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StatisticGraphPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.blueAccent[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('Graph \nStatistic',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  )),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HrasPage(
                                    bgUserName: _lastUsedUser,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.yellowAccent[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('Enter \nCollection',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),

                  /// Line Divider
                  if (_lastUsedUser.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Column(
                        children: const [
                          Divider(
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),

                  /// 7 ROW ===>  User global stats
                  if (_lastUsedUser.isNotEmpty)
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '$_lastUsedUser BG Stats: ',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        /// Total board game value
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.mood_outlined,
                                      color: middleGrey,
                                      size: 30,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Total Money spent in your \nBoard Games collection: ',
                                      style: TextStyle(
                                        color: Colors.purpleAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    '${totalValueGames + totalValueExpansions} €',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Column(
                            children: const [
                              Divider(
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.casino_rounded,
                              size: 28,
                              color: middleGrey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Games in Database: ',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              totalCountGames.toString(),
                              style: const TextStyle(
                                color: middleGrey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.extension_rounded,
                              size: 28,
                              color: middleGrey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Expansions in Database: ',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              totalCountExpansions.toString(),
                              style: const TextStyle(
                                color: middleGrey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.play_circle,
                              color: middleGrey,
                            ), //
                            const SizedBox(width: 8),
                            const Text(
                              'Total Plays: ',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              totalCountPlaysGames.toString(),
                              style: const TextStyle(
                                color: middleGrey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: middleGrey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Games Value: ',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              totalValueGames.toString(),
                              style: const TextStyle(
                                color: middleGrey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: middleGrey,
                            ), // Icon before text
                            const SizedBox(width: 8), // Spacer between icon and text
                            const Text(
                              'Expansions Value: ',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              totalValueExpansions.toString(),
                              style: const TextStyle(
                                color: middleGrey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.local_shipping,
                              color: middleGrey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Games Ordered: ',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              totalCountOrderedGames.toString(),
                              style: const TextStyle(
                                color: middleGrey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.local_shipping,
                              color: middleGrey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Expansions Ordered: ',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              totalCountOrderedExpansions.toString(),
                              style: const TextStyle(
                                color: middleGrey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
