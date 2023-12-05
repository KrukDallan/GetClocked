import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:getclocked/workhour.dart';
import 'package:getclocked/boxes.dart';
import 'package:getclocked/shared.dart';
import 'package:getclocked/settings.dart';
import 'package:getclocked/hivesettings.dart';
import 'package:getclocked/customtime.dart';
import 'package:getclocked/annotate.dart';
import 'package:getclocked/history.dart';

// TODO: LinkedHashMap or Set instead of List

var boxCheckIns = <DateTime>[];
var boxCheckOuts = <DateTime>[];
var boxBools = <bool>[];
var boxList = <(String, String)>[];

bool showAlertDialogOvertime = false;

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();

  await Hive.initFlutter();

  Hive.registerAdapter(WorkHourAdapter());
  Hive.registerAdapter(HiveSettingsAdapter());
  Hive.registerAdapter(CustomTimeAdapter());

  boxWorkHours = await Hive.openBox<WorkHour>('workHour');

  if (boxWorkHours.length > 0) {
    for (int i = 0; i < boxWorkHours.length; i++) {
      WorkHour wh = boxWorkHours.getAt(i);
      boxCheckIns.add(wh.checkIn);
      boxCheckOuts.add(wh.checkOut);
      boxBools.add(wh.check);
      boxList.add((wh.checkIn.toString(), wh.checkOut.toString()));
    }
  }

  boxSettings = await Hive.openBox<HiveSettings>('settings');

/*   if (boxSettings.length == 0){
    CustomTime ct = CustomTime(hour: 8, minute: 45);
    HiveSettings hs = HiveSettings(darkTheme: true, workhours: ct);
    boxSettings.put(0, hs);
  } */
  // temporarily disable the box
  boxSettings.clear();
  

  //(ThemeMode.system == ThemeMode.light) ? darkMode = false : darkMode = true;

  runApp(const MyApp());


}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

// Needed for light/dark theme
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: 'GetClocked',
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: const ColorScheme(
                  brightness: Brightness.light,
                  primary: Color.fromARGB(255, 154, 237, 243),
                  onPrimary: Colors.black,
                  secondary: Colors.white,
                  onSecondary: Colors.black,
                  tertiary: Colors.blue,
                  onTertiary: Colors.white,
                  error: Colors.black,
                  onError: Colors.red,
                  background: Colors.white,
                  onBackground: Colors.black,
                  surface: Colors.white,
                  onSurface: Colors.black)),
          darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: const ColorScheme(
                  brightness: Brightness.dark,
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  secondary: Color.fromARGB(255, 29, 28, 28),
                  onSecondary: Colors.white,
                  tertiary: Color.fromARGB(255, 29, 28, 28),
                  onTertiary: Colors.white,
                  error: Color.fromARGB(255, 29, 28, 28),
                  onError: Colors.red,
                  background: Colors.black,
                  onBackground: Colors.white,
                  surface: Color.fromARGB(255, 53, 51, 55),
                  onSurface: Colors.white)),
          themeMode: _themeMode,
          home: const MyHomePage(title: 'GetClocked'),
        ));
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
      //darkMode = !darkMode;
    });
  }
}

// Useful methods
class MyAppState extends ChangeNotifier {
  var checkIns = boxCheckIns;
  var checkOuts = boxCheckOuts;
  var list = boxList;
  var listIndex = (boxWorkHours.length > 0) ? (boxWorkHours.length) : 0;
  var onlyIn = (boxWorkHours.length > 0)
      ? (boxWorkHours.getAt(boxWorkHours.length - 1).onlyIn)
      : false;
  var checks = boxBools;

  DateTime getTime() {
    final dateTime = DateTime.now();
    return dateTime;
  }

  String formatTime(DateTime dt) {
    String date = dt.year.toString();
    String hour =
        (dt.hour.toInt() >= 10) ? dt.hour.toString() : '0${dt.hour.toString()}';
    String minute = (dt.minute.toInt() >= 10)
        ? dt.minute.toString()
        : '0${dt.minute.toString()}';
    String second = (dt.second.toInt() >= 10)
        ? dt.second.toString()
        : '0${dt.second.toString()}';
    return '$date-${dt.month}-${dt.day} $hour:$minute:$second';
  }

  String parseUntilSeconds(String s) {
    final splitted = s.split('.');
    return splitted[0];
  }

  String parseUntilDay(String s) {
    final splitted = s.split(' ');
    return splitted[0];
  }

  String parseForHours(String s) {
    final splitted = s.split(' ');
    return splitted[1];
  }

  void annotateIn(DateTime dt) {
    checkIns.add(dt);
    checkOuts.add(dt);
    onlyIn = true;
    checks.add(false);
    list.add((dt.toString(), dt.toString()));
    boxWorkHours.add(WorkHour(
        checkIn: dt,
        checkOut: dt,
        listIndex: listIndex,
        check: false,
        onlyIn: onlyIn));
    notifyListeners();
  }

  void removeIn(DateTime dt) {
    checkIns.remove(dt);
    notifyListeners();
  }

  void annotateOut(DateTime dt) {
    checkOuts.add(dt);
    var current = (checkIns[listIndex].toString(), dt.toString());
    list.removeAt(listIndex);
    list.insert(listIndex, current);
    checks[listIndex] = true;
    WorkHour tmpWh = boxWorkHours.getAt(listIndex);
    onlyIn = false;
    boxWorkHours.putAt(
        listIndex,
        WorkHour(
            checkIn: tmpWh.checkIn,
            checkOut: dt,
            listIndex: listIndex,
            check: true,
            onlyIn: onlyIn));
    listIndex += 1;
    notifyListeners();
  }

  void removeOut(DateTime dt) {
    checkOuts.remove(dt);
    notifyListeners();
  }

  void removeListElement((String, String) dtTuple) {
    var index = list.indexOf(dtTuple);
    checks.removeAt(index);
    list.remove(dtTuple);
    removeIn(DateTime.parse(dtTuple.$1));
    if (dtTuple.$2 != '') {
      removeOut(DateTime.parse(dtTuple.$2));
    }
    if (!onlyIn) {
      listIndex = (listIndex > 0) ? listIndex - 1 : 0;
    }
    boxWorkHours.delete(boxWorkHours.keyAt(index));
    onlyIn = false;

    notifyListeners();
  }

  void clearAll() {
    checkIns.clear();
    checkOuts.clear();
    list.clear();
    listIndex = 0;
    boxWorkHours.clear();
    onlyIn = false;
    notifyListeners();
  }

  bool compareToLastCheckIn(DateTime dt) {
    var idx = checkIns.length - 1;
    if (dt.year != checkIns[idx].year) {
      return true;
    } else if (dt.year == checkIns[idx].year &&
        dt.month != checkIns[idx].month) {
      return true;
    } else if (dt.year == checkIns[idx].year &&
        dt.month == checkIns[idx].month &&
        dt.day != checkIns[idx].day) {
      return true;
    } else {
      return false;
    }
  }

  SnackBar createSnackBar(String msg) {
    return SnackBar(
      content: Center(child: Text(msg)),
      duration: const Duration(milliseconds: 1200),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 60),
      //width: 300.0, // Width of the SnackBar.
      padding: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Home page of the application
class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;

    switch (selectedIndex) {
      case 0:
        page = const AnnotatePage();
      case 1:
        page = const HistoryPage();
      case 2:
        page = const SettingsPage();
      default:
        page = Text('UnimplementedError(no widget for $selectedIndex)');
    }

    var mainArea = ColoredBox(
      color: colorScheme.primary,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 700) {
            return Column(
              children: [
                Expanded(child: mainArea),
                 BottomNavigationBar(
                      unselectedItemColor: colorScheme.onPrimary,
                      selectedItemColor: colorScheme.onPrimary,
                      backgroundColor: colorScheme.secondary,
                      items: [
                        BottomNavigationBarItem(
                          backgroundColor: colorScheme.secondary,
                          icon: Icon(
                            Icons.access_time_filled,
                            color: colorScheme.onPrimary,
                          ),
                          label: 'Annotate',
                        ),
                        const BottomNavigationBarItem(
                          icon: Icon(
                            Icons.article,
                          ),
                          label: 'History',
                        ),
                        const BottomNavigationBarItem(
                          icon: Icon(
                            Icons.settings,
                          ),
                          label: 'Settings',
                        ),
                      ],
                      currentIndex: selectedIndex,
                      onTap: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      }),
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    backgroundColor: colorScheme.surface,
                    extended: constraints.maxWidth >= 700,
                    indicatorColor: colorScheme.primary,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.access_time_filled,
                            color: colorScheme.onSecondary),
                        label: Text(
                          'Annotate',
                          style: TextStyle(color: colorScheme.onSecondary),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.article),
                        label: Text('History',
                            style: TextStyle(color: colorScheme.onSecondary)),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.settings),
                        label: Text('Settings',
                            style: TextStyle(color: colorScheme.onSecondary)),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}


