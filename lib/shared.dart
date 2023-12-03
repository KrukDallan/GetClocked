import 'package:shared_preferences/shared_preferences.dart';

var prefs;

void initialize() async {
  prefs = await SharedPreferences.getInstance();
}