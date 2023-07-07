import 'package:flutter/material.dart';
import 'package:leso_board_games/components/constants.dart';
import 'package:leso_board_games/models/game_model.dart';

class EditGamePage extends StatelessWidget {
  late Game game;

  EditGamePage({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 0, 0, 0), // dark grey background
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          width: 350,
          height: 475,
          decoration: BoxDecoration(
            color: normalGrey, // medium grey background
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: const Color.fromARGB(75, 75, 75, 75),
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info, color: Colors.lightBlueAccent),
                      SizedBox(width: 10),
                      Text(
                        "Select type: ",
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Radio(
                                value: 1,
                                groupValue: 'null',
                                onChanged: (index) {}),
                            const Expanded(
                              child: Text(
                                'Game',
                                style: TextStyle(
                                  color: basicLightGrey,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Radio(
                                value: 1,
                                groupValue: 'null',
                                onChanged: (index) {}),
                            const Expanded(
                                child: Text(
                              'Expansion',
                              style: TextStyle(
                                color: basicLightGrey,
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.today, color: Colors.lightBlueAccent),
                      SizedBox(width: 10),
                      Text(
                        "Select Obtained date: ",
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Select date"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(
                        width: 250,
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Obtained date',
                          ),
                          style: TextStyle(
                            color: basicLightGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.monetization_on_rounded,
                          color: Colors.lightBlueAccent),
                      SizedBox(
                        height: 10,
                        width: 10,
                      ),
                      Text(
                        "Game value: ",
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                    width: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(
                        width: 250,
                        child: TextField(
                          // "Obtained Date: ",
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Game price',
                          ),
                          style: TextStyle(
                            color: basicLightGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            child: const Text('CANCEL'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            child: const Text('SUBMIT'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
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
