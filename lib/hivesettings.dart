import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'hivesettings.g.dart';

@HiveType(typeId: 0)
class HiveSettings extends HiveObject {
  @HiveField(0)
  late String theme;

  @HiveField(1)
  late TimeOfDay workhours;

  HiveSettings({required this.theme, required this.workhours});
}