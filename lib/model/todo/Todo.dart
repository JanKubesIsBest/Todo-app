class Todo {
  // Id is assigned automatically
  final String name;
  final String description;

  // TODO: Add time created, deadline.
  const Todo({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
    };
  }

  // Will be useful when printing
  @override
  String toString() {
    return 'Todo{todo_name: $name, description: $description}';
  }
}