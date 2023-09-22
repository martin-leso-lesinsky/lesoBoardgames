import 'package:flutter/material.dart';
import 'package:leso_board_games/db/hras_database.dart';
import 'package:leso_board_games/pages/hra_start_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the HrasDatabase instance
  await HrasDatabase.instance.database;

  /// Call the function to calculate and store total values
  await HrasDatabase.instance.calculateAndStoreTotalValues();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Center(
                child: FutureBuilder<int?>(
                  future: _checkDatabaseNotEmpty(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Error checking database');
                    } else {
                      return const StartPage(
                        bgUserName: '',
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<int?> _checkDatabaseNotEmpty() async {
    final database = HrasDatabase.instance;
    return await database.getHrasCount();
  }
}
