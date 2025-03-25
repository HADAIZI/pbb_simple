import 'package:flutter/material.dart';

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

class Task {
  final String id;
  final String title;
  final String description;
  bool isDone;
  DateTime? lastUpdated;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isDone = false,
    this.lastUpdated,
  }) {
    lastUpdated ??= DateTime.now(); // Initialize it in the body instead
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Initialize the task list as empty (no tasks on reload)
  final List<Task> _tasks = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final inProgressTasks = _tasks.where((task) => !task.isDone).toList();
    var doneTasks = _tasks.where((task) => task.isDone).toList();

    // Sort done tasks based on the last updated date
    doneTasks.sort((a, b) {
      // Safely compare, using null-aware operator or fallback to DateTime.now() if null
      return (b.lastUpdated ?? DateTime.now()).compareTo(
        a.lastUpdated ?? DateTime.now(),
      );
    });

    // Remove the oldest task if there are more than 4 completed tasks
    if (doneTasks.length > 4) {
      setState(() {
        _tasks.removeWhere(
          (task) =>
              task.isDone && !doneTasks.take(4).any((t) => t.id == task.id),
        );
        doneTasks = doneTasks.take(4).toList();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Todos",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Invisible container for checklist.jpg image on top of "In Progress"
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.transparent, // Invisible container
                child: Image.asset('assets/Checklist.jpg', fit: BoxFit.cover),
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
    if (tasks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              "No ${isDoneSection ? 'completed' : 'in-progress'} tasks",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

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
        child: Icon(Icons.delete, color: Colors.red[800]),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteTask(task.id),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Transform.scale(
            scale: 1.3,
            child: Checkbox(
              value: task.isDone,
              onChanged: (value) => _toggleTaskStatus(task, value!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: BorderSide(color: Colors.blue[800]!, width: 1.5),
              activeColor: Colors.blue[800],
            ),
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
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  )
                  : null,
          onTap: () => _showTaskDialog(context, task),
        ),
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
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                ),
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    setState(() {
                      if (task == null) {
                        _tasks.add(
                          Task(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            title: _titleController.text,
                            description: _descController.text,
                          ),
                        );
                      } else {
                        final index = _tasks.indexWhere((t) => t.id == task.id);
                        if (index != -1) {
                          _tasks[index] = Task(
                            id: task.id,
                            title: _titleController.text,
                            description: _descController.text,
                            isDone: task.isDone,
                            lastUpdated: DateTime.now(),
                          );
                        }
                      }
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _toggleTaskStatus(Task task, bool newStatus) {
    setState(() {
      task.isDone = newStatus;
      task.lastUpdated = DateTime.now();
    });
  }

  void _deleteTask(String taskId) {
    setState(() {
      _tasks.removeWhere((task) => task.id == taskId);
    });
  }
}
