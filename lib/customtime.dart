import 'package:hive/hive.dart';

part 'customtime.g.dart';

@HiveType(typeId: 2)
class CustomTime extends HiveObject{
  @HiveField(0)
  int hour = 8;

  @HiveField(1)
  int minute = 0;

  CustomTime({
    this.hour = 8, this.minute = 0
  });

  void setTime(int customHour, int customMinute){
    hour = customHour;
    minute = customMinute;
  }

  (int,int) getTime(){
    return (hour,minute);
  }
}