import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future openOurDatabase() async {
  final database = await openDatabase(
    join(await getDatabasesPath(), 'newDatabase.db'),
    onCreate: (db, version) {
      print("Creating tables");
      createNotifierDatabaseTable(db);
      createTodoTable(db);
    },
    version: 1,
  );

  return database;
}

Future<void> createTodoTable(Database db) {
  return db.execute(
    'CREATE TABLE todos(id INTEGER PRIMARY KEY, name TEXT, description TEXT, created STRING, deadline STRING)',
  );
}

Future<void> createNotifierDatabaseTable(Database db) {
  print("Notif. database build.");
  // Reoccurring is INT because there is no native way of making bool in SQL
  return db.execute(
    'CREATE TABLE notifications(id INTEGER PRIMARY KEY, day STRING, month STRING, year STRING, hour STRING, minute STRING, recurring STRING)',
  );
}