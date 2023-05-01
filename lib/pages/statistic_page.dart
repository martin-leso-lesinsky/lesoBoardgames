import 'package:flutter/material.dart';
import 'package:leso_board_games/components/constants.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0), // dark grey background
      body: Center(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: normalGrey, // medium grey background
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    'Game statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 180, 255, 68),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
