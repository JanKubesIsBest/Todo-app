import "package:unfuckyourlife/model/database/open_databases.dart";

Future<void> deleteTodo(int id) async {
  // Get a reference to the database.
  final db = await openTodoDatabase();

  // Remove the Dog from the database.
  await db.delete(
    'todos',
    // Use a `where` clause to delete a specific dog.
    where: 'id = ?',
    // Pass the Dog's id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}