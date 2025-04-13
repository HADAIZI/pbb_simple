# simple

A new Flutter project.

## Video

https://youtu.be/cdvG3C0PRdw


## Update Database
In this update, I integrated SQLite for data persistence in the app.

### 1. **Created `DatabaseHelper`**

reated the `DatabaseHelper` class to manage SQLite operations. It includes methods for CRUD (Create, Read, Update, Delete) operations on tasks.

```dart
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }
}
```
### 2. **Updated `Task` Class**

Modified the `Task` class to add methods for converting between `Task` objects and `Map<String, dynamic>`, required for database storage and retrieval.

```dart
class Task {
  final String id;
  final String title;
  final String description;
  bool isDone;
  DateTime? lastUpdated;

  Task({required this.id, required this.title, required this.description, this.isDone = false, this.lastUpdated});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone ? 1 : 0,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'].toString(),
      title: map['title'],
      description: map['description'],
      isDone: map['isDone'] == 1,
      lastUpdated: DateTime.tryParse(map['lastUpdated']),
    );
  }
}

```

### 3. **Integrated Database into `main.dart`**

Updated the `HomeScreen` to use the `DatabaseHelper` for fetching, adding, updating, and deleting tasks. The task list now loads from the SQLite database on startup, ensuring data persists between app restarts.

```dart
class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = DatabaseHelper.instance.getTasks();  // Fetch tasks from DB
  }

}

```

### Conclusion
Now, tasks are stored in an SQLite database, ensuring persistence across app sessions. Changes made to tasks are saved and retrieved when the app is reopened.