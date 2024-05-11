import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unfuckyourlife/model/database/open_databases.dart';
import 'package:unfuckyourlife/model/notification/notification_class.dart';
import 'package:unfuckyourlife/model/notification/notifications.dart';

import '../todo/Todo.dart';
import 'channelClass/channel.dart';

/// Creates instance of todo
/// If the todo is recuring, it makes multiple instances, starting from the first instance deadline.
/// Needs deadline to exist already
Future<void> addNewTodoToDatabase(Todo todo, bool isCustom) async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openOurDatabase();

  if (todo.isRecuring) {
    // Check how many times you will need to create instance of todo (if recuring)
    final DateTime firstInstance = await todo.getDeadline();
    final DateTime nextTwoDays = firstInstance.add(const Duration(days: 2));

    final Duration difference = nextTwoDays.difference(firstInstance);

    final int howManyTimes = difference.inSeconds ~/ todo.durationOfRecuring;

    // Make a for loop
    // <= because there can be just one instance
    for (int i = 0; i <= howManyTimes; i++) {
      final Duration addDurationToCreatedInSeconds = Duration(seconds: i * todo.durationOfRecuring,);

      final Todo newTodo = Todo(done: false, durationOfRecuring: todo.durationOfRecuring, isRecuring: todo.isRecuring, channel: todo.channel, created: firstInstance.add(addDurationToCreatedInSeconds), name: todo.name, description: todo.description, deadline: todo.deadline);
      _insertTodo(database, todo, isCustom);
    }

    // in the for loop, create each notifier instance and todo instance
  }

}

/// Adds Todo to database and makes a zoned notification for it (if it is custom).
Future<void> _insertTodo(Database db, Todo todo, bool isCustom) async {
  // Insert todo into the database
  int todoInsertedId = await db.insert(
    'todos',
    todo.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  // Create notifier and notification (if custom)
  if (isCustom) {
    // Create new custom channel 
    // New channel name is a name of the custom todo, as that's what's going to display in the notification
    insertChannel(db, Channel(0, todo.name, isCustom), todo.created);
  }
}

Future<int> insertChannel(Database db, Channel channel, DateTime date) async {
  // Add notifier
  final int databaseId = await _insertNotification(db, date);

  NotificationInfo notifInfo = NotificationInfo(time: date, id: databaseId);

  // Create zoned schedule
  NotificationService().showNotificationAt(channel, notifInfo);

  return await db.insert(
    'channels',
    {'name': channel.name, 'notifier': databaseId, 'isCustom': channel.isCustom ? 1 : 0},
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

Future<int> _insertNotification(Database db, DateTime date,)async {
  return await db.insert(
    'notifications',
    {'day': date.day.toString(), 'month': date.month.toString(), 'year': date.year.toString(), 'hour': date.hour.toString(), 'minute':date.minute.toString()},
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

Future<int> addNewDeadline( DateTime date,) async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openOurDatabase();
  return _insertNewDeadline(database, date,);
}

Future<int> _insertNewDeadline(database, DateTime date,)async {
  var db = await database;

  return await db.insert(
    'deadlines',
    {'day': date.day.toString(), 'month': date.month.toString(), 'year': date.year.toString(), 'hour': date.hour.toString(), 'minute': date.minute.toString()},
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}