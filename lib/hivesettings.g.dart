// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hivesettings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveSettingsAdapter extends TypeAdapter<HiveSettings> {
  @override
  final int typeId = 0;

  @override
  HiveSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSettings(
      theme: fields[0] as String,
      workhours: fields[1] as TimeOfDay,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSettings obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.theme)
      ..writeByte(1)
      ..write(obj.workhours);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
