import 'package:flutter/material.dart';
import 'package:getclocked/boxes.dart';
import 'package:getclocked/hivesettings.dart';
import 'package:getclocked/main.dart';
import 'package:provider/provider.dart';

//bool darkTheme = (ThemeMode.system == ThemeMode.light) ? false : true;

bool darkTheme = (boxSettings.length > 0)? (boxSettings.getAt(0) as HiveSettings).getThemeAsBool() : ((ThemeMode.system == ThemeMode.light)? false : true);
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var appState = context.watch<MyAppState>();
    var selectedTime;

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.primary,
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.all(8)),
                Center(
                    child: Text('Settings',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: colorScheme.onSecondary))),
                const Padding(
                    padding: EdgeInsets.only(bottom: 800 * 0.5 * 0.05)),
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Text('Common'),
                ),
                Card(
                  color: colorScheme.surface,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Padding(padding: EdgeInsets.only(left: 4)),
                            Icon((darkTheme)
                                ? Icons.brightness_2
                                : Icons.brightness_4),
                            const Padding(padding: EdgeInsets.only(left: 8)),
                            const Text('Theme'),
                            const Expanded(
                              child: Text(''),
                            ),
                            Switch(
                                value: darkTheme,
                                activeColor: Colors.blue[300],
                                onChanged: (bool value) {
                                  (darkTheme)
                                      ? MyApp.of(context)
                                          .changeTheme(ThemeMode.light)
                                      : MyApp.of(context)
                                          .changeTheme(ThemeMode.dark);
                                  darkTheme = value;
                                }),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 0.2,
                        indent: 12.0,
                        endIndent: 12.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Padding(padding: EdgeInsets.only(left: 4)),
                            const Icon(Icons.access_time_filled),
                            const Padding(padding: EdgeInsets.only(left: 8)),
                            const Text('Change work hours'),
                            const Expanded(
                              child: Text(''),
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                  shadowColor: MaterialStateColor.resolveWith(
                                      (states) => colorScheme.onPrimary),
                                  elevation: MaterialStateProperty.resolveWith(
                                      (states) => 2.0),
                                  backgroundColor:
                                      MaterialStateColor.resolveWith(
                                          (states) => colorScheme.surface),
                                ),
                                onPressed: () {selectedTime = showTimePicker(
                                  context: context, 
                                  initialTime: const TimeOfDay(hour: 8, minute: 45),
                                  );},
                                child: Icon(
                                  Icons.change_circle_outlined,
                                  color: colorScheme.onPrimary,
                                ))
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 0.2,
                        indent: 12.0,
                        endIndent: 12.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Padding(padding: EdgeInsets.only(left: 4)),
                            const Icon(Icons.delete_forever),
                            const Padding(padding: EdgeInsets.only(left: 8)),
                            const Text('Delete all annotations'),
                            const Expanded(
                              child: Text(''),
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                  shadowColor: MaterialStateColor.resolveWith(
                                      (states) => colorScheme.onPrimary),
                                  elevation: MaterialStateProperty.resolveWith(
                                      (states) => 2.0),
                                  backgroundColor:
                                      MaterialStateColor.resolveWith(
                                          (states) => colorScheme.surface),
                                ),
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                            backgroundColor:
                                                colorScheme.secondary,
                                            title: const Text('Warning!'),
                                            content: const Text(
                                                'Do you really wish to delete every annotation?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, 'Cancel'),
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                      color: colorScheme
                                                          .onPrimary),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () => {
                                                  appState.clearAll(),
                                                  Navigator.pop(context, 'Yes!')
                                                },
                                                child: Text('Yes!',
                                                    style: TextStyle(
                                                        color: colorScheme
                                                            .onPrimary)),
                                              ),
                                            ])),
                                child: Icon(
                                  Icons.warning,
                                  color: colorScheme.onPrimary,
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
