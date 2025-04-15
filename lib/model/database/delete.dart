import "package:android_alarm_manager_plus/android_alarm_manager_plus.dart";
import "package:sqflite/sqflite.dart";
import "package:unfuckyourlife/model/database/channelClass/channel.dart";
import "package:unfuckyourlife/model/database/open_databases.dart";
import "package:unfuckyourlife/model/database/retrieve.dart";
import "package:unfuckyourlife/model/database/update.dart";
import "package:unfuckyourlife/model/todo/mapToTodo.dart";

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
    // Delete channel and its notification in database as well as in Notification manager.
    _deleteChannel(Channel(channel["id"], channel["name"],
          channel["notifier"], channel["isCustom"] == 1 ? true : false), db);
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

Future<void> deleteChannel(Channel channel,) async {
  final db = await openOurDatabase();

    // Delete channel and its notification in database as well as in Notification manager
    await _deleteChannel(channel, db);

    // Rebrand the todos in the channel and add them to the default
    // TODO: Make a option to choose where to redirect the Todos

    // Get Todos in channel
    List<Map<String, dynamic>> todosInTheChannel = await retrieveTodosByChannel(channel.id);

    // Update them all in the database 
    for (final Map<String, dynamic> todoMap in todosInTheChannel) {
      // Only thing needed is the id, which is 1 when custom
      // TODO: Look at todo above 
      updateTodoById(mapToTodo(todoMap), Channel(1, "name", 0, false));
    }

    // Stop timer
    // Should be everything as the Time is connected through id of the channel
    AndroidAlarmManager.cancel(channel.id);
}

Future<void> _deleteChannel(Channel channel, Database database) async {
  final db = database;

  // Cancel the pending notif.
  NotificationService().cancelNotification(channel.notification);

  // Remove notification from the database
  await db.delete(
    'notifications',
    // Use a `where` clause to delete a specific T_odo.
    where: 'id = ?',
    // Pass the T_odo's id as a whereArg to prevent SQL injection.
    whereArgs: [channel.notification],
  );

  // Remove the custom channel
  await db.delete(
    'channels',
    // Use a `where` clause to delete a specific T_odo.
    where: 'id = ?',
    // Pass the Todo's id as a whereArg to prevent SQL injection.
    whereArgs: [channel.id],
  );
}