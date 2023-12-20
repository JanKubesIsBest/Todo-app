import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unfuckyourlife/model/database/open_databases.dart';

import '../todo/Todo.dart';

void addNewTodoToDatabase(Todo todo) async {
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

Future<int> addNewNotifier( DateTime date, bool recurring) async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openOurDatabase();
  return _insertNotification(database, date, recurring);
}
Future<int> _insertNotification(database, DateTime date, bool recurring)async {
  var db = await database;

  await db.insert(
    'notifications',
    {'day': date.day.toString(), 'month': date.month.toString(), 'year': date.year.toString(), 'hour': date.hour.toString(), 'minute':date.minute.toString(), 'recurring': recurring ? '1' : '0'},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  // TODO: Make it so it actually returns id of notification
  return 0;
}