import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: StackLayout(),
        ),
      ),
    );
  }
}

class StackLayout extends StatelessWidget {
  const StackLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Icon(
          Icons.star,
          color: Colors.yellow,
          size: 100,
        ),
      ],
    );
  }
}