import 'package:farm_ease/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cow_model.dart'; // Import the Cow model
import 'models/task.dart'; // Import the Task model

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register the Cow adapter
  Hive.registerAdapter(CowAdapter());

  // Register the Task adapter
  Hive.registerAdapter(TaskAdapter());

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
      home: const HomePage(), // Set ExplorePage as the initial screen
    );
  }
}