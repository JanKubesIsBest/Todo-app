class Todo {
  // Id is assigned automatically
  final int? id;
  final String name;
  final String description;
  final DateTime created;
  final DateTime deadline;

  // TODO: Add time created, deadline.
  // Id is not required, bcs we don't even use it when building components.
  const Todo({
    required this.created,
    required this.name,
    required this.description,
    required this.deadline,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      // Needs to be done, bcs SQL does not know DateTime
      'created': created.toIso8601String(),
      'deadline': deadline.toIso8601String(),
    };
  }

  // Will be useful when printing
  @override
  String toString() {
    return 'Todo{todo_name: $name, description: $description, deadline: $deadline, created: $created}';
  }
}