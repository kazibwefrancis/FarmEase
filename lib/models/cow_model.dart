import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

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
  final String vaccinationFilePath;

  @HiveField(5)
  final String breedingFilePath;

  @HiveField(6)
  final String healthFilePath;

  @HiveField(7)
  final String milkOutput;

  @HiveField(8)
  final String milkCondition;

  @HiveField(9)
  final String imagePath;

  @HiveField(10)
  final Map<DateTime, String> dailyMilkProduction;

  Cow({
    required this.name,
    required this.age,
    required this.breed,
    required this.weight,
    required this.vaccinationFilePath,
    required this.breedingFilePath,
    required this.healthFilePath,
    required this.milkOutput,
    required this.milkCondition,
    required this.imagePath,
    this.dailyMilkProduction = const {},
  });
}