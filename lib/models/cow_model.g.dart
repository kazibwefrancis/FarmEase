// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cow_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CowAdapter extends TypeAdapter<Cow> {
  @override
  final int typeId = 0;

  @override
  Cow read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cow(
      name: fields[0] as String,
      age: fields[1] as String,
      breed: fields[2] as String,
      weight: fields[3] as String,
      vaccinationFilePath: fields[4] as String?,
      breedingFilePath: fields[5] as String?,
      healthFilePath: fields[6] as String?,
      milkOutput: fields[7] as String,
      imagePath: fields[8] as String,
      milkCondition: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Cow obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.breed)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.vaccinationFilePath)
      ..writeByte(5)
      ..write(obj.breedingFilePath)
      ..writeByte(6)
      ..write(obj.healthFilePath)
      ..writeByte(7)
      ..write(obj.milkOutput)
      ..writeByte(8)
      ..write(obj.imagePath)
      ..writeByte(9)
      ..write(obj.milkCondition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CowAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
