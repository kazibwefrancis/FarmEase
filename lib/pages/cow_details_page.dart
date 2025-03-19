import 'package:flutter/material.dart';
import '../models/cow_model.dart';
import 'dart:io';

class CowDetailsPage extends StatelessWidget {
  final Cow cow;

  const CowDetailsPage({super.key, required this.cow});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cow.name),
        backgroundColor: Colors.green[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: FileImage(File(cow.imagePath)),
                child: cow.imagePath.isEmpty ? Icon(Icons.pets, size: 50) : null,
              ),
            ),
            SizedBox(height: 20),
            Text('Age: ${cow.age}'),
            Text('Breed: ${cow.breed}'),
            Text('Estimated Weight: ${cow.weight}'),
            Text('Vaccination Records: ${cow.vaccinationFilePath}'),
            Text('Breeding Records: ${cow.breedingFilePath}'),
            Text('Health Records: ${cow.healthFilePath}'),
            Text('Average Milk Output: ${cow.milkOutput}'),
          ],
        ),
      ),
    );
  }
}