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

  // Convert Task to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone':
          isDone ? 1 : 0, // SQLite doesn't store boolean, so we store as 1 or 0
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // Convert Map to Task
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
