import 'package:hive/hive.dart';

part 'workhour.g.dart';

@HiveType(typeId: 0)
class WorkHour extends HiveObject {
  @HiveField(0)
  late DateTime checkIn;

  @HiveField(1)
  late DateTime checkOut;

  @HiveField(2)
  late int listIndex;

  @HiveField(3)
  late bool onlyIn;

  @HiveField(4)
  late bool check;

  WorkHour({required this.checkIn, required this.checkOut, required this.listIndex, required this.check, required this.onlyIn});
}