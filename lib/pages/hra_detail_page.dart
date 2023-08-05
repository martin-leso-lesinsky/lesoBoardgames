// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leso_board_games/components/constants.dart';
import 'package:leso_board_games/db/hras_database.dart';
import 'package:leso_board_games/models/hra_model.dart';
import 'package:leso_board_games/pages/hra_expansion_list_page.dart';
import 'package:leso_board_games/pages/hras_list_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HraDetail extends StatefulWidget {
  final String bgUserName;
  final Map<String, dynamic> hraData;
  const HraDetail({super.key, required this.hraData, required this.bgUserName});

  @override
  _HraDetailState createState() => _HraDetailState();
}

class _HraDetailState extends State<HraDetail> {
  late Map<String, dynamic> editedHraData;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    editedHraData = Map.from(widget.hraData);
  }

  void _enableEditing() {
    setState(() {
      isEditing = true;
    });
  }

  void _onSaveChanges() async {
    /// Get the updated Hra object from the editedHraData
    final updatedHra = Hra.fromJson(editedHraData);

    /// Update the Hra in the database
    await HrasDatabase.instance.update(updatedHra);

    /// Disable editing mode
    setState(() {
      isEditing = false;
    });

    /// Navigate back to the previous page after saving changes
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HrasPage(
          bgUserName: bgUserName,
        ),
      ),
    );
  }

  /// button BGG link to selected game
  _launchURLGame() async {
    final Uri url = Uri.parse(
        'https://boardgamegeek.com/boardgame/${editedHraData[HraFields.objectId]}');

    if (!await launchUrl(url)) {
      throw Exception('Could not launch');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final id = editedHraData[HraFields.id];
    // final objectId = editedHraData[HraFields.objectId];
    final subtype = editedHraData[HraFields.subtype];
    // final collId = editedHraData[HraFields.collId];
    final name = editedHraData[HraFields.name];
    final yearPublished = editedHraData[HraFields.yearPublished];
    final image = editedHraData[HraFields.image];
    // final thumbnail = editedHraData[HraFields.thumbnail];
    final statusOwn = editedHraData[HraFields.statusOwn];
    final numPlays = editedHraData[HraFields.numPlays];
    final gameValue = editedHraData[HraFields.gameValue];
    final obtainDate = editedHraData[HraFields.obtainDate];

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
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(children: [
              /// Game Name container
              Container(
                alignment: Alignment.center,
                child: Text(
                  name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// Game data Row
              Row(
                children: [
                  /// Left - Game Picture column
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              image,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Right - Game info column Alignment
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        /// Item Type container (Game / Expansion)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            // constraints: const BoxConstraints(
                            //     maxWidth: 140, maxHeight: 110),

                            /// change color according to item type Game = Green
                            color: subtype != 'boardgameexpansion'
                                ? Colors.greenAccent
                                : Colors.yellow[400],
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,

                              /// change icon and Text according to item type Game = Green
                              children: subtype != 'boardgameexpansion'
                                  ? [
                                      Padding(
                                        padding: const EdgeInsets.all(10),
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
                                            const SizedBox(width: 5),
                                            Column(
                                              children: const [
                                                Text(
                                                  "Game",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
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
                                        padding: EdgeInsets.all(10),
                                        child: Icon(
                                          Icons.extension_rounded,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
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
                        const SizedBox(height: 10),

                        /// Game info text
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  color: tileDarkGrey,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.calendar_month,
                                                color: Colors.white),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "Published: ",
                                              style: TextStyle(
                                                color: basicLightGrey,
                                              ),
                                            ),
                                            Text(
                                              yearPublished,
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
                                                // fontSize: 10,
                                                color: basicLightGrey,
                                              ),
                                            ),
                                            Text(
                                              "9999 days",
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        /// Editable value and obtained value field
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 200,
                                  color: Colors.blue[900],
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: statusOwn == 0
                                              ? [
                                                  Image.asset(
                                                      'assets/images/delivery_icon2.png',
                                                      height: 24,
                                                      fit: BoxFit.fill),
                                                  const SizedBox(width: 10),
                                                  const Text(
                                                    "Ordered",
                                                    style: TextStyle(
                                                      color: basicLightGrey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ]
                                              : [
                                                  const Icon(Icons.today,
                                                      color: Colors.white),
                                                  const SizedBox(width: 10),
                                                  const Text(
                                                    "Obtained: ",
                                                    style: TextStyle(
                                                      color: basicLightGrey,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "26.12.2019",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: statusOwn != 0
                                              ? [
                                                  const Icon(
                                                      Icons
                                                          .monetization_on_outlined,
                                                      color: Colors.white),
                                                  const SizedBox(width: 10),
                                                  const Text(
                                                    "Core game Value: ",
                                                    style: TextStyle(
                                                      color: basicLightGrey,
                                                    ),
                                                  ),
                                                  Text(
                                                    gameValue.toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                      ]),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        /// will be showed only after click on edit button and edit button will appear only if statusOwn == 1
                        Row(
                          children: isEditing == true
                              ? [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 200,
                                        color: Colors.blue[900],
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              enabled: isEditing,
                                              initialValue:
                                                  gameValue.toString(),
                                              onChanged: (value) {
                                                setState(() {
                                                  editedHraData[
                                                          HraFields.gameValue] =
                                                      int.parse(value);
                                                });
                                              },
                                              decoration: const InputDecoration(
                                                  labelText: 'gameValue'),
                                            ),
                                            const SizedBox(height: 10),
                                            TextFormField(
                                              enabled: isEditing,
                                              initialValue: obtainDate,
                                              onChanged: (value) {
                                                setState(() {
                                                  editedHraData[HraFields
                                                      .obtainDate] = value;
                                                });
                                              },
                                              decoration: const InputDecoration(
                                                  labelText: 'obtainDate'),
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
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: [
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
                                      "Price Per Play Ratio: ",
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
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        color: Colors.greenAccent),
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
                                    numPlays.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,

                                        /// change color according to item type Game = Green
                                        color: numPlays == 0
                                            ? Colors.grey
                                            : Colors.lightBlueAccent),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          /// STATISTIC box = Cost Per Game
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
                                    numPlays == 0
                                        ? 'N/A'
                                        : (gameValue / numPlays)
                                            .round()
                                            .toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,

                                        /// change color according to item type Game = Green
                                        color: numPlays == 0
                                            ? Colors.grey
                                            : Colors.pinkAccent),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          /// STATISTIC box = Total Value
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
                                      "Total Value: ",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: normalGrey,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$gameValue €',

                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,

                                      /// change color according to item type Game = Green
                                      color: gameValue == 0
                                          ? Colors.grey
                                          : Colors.yellow[400],
                                    ),
                                    // color: Colors.yellowAccent),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              /// BUTTON BGG link to selected game
              /// VALUE of game stats
              Row(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(children: [
                          TextButton(
                            onPressed: _launchURLGame,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset('assets/images/BGG_icon.png',
                                  height: 50, width: 100, fit: BoxFit.fill),
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
                    ],
                  ),
                  Column(

                      /// BUTTON Expansions link to selected game
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HraExpansionListPage(
                                    key: null,
                                  ),
                                ),
                              ),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 50,
                                    width: 150,

                                    /// change color according to item type Game = Green
                                    color: subtype != 'boardgameexpansion'
                                        ? Colors.amberAccent
                                        : Colors.greenAccent,
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Row(
                                          children: subtype !=
                                                  'boardgameexpansion'
                                              ? [
                                                  const Icon(
                                                    Icons.extension_rounded,
                                                    size: 28,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  const Text(
                                                    "Expansions",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ]
                                              : [
                                                  const Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: Icon(
                                                      Icons.casino_rounded,
                                                      size: 28,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  const Text(
                                                    "Parent Game",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                            // ),
                            const SizedBox(height: 7),
                            Column(
                              children: subtype != 'boardgameexpansion'
                                  ? [
                                      const Text(
                                        "See Expansions list",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amberAccent,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ]
                                  : [
                                      const Text(
                                        "Navigate to Parent Game",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.greenAccent,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                            ),
                          ]),
                        ),
                      ]),
                ],
              ),
            ]),
          ),
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
