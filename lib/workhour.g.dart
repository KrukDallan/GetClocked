// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workhour.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkHourAdapter extends TypeAdapter<WorkHour> {
  @override
  final int typeId = 0;

  @override
  WorkHour read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkHour(
      checkIn: fields[0] as TimeOfDay?,
      checkOut: fields[1] as TimeOfDay?,
      listIndex: fields[2] as int,
      check: fields[4] as bool,
      onlyIn: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorkHour obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.checkIn)
      ..writeByte(1)
      ..write(obj.checkOut)
      ..writeByte(2)
      ..write(obj.listIndex)
      ..writeByte(3)
      ..write(obj.onlyIn)
      ..writeByte(4)
      ..write(obj.check);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkHourAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
