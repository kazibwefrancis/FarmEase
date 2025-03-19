import 'package:flutter/material.dart';
import 'dart:io';

class CowTile extends StatelessWidget {
  final String name;
  final String imagePath;
  final VoidCallback onTap;

  const CowTile({
    required this.name,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: FileImage(File(imagePath)),
          child: imagePath.isEmpty ? Icon(Icons.pets) : null,
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: onTap,
      ),
    );
  }
}