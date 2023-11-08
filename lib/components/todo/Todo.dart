class Todo {
  // Id is assigned automatically
  final String todoName;
  final String description;

  // TODO: Add time created, deadline.
  const Todo({
    required this.todoName,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': todoName,
      'age': description,
    };
  }

  @override
  String toString() {
    return 'Todo{todo_name: $todoName, description: $description}';
  }
}