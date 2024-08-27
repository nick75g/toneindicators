import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

var testData = {
  "/s": ["sarcasm", "The previous statement was meant to be sarcastic."],
  "/j": ["joke", "The previous statement was meant as a joke."],
  "/lh": ["lighthearted", "The previous statement was meant to be lighthearted."],
  "/gen": ["genuine", "The previous statement was genuine."],
  "/srs": ["serious", "The previous statement was to be taken seriously."]
};

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'ToneIndicator',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 100, 100, 255)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  Map indicators = testData; //replace testData with {} for test

  void addIndicator(tag, name, desc) {
    indicators[tag] = [name, desc];
    notifyListeners();
  }

  void removeIndicator(tag) {
    indicators.remove(tag);
    notifyListeners();
  }

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = Placeholder();
      default:
        throw UnimplementedError('no widget for $selectedIndex');

    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: GeneratorPage(),
        );
      }
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leadstyle = theme.textTheme.headlineSmall!.copyWith(color: theme.colorScheme.onPrimary);
    final substyle = theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onPrimary);
    final titlestyle = theme.textTheme.headlineMedium!.copyWith(color: theme.colorScheme.primary);
    var appState = context.watch<MyAppState>();
    var ind = appState.indicators;

    return Center(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text("Indicators", style: titlestyle),
          ),
          for (var i in ind.entries)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListTile(
                tileColor: theme.colorScheme.primary,
                title: Text(i.value[0], style: leadstyle),
                subtitle: Text(i.value[1], style: substyle),
                leading: Text(i.key, style: leadstyle),
                trailing: IconButton(onPressed: () {appState.removeIndicator(i.key);}, icon: Icon(Icons.delete, color: theme.colorScheme.onPrimary),),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)
                ),
              ),
            )
        ],
      )
    );
  }
}
