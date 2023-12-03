import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(padding: EdgeInsets.all(14)),
              SizedBox(
                  child: Center(
                      child: Text('Settings',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: colorScheme.onSecondary)))),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Sample text'),
                ],
              )
            ]),
      ),
    );
  }
}
