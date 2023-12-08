import 'package:flutter/material.dart';
import 'package:getclocked/main.dart';
import 'package:provider/provider.dart';
import 'package:getclocked/settings.dart';

var timeIn;

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
                      var dt = showTimePicker(
                        context: context,
                        builder: (context, child) {
                          return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: (darkTheme)
                                    ? const ColorScheme(
                                        brightness: Brightness.dark,
                                        primary: Colors.white,
                                        onPrimary:
                                            Color.fromARGB(255, 95, 91, 91),
                                        secondary: Colors.black,
                                        onSecondary: Colors.white,
                                        background: Colors.black,
                                        onBackground: Colors.white,
                                        error: Colors.red,
                                        onError: Colors.black,
                                        surface: Colors.black,
                                        onSurface: Colors.white,
                                      )
                                    : const ColorScheme(
                                        brightness: Brightness.light,
                                        primary: Colors.black,
                                        onPrimary:
                                            Color.fromARGB(255, 193, 187, 187),
                                        secondary: Colors.white,
                                        onSecondary: Colors.black,
                                        error: Colors.red,
                                        onError: Colors.black,
                                        background: Colors.white,
                                        onBackground: Colors.black,
                                        surface: Colors.white,
                                        onSurface: Colors.black),
                              ),
                              // remove the "AM/PM" widget
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  alwaysUse24HourFormat: true,
                                ),
                                child: child!,
                              ));
                        },
                        initialTime: TimeOfDay.now(),
                      ).then((value) => timeIn = value) ;
                      if (!appState.onlyIn || (appState.checkIns.isEmpty)) {
                        appState.annotateIn(timeIn);
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
                const Padding(padding: EdgeInsets.only(right: 480 * 0.5 * 0.2)),
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
                        final TimeOfDay? dt = showTimePicker(
                        context: context,
                        builder: (context, child) {
                          return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: (darkTheme)
                                    ? const ColorScheme(
                                        brightness: Brightness.dark,
                                        primary: Colors.white,
                                        onPrimary:
                                            Color.fromARGB(255, 95, 91, 91),
                                        secondary: Colors.black,
                                        onSecondary: Colors.white,
                                        background: Colors.black,
                                        onBackground: Colors.white,
                                        error: Colors.red,
                                        onError: Colors.black,
                                        surface: Colors.black,
                                        onSurface: Colors.white,
                                      )
                                    : const ColorScheme(
                                        brightness: Brightness.light,
                                        primary: Colors.black,
                                        onPrimary:
                                            Color.fromARGB(255, 193, 187, 187),
                                        secondary: Colors.white,
                                        onSecondary: Colors.black,
                                        error: Colors.red,
                                        onError: Colors.black,
                                        background: Colors.white,
                                        onBackground: Colors.black,
                                        surface: Colors.white,
                                        onSurface: Colors.black),
                              ),
                              // remove the "AM/PM" widget
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  alwaysUse24HourFormat: true,
                                ),
                                child: child!,
                              ));
                        },
                        initialTime: TimeOfDay.now(),
                      ) as TimeOfDay?;
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
            const Expanded(
              child: Text(''),
            ),
          ],
        ),
      ),
    );
  }
}
