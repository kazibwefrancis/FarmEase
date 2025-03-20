import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart'; // Import the Task model

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late Box<Task> _tasksBox;
  final TextEditingController _taskController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }
    _tasksBox = await Hive.openBox<Task>('tasks');
    setState(() {
      _isLoading = false;
    });
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      final newTask = Task(
        title: _taskController.text,
        isCompleted: false,
      );
      _tasksBox.add(newTask);
      _taskController.clear();
      setState(() {});
    }
  }

  void _toggleTaskCompletion(int index) {
    final task = _tasksBox.getAt(index);
    if (task != null) {
      final updatedTask = Task(
        title: task.title,
        isCompleted: !task.isCompleted,
      );
      _tasksBox.putAt(index, updatedTask);
      setState(() {});
    }
  }

  void _deleteTask(int index) {
    _tasksBox.deleteAt(index);
    setState(() {});
  }

  void _editTask(int index, String currentTitle) {
    TextEditingController editController = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Task"),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: "Update your task"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  final oldTask = _tasksBox.getAt(index);
                  if (oldTask != null) {
                    final updatedTask = Task(
                      title: editController.text,
                      isCompleted: oldTask.isCompleted,
                    );
                    _tasksBox.putAt(index, updatedTask);
                    setState(() {});
                  }
                }
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search here....",
                            isDense: true,
                            contentPadding: EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(99)),
                            ),
                            prefixIcon: Icon(IconlyLight.search),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: IconButton.filled(
                          onPressed: () {},
                          icon: const Icon(IconlyLight.filter),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: Card(
                    color: Colors.green.shade50,
                    elevation: 0.1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Free Expert Consultation",
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                        color: Colors.green.shade700,
                                      ),
                                ),
                                Text("Get free support from our experts around the nation"),
                                FilledButton(
                                  onPressed: () {},
                                  child: Text("Call Now"),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            'assets/contact.png',
                            width: 140,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Add Duties Here",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _tasksBox.listenable(),
                  builder: (context, Box<Task> box, _) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: box.length,
                      itemBuilder: (context, index) {
                        final task = box.getAt(index);
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: task?.isCompleted ?? false,
                              onChanged: (value) {
                                _toggleTaskCompletion(index);
                              },
                              activeColor: Colors.green,
                            ),
                            title: GestureDetector(
                              onTap: () => _editTask(index, task?.title ?? ''),
                              child: Text(
                                task?.title ?? '',
                                style: TextStyle(
                                  decoration: task?.isCompleted ?? false
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: task?.isCompleted ?? false ? Colors.grey.shade600 : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editTask(index, task?.title ?? ''),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red.shade400),
                                  onPressed: () {
                                    _deleteTask(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _taskController,
                              decoration: InputDecoration(
                                hintText: "Add a new task...",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            onPressed: _addTask,
                            icon: Icon(Icons.add_circle_outline, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}