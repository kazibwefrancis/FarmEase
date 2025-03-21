import 'package:farm_ease/pages/home_page.dart';
// import 'package:farm_ease/pages/splashscreen.dart'; // Import the dedicated splash screen file
import 'package:farm_ease/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cow_model.dart'; // Import the Cow model
import 'models/task.dart'; // Import the Task model
import 'dart:async';

// Define the DateTimeAdapter
class DateTimeAdapter extends TypeAdapter<DateTime> {
  @override
  final int typeId = 2;

  @override
  DateTime read(BinaryReader reader) {
    return DateTime.fromMillisecondsSinceEpoch(reader.readInt());
  }

  @override
  void write(BinaryWriter writer, DateTime obj) {
    writer.writeInt(obj.millisecondsSinceEpoch);
  }
}

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(CowAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(DateTimeAdapter()); // Register DateTimeAdapter

  // Open the Hive boxes for cows and tasks
  await Hive.openBox<Cow>('cows');
  await Hive.openBox<Task>('tasks');

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: const SplashScreen(), // Set SplashScreen from splashscreen.dart as the initial screen
    );
  }
}
