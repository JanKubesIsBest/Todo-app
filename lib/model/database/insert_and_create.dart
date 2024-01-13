import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unfuckyourlife/model/database/open_databases.dart';

import '../todo/Todo.dart';
import 'channelClass/channel.dart';

Future<void> addNewTodoToDatabase(Todo todo) async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openOurDatabase();

  _insertTodo(database, todo);
}

// Define a function that inserts dogs into the database
Future<void> _insertTodo(database, Todo todo) async {
  print("inserting todo");
  // Get a reference to the database.
  var db = await database;
  await db.insert(
    'todos',
    todo.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<int> addNewNotifier( DateTime date) async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openOurDatabase();
  return _insertNotification(database, date,);
}
Future<int> _insertNotification(database, DateTime date,)async {
  var db = await database;

  return await db.insert(
    'notifications',
    {'day': date.day.toString(), 'month': date.month.toString(), 'year': date.year.toString(), 'hour': date.hour.toString(), 'minute':date.minute.toString()},
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

Future<int> addNewChannel(Channel channel, DateTime date,) async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openOurDatabase();

  return _insertChannel(database, channel, date);
}
Future<int> _insertChannel(database, Channel channel, DateTime date) async {
  var db = await database;

  int databaseId = await addNewNotifier(date);

  return await db.insert(
    'channels',
    {'name': channel.name, 'notifier': databaseId, 'isCustom': channel.isCustom ? 1 : 0},
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

Future<int> addNewDeadline( DateTime date) async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openOurDatabase();
  return _insertNewDeadline(database, date,);
}
Future<int> _insertNewDeadline(database, DateTime date,)async {
  var db = await database;

  return await db.insert(
    'deadlines',
    {'day': date.day.toString(), 'month': date.month.toString(), 'year': date.year.toString(),},
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}