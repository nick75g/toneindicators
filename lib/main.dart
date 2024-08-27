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
}; //TODO: Replace with sqflite stuff

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
  var selectedIndex = 0;
  var currentTag = "";

  void addIndicator(tag, name, desc) {
    indicators[tag] = [name, desc];
    notifyListeners();
  }

  void removeIndicator(tag) {
    indicators.remove(tag);
    notifyListeners();
  }

  void changeIndex(i) {
    selectedIndex = i;
    notifyListeners();
  }

  Widget fullScreen(tag) {
    return FullScreen(tag: tag);
  }

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var tag = appState.currentTag;
    var index = appState.selectedIndex;
    
    Widget page;
    Icon icon;
    switch (index) {
      case 0:
        page = GeneratorPage();
        icon = Icon(Icons.edit);
      case 1:
        page = FullScreen(tag: tag);
        icon = Icon(Icons.arrow_back);
      case 2:
        page = EditScreen(tag: tag);
        icon = Icon(Icons.check);
      default:
        throw UnimplementedError('no widget for $index');
    }
    
    final theme = Theme.of(context);
    final titlestyle = theme.textTheme.headlineMedium!.copyWith(color: theme.colorScheme.primary);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: page,
          appBar: AppBar( //TODO: Conditional AppBar when in FullScreen widget
            leading: IconButton(onPressed: () {

            }, icon: Icon(Icons.arrow_back)),
            title: Text("Tone Indicators", style: titlestyle),
          ),
          floatingActionButton: FloatingActionButton(onPressed: () {
            if (index == 1) {
              appState.changeIndex(0); //TODO: Fully implement Button
            }
          },
          child: icon,
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final ind = appState.indicators;

    return Center(
      child: ListView(
        children: [
          for (var i in ind.entries)
            ToneCard(titleText: i.value[0], subText: i.value[1], toneTag: i.key)
        ],
      )
    );
  }
}

class ToneCard extends StatefulWidget {

  final String titleText;
  final String subText;
  final String toneTag;

  const ToneCard({required this.titleText, required this.subText, required this.toneTag});

  @override
  State<ToneCard> createState() => _ToneCardState();
}

class _ToneCardState extends State<ToneCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leadstyle = theme.textTheme.headlineSmall!.copyWith(color: theme.colorScheme.onPrimary);
    final substyle = theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onPrimary);
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ListTile(
        tileColor: theme.colorScheme.primary,
        title: Text(widget.titleText, style: leadstyle),
        subtitle: Text(widget.subText, style: substyle),
        leading: TextButton(onPressed: () {setState(() {
          appState.currentTag = widget.toneTag; appState.changeIndex(1);
        });}, child: Text(widget.toneTag, style: leadstyle)),
        trailing: IconButton(onPressed: () {appState.removeIndicator(widget.toneTag);}, icon: Icon(Icons.info, color: theme.colorScheme.onPrimary),),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)
        ),
      ),
    );
  }
}

class EditScreen extends StatelessWidget {
  final String tag;

  const EditScreen({required this.tag});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Placeholder(); //TODO: Implement EditScreen and NewTagScreen
  }
}

class FullScreen extends StatelessWidget {
  final String tag;

  const FullScreen({required this.tag});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.primary;
    final style = theme.textTheme.displayLarge!.copyWith(color: theme.colorScheme.onPrimary);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(5.0),
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        child: Card(
          color: cardColor,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(tag,
                  style: style,
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}