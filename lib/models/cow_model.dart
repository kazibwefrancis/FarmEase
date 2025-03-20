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
  final String? vaccinationFilePath; // Made nullable

  @HiveField(5)
  final String? breedingFilePath; // Made nullable

  @HiveField(6)
  final String? healthFilePath; // Made nullable

  @HiveField(7)
  final String milkOutput;

  @HiveField(8)
  final String imagePath;

  @HiveField(9)
  final String milkCondition;

  Cow({
    required this.name,
    required this.age,
    required this.breed,
    required this.weight,
    this.vaccinationFilePath = '', // Provide default empty string
    this.breedingFilePath = '',
    this.healthFilePath = '',
    required this.milkOutput,
    required this.imagePath,
    required this.milkCondition,
  });
}