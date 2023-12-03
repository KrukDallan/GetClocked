import 'package:flutter/material.dart';




class SettingsPage extends StatelessWidget{
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: colorScheme.primary),
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children:  [
          const Padding(padding: EdgeInsets.all(16)),
          SizedBox(
            child: Text('Settings',textScaler: const TextScaler.linear(1.5),
                style: TextStyle(
                    fontWeight: FontWeight.w500, 
                    color: colorScheme.onSecondary))
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Sample text'),
            ],
          )
        ]
      ),
    );
  }
}