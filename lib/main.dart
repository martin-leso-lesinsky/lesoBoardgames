import 'package:flutter/material.dart';
import 'package:leso_board_games/db/hras_database.dart';
import 'package:leso_board_games/pages/hra_start_page.dart';
import 'package:leso_board_games/pages/hras_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

var _lastUsedUser = '';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  _lastUsedUser = prefs.getString('lastUsedUser') ?? '';

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
                      final hrasCount = snapshot.data;
                      if (_lastUsedUser.isEmpty && hrasCount == 0) {
                        return const StartPage(
                          bgUserName: '',
                        );
                      } else {
                        return HrasPage(
                          bgUserName: _lastUsedUser,
                        );
                      }
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
