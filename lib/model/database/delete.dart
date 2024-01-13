import "package:unfuckyourlife/model/database/open_databases.dart";
import "package:unfuckyourlife/model/database/retrieve.dart";

import "../todo/Todo.dart";
import '../../model/notification/notifications.dart';

Future<void> deleteTodo(Todo todo) async {
  // Get a reference to the database.
  final db = await openOurDatabase();

  print(todo.channel);
  print(await retrieveChannels());
  
  // Get Channel
  List<Map<String, dynamic>> mapChannelList =
      await retrieveChannelById(todo.channel);
  Map<String, dynamic> channel = mapChannelList[0];

  // If it is custom, then delete it.
  if (channel["isCustom"] == 1) {
    // Get the id
    List<Map<String, dynamic>> mapNotifList =
        await retrieveNotificationsById(todo.channel);
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

    // Remove the custom channel
    await db.delete(
      'channels',
      // Use a `where` clause to delete a specific T_odo.
      where: 'id = ?',
      // Pass the T_odo's id as a whereArg to prevent SQL injection.
      whereArgs: [todo.channel],
    );
  }
  // Todo and deadline will be removed. Does not matter if it is custom or not.

  // Remove deadline
  await db.delete(
    'deadlines',
    // Use a `where` clause to delete a specific T_odo.
    where: 'id = ?',
    // Pass the T_odo's id as a whereArg to prevent SQL injection.
    whereArgs: [todo.deadline],
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

Future<void> deleteNotification(notificationId) async {
  final db = await openOurDatabase();
  await db.delete(
    'notifications',
    // Use a `where` clause to delete a specific T_odo.
    where: 'id = ?',
    // Pass the T_odo's id as a whereArg to prevent SQL injection.
    whereArgs: [notificationId],
  );
}
