import 'package:flutter/material.dart';

class HraStatisticPage extends StatelessWidget {
  final int gamesInDatabase;
  final int expansionsInDatabase;
  final int totalPlays;
  final int valueForGames;
  final int valueForExpansions;

  const HraStatisticPage({
    required this.gamesInDatabase,
    required this.expansionsInDatabase,
    required this.totalPlays,
    required this.valueForGames,
    required this.valueForExpansions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistic Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Games in Database: $gamesInDatabase',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Expansions in Database: $expansionsInDatabase',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Plays: $totalPlays',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Value for Games: $valueForGames',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Value for Expansions: $valueForExpansions',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // Navigate back when button is pressed
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
