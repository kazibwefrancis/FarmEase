import 'package:hive/hive.dart';

part 'cow_model.g.dart';

@HiveType(typeId: 0)
class Cow {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String age;

  @HiveField(2)
  final String breed;

  @HiveField(3)
  final String weight;

  @HiveField(4)
  final String vaccinationFilePath; // File path for vaccination record

  @HiveField(5)
  final String breedingFilePath; // File path for breeding record

  @HiveField(6)
  final String healthFilePath; // File path for health record

  @HiveField(7)
  final String milkOutput;

  @HiveField(8)
  final String imagePath;

  Cow({
    required this.name,
    required this.age,
    required this.breed,
    required this.weight,
    required this.vaccinationFilePath,
    required this.breedingFilePath,
    required this.healthFilePath,
    required this.milkOutput,
    required this.imagePath,
  });
}