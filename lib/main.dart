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

  if (boxSettings.length == 0){
    CustomTime ct = CustomTime(hour: 8, minute: 45);
    HiveSettings hs = HiveSettings(darkTheme: true, workhours: ct);
    boxSettings.put(0, hs);
  }

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
                  surface: Color.fromARGB(255, 53, 52, 54),
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
      width: 300.0, // Width of the SnackBar.
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
      color: colorScheme.surface,
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
                SafeArea(
                  child: BottomNavigationBar(
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
                ),
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

class AnnotatePage extends StatelessWidget {
  const AnnotatePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var colorScheme = Theme.of(context).colorScheme;

    final myController = TextEditingController();

    int overtimeHours = 0;
    int overtimeMinutes = 0;
    int currentValueM = 0;
    int currentValueH = 0;

    @override
    void dispose() {
      myController.dispose();
    }

    return Container(
      decoration: BoxDecoration(color: colorScheme.primary),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
                padding: EdgeInsets.only(
                    top: 800 * 0.5 * 0.2, bottom: 14, left: 14, right: 14)),
            SizedBox(
              child: Text(
                "Welcome!",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSecondary,
                    fontSize: 24),
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 480 * 0.5 * 0.4)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 480 * 0.5 * 0.55,
                  height: 800 * 0.5 * 0.25,
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      elevation:
                          MaterialStateProperty.resolveWith((states) => 10),
                      shadowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.white),
                    ),
                    onPressed: () {
                      final dt = appState.getTime();
                      if (!appState.onlyIn &&
                          ((appState.checkIns.isNotEmpty &&
                                  appState.compareToLastCheckIn(dt)) ||
                              (appState.checkIns.isEmpty))) {
                        appState.annotateIn(dt);
                        var snackBar =
                            appState.createSnackBar('You have checked in!');
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        var snackBar = appState.createSnackBar(
                            'You have already checked in today!');
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    icon: Icon(
                      Icons.add_alarm_outlined,
                      color: colorScheme.onSecondary,
                    ),
                    label: Text(
                      'Check in',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(right: 480 * 0.5 * 0.4)),
                SizedBox(
                  width: 480 * 0.5 * 0.55,
                  height: 800 * 0.5 * 0.25,
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      elevation:
                          MaterialStateProperty.resolveWith((states) => 10),
                      shadowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.white),
                    ),
                    onPressed: () {
                      if (appState.onlyIn) {
                        final dt = appState.getTime();
                        appState.annotateOut(dt);
                        var snackBar =
                            appState.createSnackBar('You have checked out!');
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    icon: Icon(Icons.assignment_turned_in_outlined,
                        color: colorScheme.onSecondary),
                    label: Text(
                      'Check out',
                      style: TextStyle(
                          fontSize: 11, color: colorScheme.onSecondary),
                    ),
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(30)),
            ElevatedButton(
                child: Text(
                  'Clear All',
                  style: TextStyle(color: colorScheme.onSecondary),
                ),
                onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                            backgroundColor: colorScheme.tertiary,
                            title: const Text('Warning!'),
                            content: const Text(
                                'Do you really wish to delete all your annotations?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => {
                                  appState.clearAll(),
                                  Navigator.pop(context, 'Yes!')
                                },
                                child: const Text('Yes!'),
                              ),
                            ]))),
            const Expanded(
              child: Text(''),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    //Duration workHours = sharedOvertime;
    Duration workHours = const Duration(hours: 8, minutes: 45);
    var colorScheme = Theme.of(context).colorScheme;

    var dates = <String>[];

    for (int i = 0; i < appState.checkIns.length; i++) {
      // ignore: unnecessary_string_interpolations
      dates.add("${appState.parseUntilDay((appState.checkIns[i]).toString())}");
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.primary,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.only(top: 14)),
              Center(
                child: Text(
                  'Your annotations',
                  style: TextStyle(
                      fontSize: 24.0,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSecondary),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 800 * 0.5 * 0.05)),
              for (var i in appState.list.reversed) ...[
                Card(
                  child: ListTile(
                    title: Text(
                      dates[appState.list.indexOf(i)],
                      style: TextStyle(color: colorScheme.onSecondary),
                    ),
                    subtitle: (!appState.checks[appState.list.indexOf(i)])
                        ? Text(
                            "${appState.parseForHours(appState.formatTime(DateTime.parse(i.$1)))} || ",
                            style: TextStyle(color: colorScheme.onSecondary),
                          )
                        : Text(
                            "${appState.parseForHours(appState.formatTime(DateTime.parse(i.$1)))} || ${appState.parseForHours(appState.formatTime(DateTime.parse(i.$2)))}",
                            style: TextStyle(color: colorScheme.onSecondary),
                          ),
                    trailing: (appState.checkOuts[appState.checkOuts
                                    .indexOf(DateTime.parse(i.$2))]
                                .difference(appState.checkIns[appState.checkIns
                                    .indexOf(DateTime.parse(i.$1))])
                                .compareTo(workHours) >
                            0)
                        ? Text(
                            "Overtime: ${appState.parseUntilSeconds((appState.checkOuts[appState.checkOuts.indexOf(DateTime.parse(i.$2))].difference(appState.checkIns[appState.checkIns.indexOf(DateTime.parse(i.$1))])).toString())}",
                            style: TextStyle(color: colorScheme.onSecondary),
                          )
                        : Text(
                            "Overtime: 00:00:00",
                            style: TextStyle(color: colorScheme.onSecondary),
                          ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
