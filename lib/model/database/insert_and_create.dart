import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../todo/Todo.dart';

Future openTodoDatabase() async {
  final database = await openDatabase(
    join(await getDatabasesPath(), 'to_do_test.db'),
    onCreate: (db, version) {
      return createTable(db);
    },
    version: 1,
  );

  return database;
}

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

Future<void> createTable(Database db) {
  return db.execute(
    'CREATE TABLE todos(id INTEGER PRIMARY KEY, name TEXT, description TEXT)',
  );
}