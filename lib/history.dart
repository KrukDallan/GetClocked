import 'package:flutter/material.dart';
import 'package:getclocked/main.dart';
import 'package:provider/provider.dart';

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
                    // Start and end time
                    subtitle: (!appState.checks[appState.list.indexOf(i)])
                        ? Text(
                            "Start: ${appState.parseForHours(appState.formatTime(DateTime.parse(i.$1)))} | End: ",
                            style: TextStyle(color: colorScheme.onSecondary,
                            fontSize: 11.0),
                          )
                        : Text(
                            "Start: ${appState.parseForHours(appState.formatTime(DateTime.parse(i.$1)))} | End: ${appState.parseForHours(appState.formatTime(DateTime.parse(i.$2)))}",
                            style: TextStyle(color: colorScheme.onSecondary,
                            fontSize: 11.0),
                          ),
                          // Overtime
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