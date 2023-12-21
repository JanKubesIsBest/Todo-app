import "package:unfuckyourlife/model/database/open_databases.dart";
import "package:unfuckyourlife/model/database/retrieve.dart";

import "../todo/Todo.dart";
import '../../model/notification/notifications.dart';


Future<void> deleteTodo(Todo todo) async {
  // Get a reference to the database.
  final db = await openOurDatabase();

  // Get the id
  List<Map<String, dynamic>> mapNotifList = await retrieveNotificationsById(todo.deadline);
  Map<String, dynamic> mapNotif = mapNotifList[0];

  int notificationId = mapNotif["id"];

  // Cancel the pending notif.
  NotificationService().cancelNotification(notificationId);

  // Remove notification from the database
  await db.delete(
    'notifications',
    // Use a `where` clause to delete a specific T_odo.
    where: 'id = ?',
    // Pass the T_odo's id as a whereArg to prevent SQL injection.
    whereArgs: [notificationId],
  );

  // Remove the T_odo from the database.
  await db.delete(
    'todos',
    // Use a `where` clause to delete a specific T_odo.
    where: 'id = ?',
    // Pass the T_odo's id as a whereArg to prevent SQL injection.
    whereArgs: [todo.id],
  );
}