import 'package:hive/hive.dart';
import 'package:getclocked/customtime.dart';

part 'hivesettings.g.dart';

@HiveType(typeId: 1)
class HiveSettings extends HiveObject {
  @HiveField(0)
  late bool darkTheme;

  @HiveField(1)
  late CustomTime workhours;

  HiveSettings({required this.darkTheme, required this.workhours});

  String getThemeAsString(){
    return (darkTheme)? 'DarkTheme' : 'LightTheme';
  }

  bool getThemeAsBool(){
    return darkTheme;
  }

  CustomTime getCustomTime(){
    return workhours;
  }
}