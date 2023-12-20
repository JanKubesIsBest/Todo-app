import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unfuckyourlife/model/database/open_databases.dart';

import '../todo/Todo.dart';

void addNewTodoToDatabase(Todo todo) async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openTodoDatabase();

  _insertTodo(database, todo);
}

// Define a function that inserts dogs into the database
Future<void> _insertTodo(database, Todo todo) async {
  // Get a reference to the database.
  var db = await database;
  await db.insert(
    'todos',
    todo.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<int> addNewNotifier( DateTime date, bool recurring) async{
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openNotifierDatabase();

  database.insert(
    'notifications',
    {'day': date.day.toString(), 'month': date.month.toString(), 'year': date.year.toString(), 'hour': date.hour.toString(), 'minute':date.minute.toString(), 'recurring': recurring ? '1' : '0'},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  // TODO: Make it so it actually rereturns id of notification
  return 0;
}