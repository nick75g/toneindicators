import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

var testData = {
  "/s": ["sarcasm", "The previous statement was meant to be sarcastic."],
  "/j": ["joke", "The previous statement was meant as a joke."],
  "/lh": ["lighthearted", "The previous statement was meant to be lighthearted."],
  "/gen": ["genuine", "The previous statement was genuine."],
  "/srs": ["serious", "The previous statement was to be taken seriously."]
}; //TODO: Forget sqflite, replace with path_provider

var finalData = {};
File saveFile = File('');


Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;

  return File('$path/tags.json');
}

Future<File> saveChanges(Map map) async {
  final file = await _localFile;

  return file.writeAsString(jsonEncode(map));
}

Future<Map> readFile() async {
  try {
    final file = await _localFile;
    final contents = await file.readAsString();
    return jsonDecode(contents);
  } catch (e) {
    return testData;
  }
}

void main() async {
  runApp(MyApp());
  finalData = await readFile();
  saveFile = await _localFile;
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
  Map indicators = finalData; //TODO: replace testData with {} for test
  var selectedIndex = 0;
  String currentTag = "";
  String temptag = "";
  String temptitle = "";
  String tempsubtitle = "";
  File localFile = saveFile;

  void addIndicator(String tag, String name, String desc) async {
    indicators[tag] = <String>[name, desc];
    await saveChanges(indicators);
    notifyListeners();
  }

  void changeIndicator() async {
    indicators.remove(currentTag);
    indicators[temptag] = [temptitle, tempsubtitle];
    await saveChanges(indicators);
    notifyListeners();
  }

  void removeIndicator(tag) async {
    indicators.remove(tag);
    await saveChanges(indicators);
    notifyListeners();
  }

  void changeIndex(i) {
    selectedIndex = i;
    notifyListeners();
  }

  bool checkExist (tag) {
    return indicators.containsKey(tag);
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
  void initState() {
    super.initState();
    readFile().then((value) {
      setState(() {
        finalData = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var tag = appState.currentTag;
    var index = appState.selectedIndex;
    final theme = Theme.of(context);
    final titlestyle = theme.textTheme.headlineMedium!.copyWith(color: theme.colorScheme.primary);

    if (finalData != {}) {
      appState.indicators = finalData;
    }
    else {
      appState.indicators = testData;
    }

    Widget cancel = TextButton(onPressed: (){
      Navigator.of(context).pop();
    }, child: Text("Cancel"));

    Widget exitScreen = TextButton(onPressed: (){
      appState.changeIndex(0);
      Navigator.of(context).pop();
    }, child: Text("Exit"));

    Widget deleteEdit = TextButton(onPressed: (){
      appState.removeIndicator(tag);
      appState.changeIndex(0);
      Navigator.of(context).pop();
    }, child: Text("Delete"));

    Widget ack = TextButton(onPressed: () {
      Navigator.of(context).pop();
    }, child: Text("Okay"));

    SnackBar snackBarDeleted = SnackBar(content: Text("Indicator deleted."));

    Widget yesDelete = TextButton(onPressed: () {
      appState.removeIndicator(tag);
      appState.changeIndex(0);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(snackBarDeleted);
    }, child: Text("Yes, Delete"));

    AlertDialog alertDeleteTag = AlertDialog(
      title: Text("Delete Indicator"),
      content: Text("Are you sure you want to delete this indicator?"),
      actions: [
        cancel,
        yesDelete
      ],
    );

    Widget delete = IconButton(onPressed: () {
      showDialog(context: context, builder: (BuildContext context) {return alertDeleteTag;});
    }, icon: Icon(Icons.delete, color: theme.colorScheme.primary));
    

    AlertDialog alertEditExit = AlertDialog(
      title: Text("Exit Editing"),
      content: Text("Are you sure you want to exit the 'Edit Indicator' screen? Unsaved data will be lost."),
      actions: [
        cancel,
        exitScreen
      ]
    );

    AlertDialog alertNewExit = AlertDialog(
      title: Text("Exit Creation"),
      content: Text("Are you sure you want to exit the 'New Indicator' screen? Unsaved Data will be lost."),
      actions: [
        cancel,
        exitScreen
      ]
    );

    AlertDialog alertEmptyTagDelete = AlertDialog(
      title: Text("Delete Tag"),
      content: Text("You've left the 'Tone Indicator' box empty. If you continue, the tone indicator will be deleted. Are you sure?"),
      actions: [
        cancel,
        deleteEdit
      ]
    );

    AlertDialog alertNewNonZeroTag = AlertDialog(
      title: Text("Invalid Input"),
      content: Text("You haven't specified an indicator. The 'Tone Indicator' field is mandatory."),
      actions: [
        ack
      ]
    );

    AlertDialog alertNewExistingTag = AlertDialog(
      title: Text("Indicator already exists"),
      content: Text("You're trying to create an indicator which already exists. Please rewrite your indicator."),
      actions: [
        ack
      ],
    );

    SnackBar snackBarSaved = SnackBar(content: Text("Changes saved."));
    SnackBar snackBarCreated = SnackBar(content: Text("Indicator created."));
    
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
        actionButton = FloatingActionButton(onPressed: () {
          appState.changeIndex(3);
        }, child: icon);
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
            if (appState.temptag != tag || appState.temptitle != appState.indicators[tag][0] || appState.tempsubtitle != appState.indicators[tag][1]) {
              showDialog(context: context, builder: (BuildContext context) {return alertEditExit;});
            }
            else {
              appState.changeIndex(0);
            }
          }, icon: Icon(Icons.arrow_back)),
          title: Text("Edit Indicator", style: titlestyle),
          actions: [
            delete
          ],
        );
        actionButton = FloatingActionButton(onPressed: () {
          if (appState.temptag == "") {
            showDialog(context: context, builder: (BuildContext context){return alertEmptyTagDelete;});
          }
          else {
            appState.changeIndicator();
            appState.changeIndex(0);
            ScaffoldMessenger.of(context).showSnackBar(snackBarSaved);
          }
        },
        child: icon);
      case 3:
        page = NewTag();
        icon = Icon(Icons.check);
        appbar = AppBar(leading: IconButton(onPressed: () {
          if (appState.temptag != "" || appState.temptitle != "" || appState.tempsubtitle != "") {
            showDialog(context: context, builder: (BuildContext context) {return alertNewExit;});
          }
          else {
            appState.changeIndex(0);
          }
        }, icon: Icon(Icons.arrow_back)),
        title: Text("New Indicator", style: titlestyle)
        );
        actionButton = FloatingActionButton(onPressed: () {
          if (appState.temptag == "") {
            showDialog(context: context, builder: (BuildContext context) {return alertNewNonZeroTag;});
          }
          else if (appState.checkExist(appState.temptag)) {
            showDialog(context: context, builder: (BuildContext context) {return alertNewExistingTag;});
          }
          else {
            appState.addIndicator(appState.temptag, appState.temptitle, appState.tempsubtitle);
            appState.changeIndex(0);
            ScaffoldMessenger.of(context).showSnackBar(snackBarCreated);
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
        });}, icon: Icon(Icons.edit, color: theme.colorScheme.onPrimary),),
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
    appState.temptag = tonaltag;
    appState.temptitle = title;
    appState.tempsubtitle = subtitle;



    Widget cancel = TextButton(onPressed: (){
      Navigator.of(context).pop();
    }, child: Text("Cancel"));

    Widget exitScreen = TextButton(onPressed: (){
      appState.changeIndex(0);
      Navigator.of(context).pop();
    }, child: Text("Exit"));



    AlertDialog alertEditExit = AlertDialog(
      title: Text("Exit Editing"),
      content: Text("Are you sure you want to exit the 'Edit Indicator' screen? Unsaved data will be lost."),
      actions: [
        cancel,
        exitScreen
      ]
    );



    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (appState.temptag != tag || appState.temptitle != appState.indicators[tag][0] || appState.tempsubtitle != appState.indicators[tag][1]) {
          showDialog(context: context, builder: (BuildContext context) {return alertEditExit;});
        }
        else {
          appState.changeIndex(0);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 15.0),
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
      ),
    ); 
  }
}

class FullScreen extends StatelessWidget {
  final String tag;

  const FullScreen({required this.tag});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.primary;
    final style = theme.textTheme.displayLarge!.copyWith(color: theme.colorScheme.onPrimary);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        appState.changeIndex(0);
      },
      child: Center(
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
      ),
    );
  }
}

class NewTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    appState.temptag = "";
    appState.temptitle = "";
    appState.tempsubtitle = "";
    
    
    
    Widget cancel = TextButton(onPressed: (){
      Navigator.of(context).pop();
    }, child: Text("Cancel"));

    Widget exitScreen = TextButton(onPressed: (){
      appState.changeIndex(0);
      Navigator.of(context).pop();
    }, child: Text("Exit"));

    

    AlertDialog alertNewExit = AlertDialog(
      title: Text("Exit Creation"),
      content: Text("Are you sure you want to exit the 'New Indicator' screen? Unsaved Data will be lost."),
      actions: [
        cancel,
        exitScreen
      ]
    );



    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (appState.temptag != "" || appState.temptitle != "" || appState.tempsubtitle != "") {
          showDialog(context: context, builder: (BuildContext context) {return alertNewExit;});
        }
        else {
          appState.changeIndex(0);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 15.0),
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Tone Indicator *",
              hintText: "e.g. /s"
            ),
            onChanged: (value) {
              appState.temptag = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "This field is mandatory.";
              }
              return null;
            },
          ),
          SizedBox(
            height: 15.0,
          ),
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Title",
              hintText: "e.g. Sarcasm"
            ),
            onChanged: (value) {
              appState.temptitle = value;
            },
          ),
          SizedBox(
            height: 15.0,
          ),
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Description",
              hintText: "When is your tag to be used?"
            ),
            onChanged: (value) {
              appState.tempsubtitle = value;
            },
          )
        ],
      ),
    );
  }
}