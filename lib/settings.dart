import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:getclocked/workhour.dart';
import 'package:getclocked/boxes.dart';
import 'package:getclocked/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:numberpicker/numberpicker.dart';



class SettingsPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: colorScheme.primaryContainer),
      child: Column(
      ),
    );
  }
}