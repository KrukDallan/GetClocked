import 'package:flutter/material.dart';
import 'package:getclocked/boxes.dart';
import 'package:getclocked/hivesettings.dart';
import 'package:getclocked/main.dart';

//bool darkTheme = (ThemeMode.system == ThemeMode.light)? false : true;
bool darkTheme = (boxSettings.length > 0)? (boxSettings.getAt(0) as HiveSettings).getThemeAsBool() : ((ThemeMode.system == ThemeMode.light)? false : true);
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.primary,
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.all(8)),
                Center(
                    child: Text('Settings',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 24,
                            color: colorScheme.onSecondary))),
                const Padding(padding: EdgeInsets.only(bottom: 800 * 0.5 * 0.05)),
                const Text('Common'),
                Card(
                  color: colorScheme.secondary,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(padding: EdgeInsets.only(left: 4)),
                        Icon((darkTheme)? Icons.brightness_2 : Icons.brightness_4),
                        const Padding(padding: EdgeInsets.only(left: 8)),
                        const Text('Theme'),
                        const Expanded(child: Text(''),),
                        Switch(
                          value: darkTheme, 
                          activeColor: Colors.blue[300],
                          onChanged: (bool value) {(darkTheme)? MyApp.of(context).changeTheme(ThemeMode.light) : MyApp.of(context).changeTheme(ThemeMode.dark);
                          darkTheme = value;    
                          }),
                      ],
                    ),
                  ),
                )
              ]),
        ),
      ),
    );
  }
}



