import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TextData>(
      create: (context) => TextData(),
      child: const MaterialApp(
        title: 'Retornar Texto',
        home: MyCustomForm(),
      ),
    );
  }
}

class TextData extends ChangeNotifier {
  String displayedText = '';

  void updateText(String newText) {
    displayedText = newText;
    notifyListeners();
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retornar Texto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(controller: myController),
            const SizedBox(height: 20),
            Consumer<TextData>(
              builder: (context, textData, child) {
                return Text('Retornar Texto: ${textData.displayedText}');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<TextData>(context, listen: false)
                    .updateText(myController.text);
              },
              child: const Text('Enviar Texto'),
            ),
          ],
        ),
      ),
    );
  }
}