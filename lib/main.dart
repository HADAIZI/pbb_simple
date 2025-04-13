import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'task.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Task>> _tasksFuture;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tasksFuture = DatabaseHelper.instance.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todos"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blue[800],
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final tasks = snapshot.data ?? [];
          final inProgressTasks = tasks.where((task) => !task.isDone).toList();
          var doneTasks = tasks.where((task) => task.isDone).toList();

          doneTasks.sort((a, b) {
            return (b.lastUpdated ?? DateTime.now()).compareTo(
              a.lastUpdated ?? DateTime.now(),
            );
          });

          if (doneTasks.length > 4) {
            doneTasks = doneTasks.take(4).toList();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Background image restored as before
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.transparent, // Invisible container
                    child: Image.asset(
                      'assets/Checklist.jpg', // Background image path
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader("In Progress"),
                  _buildTaskList(inProgressTasks, false),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Done"),
                  _buildTaskList(doneTasks, true),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[800],
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        onPressed: () => _showTaskDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, bool isDoneSection) {
    return Card(
      child: Column(
        children: tasks.map((task) => _buildTaskItem(task)).toList(),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Dismissible(
      key: ValueKey(task.id),
      background: Container(
        color: Colors.red[100],
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteTask(task.id),
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (value) => _toggleTaskStatus(task, value!),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone ? Colors.grey[600] : Colors.blue[800],
          ),
        ),
        subtitle:
            task.description.isNotEmpty
                ? Text(
                  task.description,
                  style: TextStyle(
                    color: task.isDone ? Colors.grey[500] : Colors.grey[700],
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                  ),
                )
                : null,
        onTap: () => _showTaskDialog(context, task),
      ),
    );
  }

  void _showTaskDialog(BuildContext context, Task? task) {
    if (task != null) {
      _titleController.text = task.title;
      _descController.text = task.description;
    } else {
      _titleController.clear();
      _descController.clear();
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(task == null ? "Add Task" : "Edit Task"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    setState(() {
                      final newTask = Task(
                        id:
                            task?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _titleController.text,
                        description: _descController.text,
                      );
                      if (task == null) {
                        DatabaseHelper.instance.addTask(newTask);
                      } else {
                        DatabaseHelper.instance.updateTask(newTask);
                      }
                      _tasksFuture = DatabaseHelper.instance.getTasks();
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _toggleTaskStatus(Task task, bool newStatus) async {
    task.isDone = newStatus;
    task.lastUpdated = DateTime.now();
    await DatabaseHelper.instance.updateTask(task);
    setState(() {});
  }

  void _deleteTask(String id) async {
    await DatabaseHelper.instance.deleteTask(id);
    setState(() {});
  }
}
