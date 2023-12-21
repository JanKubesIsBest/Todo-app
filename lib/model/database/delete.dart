import "package:unfuckyourlife/model/database/open_databases.dart";

Future<void> deleteTodo(int id) async {
  // Get a reference to the database.
  final db = await openOurDatabase();

  // Get the id
  //final maps = await db.query('notifications', where: '_id = ?', whereArgs: [id]);
  // Cancel the pending notif.

  // Remove the T_odo from the database.
  await db.delete(
    'todos',
    // Use a `where` clause to delete a specific T_odo.
    where: 'id = ?',
    // Pass the T_odo's id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}