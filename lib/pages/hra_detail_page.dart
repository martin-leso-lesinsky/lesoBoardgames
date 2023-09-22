import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leso_board_games/components/constants.dart';
import 'package:leso_board_games/db/hras_database.dart';
import 'package:leso_board_games/models/hra_model.dart';
import 'package:leso_board_games/pages/hra_expansion_list_page.dart';
import 'package:leso_board_games/pages/hras_list_page.dart';
import 'package:leso_board_games/services/get_hra_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HraDetail extends StatefulWidget {
  final String bgUserName;
  final Map<String, dynamic> hraData;
  final int objectId;

  const HraDetail({super.key, required this.hraData, required this.bgUserName, required this.objectId});

  @override
  _HraDetailState createState() => _HraDetailState();
}

class _HraDetailState extends State<HraDetail> {
  num _totalGameValue = 0; // this stores total game value
  int detailGameExpansionCount = 0; // this stores total existing expansions

  late Map<String, dynamic> editedHraData;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    editedHraData = Map.from(widget.hraData);
    _calculateTotalGameValue(widget.objectId); // Calculate the total game value

    fetchDetailGameExpansionCount();
    // _fetchGameDetails();
  }

  void _enableEditing() {
    setState(() {
      isEditing = true;
    });
  }

  /// this gets total game value from [hras_database] => (getTotalGameValueByParentGameId)
  Future<void> _calculateTotalGameValue(int parentGameId) async {
    final totalGameValue = await HrasDatabase.instance.getTotalGameValueByParentGameId(parentGameId);
    setState(() {
      _totalGameValue = totalGameValue; // Update the state variable
    });
  }

  void _onSaveChanges() async {
    /// Get the updated Hra object from the editedHraData
    final updatedHra = Hra.fromJson(editedHraData);

    /// Update the Hra in the database
    await HrasDatabase.instance.update(updatedHra);

    /// Update totalValueGames and totalValueExpansions in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final gameValue = updatedHra.gameValue;

    if (updatedHra.subtype == 'boardgame') {
      final currentTotalValueGames = prefs.getInt('totalValueGames') ?? 0;
      prefs.setInt('totalValueGames', (currentTotalValueGames - gameValue + updatedHra.gameValue).round());
    } else if (updatedHra.subtype == 'boardgameexpansion') {
      final currentTotalValueExpansions = prefs.getInt('totalValueExpansions') ?? 0;
      prefs.setInt('totalValueExpansions', (currentTotalValueExpansions - gameValue + updatedHra.gameValue).round());
    }

    /// Disable editing mode
    setState(() {
      isEditing = false;
    });

    /// navigate to the previous screen
    Navigator.pop(context, true);
  }

  /// button BGG link to selected game
  _launchURLGame() async {
    final Uri url = Uri.parse('https://boardgamegeek.com/boardgame/${editedHraData[HraFields.objectId]}');

    if (!await launchUrl(url)) {
      throw Exception('Could not launch');
    }
  }

  int calculateDaysInCollection(DateTime obtainDate) {
    final currentDate = DateTime.now();
    final difference = currentDate.difference(obtainDate);
    return difference.inDays;
  }

  /// Fetch Game details - Expansions
  bool isFetching = false; // Add this variable
  Future<void> _fetchGameDetails() async {
    final objectId = widget.objectId;

    /// Fetch the expansion IDs only for board games
    if (widget.hraData[HraFields.subtype] == 'boardgame') {
      setState(() {
        isFetching = true; // Set fetching state to true
      });

      final expansionIds = await getExpansionIds(objectId.toString());

      /// Access the HrasDatabase instance and call updateParentGameForExpansion
      final hrasDatabase = HrasDatabase.instance;
      await hrasDatabase.updateParentGameForExpansion(objectId, expansionIds);

      setState(() {
        isFetching = false; // Set fetching state to false
      });
    }
  }

  Future<void> _navigateToHraDetail(BuildContext context, int objectId) async {
    final retrievedHra = await HrasDatabase.instance.getItemByObjectId(objectId);

    if (retrievedHra != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HraDetail(
            hraData: retrievedHra.toJson(),
            bgUserName: bgUserName, // Pass the bgUserName
            objectId: objectId,
          ),
        ),
      );

      if (result == true) {}
    }
  }

  Future<void> fetchDetailGameExpansionCount() async {
    final hrasDatabase = HrasDatabase.instance;
    final count = await hrasDatabase.getDetailGameExpansionCount(widget.objectId);
    setState(() {
      detailGameExpansionCount = count;
    });
  }

  /// number picker Dialog and Logic
  Future<void> _showNumberPickerDialog(BuildContext context) async {
    num selectedValue = editedHraData[HraFields.gameValue];

    // Create a TextEditingController and set its initial value
    TextEditingController controller = TextEditingController(text: selectedValue.toString());

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        /// Set the focus node to automatically open the keyboard
        FocusNode focusNode = FocusNode();

        /// Delay focusing on the text field to allow the keyboard to open first
        Future.delayed(const Duration(milliseconds: 300), () {
          focusNode.requestFocus();
        });

        String title;
        IconData icon;
        Color backgroundColor;

        if (editedHraData[HraFields.subtype] != 'boardgameexpansion') {
          title = 'Set Game Value';
          icon = Icons.casino_rounded; // Change the icon to a game controller
          backgroundColor = Colors.greenAccent; // Change the background color to green
        } else {
          title = 'Set Expansion Value';
          icon = Icons.extension; // Change the icon to a puzzle piece
          backgroundColor = Colors.yellow; // Change the background color to yellow
        }

        return AlertDialog(
          contentPadding: EdgeInsets.zero, // Remove default padding
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
          content: ClipRRect(
            // Clip content with rounded corners
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: backgroundColor,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(icon),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 26), // Set font size to 26
                    onChanged: (value) {
                      selectedValue = double.tryParse(value) ?? selectedValue;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            editedHraData[HraFields.gameValue] = selectedValue;
                          });
                          Navigator.pop(context); // Close the dialog
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusOwn = editedHraData[HraFields.statusOwn];
    return Scaffold(
      backgroundColor: Colors.black,

      /// Edit buttons
      appBar: AppBar(
        actions: statusOwn == 1
            ? [
                if (!isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _enableEditing,
                  ),
                if (isEditing)
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _onSaveChanges,
                  ),
              ]
            : [],
      ),

      /// Body Part
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FutureBuilder<Hra?>(
            future: HrasDatabase.instance.getItemByObjectId(widget.hraData[HraFields.objectId]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(), // Loading indicator while waiting for data
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Text('No data available');
              } else {
                final retrievedHra = snapshot.data!;

                /// Convert the obtainDate string to a DateTime object if available
                final obtainDate =
                    retrievedHra.obtainDate != null && retrievedHra.obtainDate != 'N/A' ? DateTime.parse(retrievedHra.obtainDate!) : null;

                /// Calculate days in collection if obtainDate is available
                final daysInCollection = obtainDate != null ? calculateDaysInCollection(obtainDate) : null;
                return SingleChildScrollView(
                  child: Column(children: [
                    /// Game Name container
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          retrievedHra.name,
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

                    /// Game data Row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Row(
                        children: [
                          /// Left - Game Picture column
                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          retrievedHra.image,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// Right - Game info column Alignment
                          Expanded(
                            child: Column(
                              children: [
                                /// Item Type container (Game / Expansion)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      /// change color according to item type Game = Green
                                      color: retrievedHra.subtype != 'boardgameexpansion' ? Colors.greenAccent : Colors.yellow[400],
                                      child: Row(
                                        /// change icon and Text according to item type Game = Green
                                        children: retrievedHra.subtype != 'boardgameexpansion'
                                            ? [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                  child: Row(
                                                    children: [
                                                      Column(
                                                        children: const [
                                                          Icon(
                                                            Icons.casino_rounded,
                                                            size: 28,
                                                          )
                                                        ],
                                                      ),
                                                      Column(
                                                        children: const [
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(5, 0, 10, 0),
                                                            child: Text(
                                                              "Game",
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.normal,
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ]
                                            : [
                                                const Padding(
                                                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                  child: Icon(
                                                    Icons.extension_rounded,
                                                    size: 28,
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.fromLTRB(5, 0, 20, 0),
                                                  child: Text(
                                                    "Expansion",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.normal,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),

                                /// Game info text
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            color: tileDarkGrey,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      const Padding(
                                                        padding: EdgeInsets.fromLTRB(5, 5, 15, 0),
                                                        child: Icon(Icons.calendar_month, color: Colors.white),
                                                      ),
                                                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                        const SizedBox(width: 10),
                                                        const Text(
                                                          "Published: ",
                                                          style: TextStyle(
                                                            color: basicLightGrey,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        Text(
                                                          retrievedHra.yearPublished,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ]),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      const Padding(
                                                        padding: EdgeInsets.fromLTRB(5, 5, 15, 0),
                                                        child: Icon(Icons.access_time, color: Colors.white),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            "In collection: ",
                                                            style: TextStyle(
                                                              // fontSize: 10,
                                                              color: basicLightGrey,
                                                            ),
                                                          ),
                                                          Text(
                                                            daysInCollection != null ? '$daysInCollection days' : 'N/A',
                                                            style: const TextStyle(
                                                              color: Colors.white,
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
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),

                                /// Editable value and obtained value field
                                Row(
                                  children: isEditing != true
                                      ? [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  width: 200,
                                                  color: Colors.blue[900],
                                                  padding: const EdgeInsets.all(10),
                                                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: statusOwn == 0
                                                          ? [
                                                              Padding(
                                                                padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                                                                child: Row(
                                                                  children: const [
                                                                    Icon(Icons.mail, color: Colors.blueAccent),
                                                                    SizedBox(width: 10),
                                                                    Text(
                                                                      "Ordered...",
                                                                      style: TextStyle(
                                                                          color: Colors.blueAccent, fontWeight: FontWeight.normal, fontSize: 18),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ]
                                                          : [
                                                              const Padding(
                                                                padding: EdgeInsets.fromLTRB(5, 5, 15, 0),
                                                                child: Icon(Icons.today, color: Colors.white),
                                                              ),
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const Text(
                                                                    "Obtained date: ",
                                                                    style: TextStyle(
                                                                      color: basicLightGrey,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    retrievedHra.obtainDate ?? 'N/A',
                                                                    style: const TextStyle(
                                                                      color: Colors.white,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: statusOwn != 0
                                                          ? [
                                                              const Padding(
                                                                padding: EdgeInsets.fromLTRB(5, 5, 15, 0),
                                                                child: Icon(Icons.monetization_on_outlined, color: Colors.white),
                                                              ),
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const Text(
                                                                    "Core game Value: ",
                                                                    style: TextStyle(
                                                                      color: basicLightGrey,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '${retrievedHra.gameValue} €',
                                                                    style: const TextStyle(
                                                                      color: Colors.white,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 20,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ]
                                                          : [],
                                                    ),
                                                  ]),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]
                                      : [],
                                ),
                                const SizedBox(height: 10),

                                /// will be showed only after click on edit button and edit button will appear only if statusOwn == 1
                                Row(
                                  children: isEditing == true
                                      ? [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  width: 200,
                                                  color: editedHraData[HraFields.subtype] == 'boardgame' ? Colors.greenAccent : Colors.yellow[400],
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                                    child: Column(
                                                      children: [
                                                        /// Obtained Date Row - value + Edit icon
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Add this line
                                                          children: [
                                                            /// Gesture trigger
                                                            GestureDetector(
                                                              onTap: () async {
                                                                final selectedDate = await showDatePicker(
                                                                  context: context,
                                                                  initialDate: DateTime.now(),
                                                                  firstDate: DateTime(1900),
                                                                  lastDate: DateTime.now(),
                                                                );

                                                                if (selectedDate != null) {
                                                                  setState(() {
                                                                    editedHraData[HraFields.obtainDate] =
                                                                        DateFormat('yyyy-MM-dd').format(selectedDate);
                                                                  });
                                                                }
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  /// Obtained Date value Calendar column
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Row(
                                                                        children: const [
                                                                          Text(
                                                                            'Obtained Date:',
                                                                            style: TextStyle(
                                                                              color: normalGrey,
                                                                              fontSize: 12,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            editedHraData[HraFields.obtainDate] ?? 'N/A',
                                                                            style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 16,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 10),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                            /// Edit Calendar Icon Column
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                              children: [
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    shape: BoxShape.circle,
                                                                    border: Border.all(
                                                                        color: editedHraData[HraFields.subtype] == 'boardgame'
                                                                            ? Colors.green
                                                                            : Colors.amberAccent,
                                                                        width: 2),
                                                                  ),
                                                                  child: IconButton(
                                                                    onPressed: () async {
                                                                      final selectedDate = await showDatePicker(
                                                                        context: context,
                                                                        initialDate: DateTime.now(),
                                                                        firstDate: DateTime(1900),
                                                                        lastDate: DateTime.now(),
                                                                      );

                                                                      if (selectedDate != null) {
                                                                        setState(() {
                                                                          editedHraData[HraFields.obtainDate] =
                                                                              DateFormat('yyyy-MM-dd').format(selectedDate);
                                                                        });
                                                                      }
                                                                    },
                                                                    icon: const Icon(
                                                                      Icons.calendar_today,
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 20),

                                                        /// Game Value  Row - value + Edit icon
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      const Text(
                                                                        'Game Value:',
                                                                        style: TextStyle(color: normalGrey, fontSize: 12),
                                                                      ),
                                                                      Text(
                                                                        editedHraData[HraFields.gameValue].toString(),
                                                                        style: const TextStyle(
                                                                          color: Colors.black,
                                                                          fontWeight: FontWeight.bold,
                                                                          fontSize: 18,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            if (isEditing)
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  shape: BoxShape.circle,
                                                                  border: Border.all(
                                                                      color: editedHraData[HraFields.subtype] == 'boardgame'
                                                                          ? Colors.green
                                                                          : Colors.amberAccent,
                                                                      width: 2),
                                                                ),
                                                                child: IconButton(
                                                                  icon: const Icon(Icons.edit, color: Colors.black),
                                                                  onPressed: () {
                                                                    _showNumberPickerDialog(context);
                                                                  },
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
                                          ),
                                        ]
                                      : [],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (editedHraData[HraFields.subtype] == 'boardgame')
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 100),
                          child: Row(
                            children: [
                              /// STATISTIC box = Played Games
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: tileDarkGrey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "P P P \nRatio: ",
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: normalGrey,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '0.54',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.greenAccent),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),

                              /// STATISTIC box = Played Games
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: tileDarkGrey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "Played Games: ",
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: normalGrey,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        retrievedHra.numPlays.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,

                                            /// change color according to item type Game = Green
                                            color: retrievedHra.numPlays == 0 ? Colors.grey : Colors.lightBlueAccent),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),

                              /// STATISTIC box = Cost Per Game its total Game value [gameValue + All expansions] divided played games
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: tileDarkGrey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "Cost per Game: ",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: normalGrey,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        maxLines: 3,
                                        retrievedHra.numPlays == 0 ? 'N/A' : (_totalGameValue / retrievedHra.numPlays).round().toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,

                                            /// change color according to item type Game = Green
                                            color: retrievedHra.numPlays == 0 ? Colors.grey : Colors.pinkAccent),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),

                              /// STATISTIC box = Total Value
                              Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  color: tileDarkGrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        "Total Game \nValue: ",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: normalGrey,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      // '($_totalGameValue.toStringAsFixed(2)) €',
                                      '${_totalGameValue.toStringAsFixed(2)} €',

                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,

                                        /// change color according to item type Game = Green
                                        color: retrievedHra.gameValue == 0 ? Colors.grey : Colors.yellow[400],
                                      ),
                                      // color: Colors.yellowAccent),
                                    ),
                                  ],
                                ),
                              ),
                              // const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),

                    /// Link Buttons ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// BUTTON BGG link to selected game
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Column(children: [
                            TextButton(
                              onPressed: _launchURLGame,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset('assets/images/BGG_icon.png', height: 50, width: 100, fit: BoxFit.fill),
                              ),
                            ),
                            Text(
                              'BGG Link',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                                fontSize: 10,
                              ),
                            ),
                          ]),
                        ),

                        /// BUTTON Expansions link to selected game
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 17, 0, 10),
                          child: Column(children: [
                            GestureDetector(
                              onTap: () {
                                if (retrievedHra.subtype != 'boardgame') {
                                  _navigateToHraDetail(context, retrievedHra.parentGameId!);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HraExpansionListPage(
                                        objectId: retrievedHra.objectId,
                                        gameValue: retrievedHra.gameValue,
                                        name: retrievedHra.name,
                                        expansions: const [],
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Row(
                                    children: statusOwn == 1
                                        ? [
                                            Row(
                                              children: retrievedHra.subtype != 'boardgameexpansion'
                                                  ? [
                                                      Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius: BorderRadius.circular(12),
                                                                child: Container(
                                                                  height: 50,
                                                                  color: Colors.amberAccent,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(10),
                                                                    child: Row(
                                                                      children: [
                                                                        const Icon(
                                                                          Icons.extension_rounded,
                                                                          size: 28,
                                                                        ),
                                                                        const SizedBox(width: 10),
                                                                        const Text(
                                                                          "Expansions",
                                                                          style: TextStyle(
                                                                            color: Colors.black,
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(width: 10),
                                                                        Container(
                                                                          width: 30,
                                                                          height: 30,
                                                                          decoration: BoxDecoration(
                                                                            color: tileDarkGrey,
                                                                            borderRadius: BorderRadius.circular(10),
                                                                          ),
                                                                          child: Center(
                                                                            child: Text(
                                                                              detailGameExpansionCount.toString(),
                                                                              style: const TextStyle(
                                                                                color: Colors.yellow,
                                                                                fontWeight: FontWeight.normal,
                                                                              ),
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
                                                          const SizedBox(height: 8),
                                                          Row(
                                                            children: const [
                                                              Text(
                                                                "See Expansions list",
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.amberAccent,
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    ]
                                                  : [
                                                      if (retrievedHra.parentGameId != 0)
                                                        Column(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius: BorderRadius.circular(12),
                                                              child: Container(
                                                                color: Colors.greenAccent,
                                                                height: 50,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                                                  child: Row(
                                                                    children: const [
                                                                      Icon(
                                                                        Icons.casino_rounded,
                                                                        size: 28,
                                                                      ),
                                                                      SizedBox(width: 10),
                                                                      Text(
                                                                        "Parent Game",
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
                                                            const SizedBox(height: 7),
                                                            Row(
                                                              children: const [
                                                                Text(
                                                                  "Navigate to Parent Game",
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Colors.greenAccent,
                                                                    fontSize: 10,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                    ],
                                            ),
                                          ]
                                        : [],
                                  )),
                            ),
                          ]),
                        ),

                        /// BUTTON Add Accessories link to selected game if is subtype =='boardgame' and statusOwn ==1
                        if (statusOwn == 1)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Column(
                              children: retrievedHra.subtype != 'boardgameexpansion'
                                  ? [
                                      Column(
                                        children: [
                                          TextButton(
                                            onPressed: _launchURLGame,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Container(
                                                height: 50,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: Row(
                                                    children: const [
                                                      Icon(
                                                        Icons.library_add_rounded,
                                                        color: darkBlue,
                                                        size: 28,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        "Add",
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
                                          ),
                                          const Text(
                                            'Add Accessories',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: darkBlue,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                      ],
                    ),
                  ]),
                );
              }
            }),
      ),

      /// back BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue[900],
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HrasPage(
                bgUserName: widget.bgUserName,
              ), // Replace HrasPage with your actual page name
            ),
          );
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
