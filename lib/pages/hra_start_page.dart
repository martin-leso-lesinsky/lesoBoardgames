import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leso_board_games/db/hras_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leso_board_games/pages/hras_list_page.dart';

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

  @override
  void initState() {
    super.initState();
    _bgUserNameController.clear();
    _getLastUsedUser();
    _bgUserNameController.addListener(_onUserNameChanged);
  }

  @override
  void dispose() {
    _bgUserNameController.removeListener(_onUserNameChanged);
    _bgUserNameController.dispose();
    super.dispose();
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

  Future<void> _deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('lastUsedUser');
    setState(() {
      _lastUsedUser = '';
      _bgUserNameController.clear();
    });
    print('User was deleted');

    await HrasDatabase.instance.deleteData();
    print('Db was cleared');
  }

  /// Function to format the date string
  String formatLastBgSync(String dateString) {
    final originalFormat = DateFormat('E, d MMM yyyy HH:mm:ss Z');
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[350],
        padding: const EdgeInsets.only(top: 100),
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
                      _lastUsedUser.isEmpty
                          ? 'Please enter BG user...'
                          : 'BG user:',
                      style:
                          const TextStyle(fontSize: 20, color: Colors.blueGrey),
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
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors
                                        .blueGrey), // Font size for 'Last sync:'
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

                /// 3 ROW ===>  Sync Button Displayed only if BG user is not empty
                if (_lastUsedUser.isNotEmpty)
                  ElevatedButton(
                    onPressed: (_lastUsedUser.isNotEmpty ||
                            _bgUserNameController.text.isNotEmpty)
                        ? () async {
                            final bgUserName = _bgUserNameController.text;
                            _setLastUsedUser(bgUserName);

                            /// Show a loading spinner while data is being fetched
                            showDialog(
                              context: context,
                              barrierDismissible:
                                  false, // Prevent user from dismissing the dialog
                              builder: (BuildContext context) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            /// Call the populateDatabaseFromApi function here
                            await HrasDatabase.instance
                                .populateDatabaseFromApi(bgUserName);

                            /// Close the loading spinner dialog
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.account_circle),
                                      const SizedBox(width: 8),
                                      Text('$bgUserName - ' +
                                          'Database refreshed!'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today),
                                      const SizedBox(width: 8),
                                      Text('Last Sync: $_lastBgSync'),
                                    ],
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.deepPurple,
                            ));

                            /// Check and show snack bars if new Game was added
                            if (HrasDatabase.instance.newGameAdded) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.casino_rounded,
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
                              HrasDatabase.instance
                                  .resetNewFlags(); // Reset the flag
                            }

                            /// Check and show snack bars if new Expansion was added
                            if (HrasDatabase.instance.newExpansionAdded) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.extension_rounded,
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
                              HrasDatabase.instance
                                  .resetNewFlags(); // Reset the flag
                            }

                            /// Check and show snack bars if new Expansion was added
                            if (HrasDatabase.instance.newPlaysAdded) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.extension_rounded,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'New Plays was Added',
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
                              HrasDatabase.instance
                                  .resetNewFlags(); // Reset the flag
                            }

                            /// Navigate to hras_list_page.dart
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HrasPage(
                                        bgUserName: bgUserName,
                                      )),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: _lastUsedUser.isNotEmpty
                          ? Colors.greenAccent.shade400
                          : Colors.orange[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Sync $_lastUsedUser',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),

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

                const SizedBox(height: 20),

                /// 5 ROW ===>  SET new user
                if (_lastUsedUser.isEmpty)
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: (_lastUsedUser.isNotEmpty ||
                                _bgUserNameController.text.isNotEmpty)
                            ? () async {
                                final newBgUserName =
                                    _bgUserNameController.text;
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
                                  await HrasDatabase.instance
                                      .populateDatabaseFromApi(newBgUserName);

                                  /// Close the loading spinner dialog
                                  Navigator.pop(context);

                                  /// show snackBar
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.account_circle),
                                            const SizedBox(width: 10),
                                            Text(
                                              '$newBgUserName' +
                                                  ' - BG user Set and Updated',
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.greenAccent,
                                  ));

                                  /// Navigate to HrasPage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HrasPage(
                                              bgUserName: newBgUserName,
                                            )),
                                  );
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

                /// 6 ROW ===>  Delete User Button will delete user and clear Database
                if (_lastUsedUser.isNotEmpty)
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
                                    Navigator.of(context)
                                        .pop(); // Close the dialog

                                    /// Snack Bar  Deleted BG User
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.account_circle),
                                              const SizedBox(width: 10),
                                              Text(
                                                '$_lastUsedUser'
                                                ' - BG user Deleted !',
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15),
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
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
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
                      child: const Text('Delete User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          )),
                    ),
                  ),

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
                        children: const [
                          Text(
                            'User Stats: ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Icon(
                            Icons.casino_rounded,
                            size: 28,
                          ), // Icon before text
                          const SizedBox(
                              width: 8), // Spacer between icon and text
                          const Text('Games in Database: '),
                          Text(
                            gamesCount.toString(),
                            style: const TextStyle(
                              color: Colors.black,
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
                          ), // Icon before text
                          const SizedBox(
                              width: 8), // Spacer between icon and text
                          const Text('Expansions in Database: '),
                          Text(
                            expansionsCount,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.play_circle), // Icon before text
                          const SizedBox(
                              width: 8), // Spacer between icon and text
                          const Text('Total Plays: '),
                          Text(
                            playsCount,
                            style: const TextStyle(
                              color: Colors.black,
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
    );
  }
}
