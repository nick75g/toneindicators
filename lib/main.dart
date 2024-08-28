import 'dart:io';
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
  var temptag = "";
  var temptitle = "";
  var tempsubtitle = "";

  void addIndicator(tag, name, desc) {
    indicators[tag] = [name, desc];
    notifyListeners();
  }

  void changeIndicator() {
    indicators.remove(currentTag);
    indicators[temptag] = [temptitle, tempsubtitle];
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
    final theme = Theme.of(context);
    final titlestyle = theme.textTheme.headlineMedium!.copyWith(color: theme.colorScheme.primary);

    Widget cancel = TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Cancel"));
    Widget closeEdit = TextButton(onPressed: (){
      appState.changeIndex(0);
      Navigator.of(context).pop();
    }, child: Text("Close"));


    AlertDialog alertEditExit = AlertDialog(
      title: Text("Exit Editing"),
      content: Text("Are you sure you want to exit the edit screen? Unsaved data will be lost."),
      actions: [
        cancel,
        closeEdit
      ],
    );

    Widget deleteEdit = TextButton(onPressed: (){
      appState.removeIndicator(tag);
      appState.changeIndex(0);
      Navigator.of(context).pop();
    }, child: Text("Delete"));


    AlertDialog alertDeleteTag = AlertDialog(
      title: Text("Delete Tag"),
      content: Text("You've left the 'Tone Indicator' box empty. If you continue, the tone indicator will be deleted. Are you sure?"),
      actions: [
        cancel,
        deleteEdit
      ],
    );

    SnackBar snackBar = SnackBar(content: Text("Changes saved."));
    
    Widget page;
    PreferredSizeWidget appbar;
    Icon icon;
    FloatingActionButton actionButton;
    switch (index) {
      case 0:
        page = GeneratorPage();
        icon = Icon(Icons.add);
        appbar = AppBar(leading: IconButton(onPressed: () {
            exit(0);
          }, icon: Icon(Icons.close)),
          title: Text("Tone Indicators", style: titlestyle),
        );
        actionButton = FloatingActionButton(onPressed: () {}, child: icon);
      case 1:
        page = FullScreen(tag: tag);
        icon = Icon(Icons.arrow_back);
        appbar = PreferredSize(preferredSize: Size(0.0, 0.0), child: Container());
        actionButton = FloatingActionButton(onPressed: () {
          appState.changeIndex(0);
        },
        child: icon);
      case 2:
        page = EditScreen(tag: tag);
        icon = Icon(Icons.check);
        appbar = AppBar(leading: IconButton(onPressed: () {
            showDialog(context: context, builder: (BuildContext context) {return alertEditExit;});
          }, icon: Icon(Icons.arrow_back)),
          title: Text("Edit Indicator", style: titlestyle)
        );
        actionButton = FloatingActionButton(onPressed: () {
          if (appState.temptag == "") {
            showDialog(context: context, builder: (BuildContext context){return alertDeleteTag;});
          }
          else {
            appState.changeIndicator();
            appState.changeIndex(0);
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: icon);
      default:
        throw UnimplementedError('no widget for $index');
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: page,
          appBar: appbar,
          floatingActionButton: actionButton
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
        trailing: IconButton(onPressed: () {setState(() {
          appState.currentTag = widget.toneTag; appState.changeIndex(2);
        });}, icon: Icon(Icons.info, color: theme.colorScheme.onPrimary),),
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
    var tonaltag = tag;
    var title = appState.indicators[tag][0];
    var subtitle = appState.indicators[tag][1];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: tonaltag,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Tone Indicator"
          ),
          onChanged: (value) {
            appState.temptag = value;
          },
        ),
        SizedBox(
          height: 15.0,
        ),
        TextFormField(
          initialValue: title,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Title"
          ),
          onChanged: (value) {
            appState.temptitle = value;
          },
        ),
        SizedBox(
          height: 15.0,
        ),
        TextFormField(
          initialValue: subtitle,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Description"
          ),
          onChanged: (value) {
            appState.tempsubtitle = value;
          },
        )
      ],
    ); //TODO: Implement EditScreen and NewTagScreen
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