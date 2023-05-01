import 'package:flutter/material.dart';
import 'package:leso_board_games/pages/collection_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 0, 0, 0), // Set your desired color here
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: const Center(
                child: MyCollectionPage(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
