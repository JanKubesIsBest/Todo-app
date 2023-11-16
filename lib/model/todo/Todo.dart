class Todo {
  // Id is assigned automatically
  final String name;
  final String description;
  final DateTime created;

  // TODO: Add time created, deadline.
  const Todo({
    required this.created,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      // Needs to be done, bcs SQL does not know DateTime
      'created': created.toIso8601String(),
    };
  }

  // Will be useful when printing
  @override
  String toString() {
    return 'Todo{todo_name: $name, description: $description}';
  }
}