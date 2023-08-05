import 'package:flutter/material.dart';
import 'package:leso_board_games/components/constants.dart';

class HraExpansionListPage extends StatelessWidget {
  const HraExpansionListPage({required Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGrey, // dark grey background
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              width: 300,
              height: 100,
              decoration: BoxDecoration(
                color: normalGrey, // medium grey background
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Expansion List for game will be here',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
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
