import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future openTodoDatabase() async {
  final database = await openDatabase(
    // TODO: Make a different name for to_do_test.db
    join(await getDatabasesPath(), 'to_do_test.db'),
    onCreate: (db, version) {
      return createTodoTable(db);
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

Future openNotifierDatabase() async {
  final database = await openDatabase(
    join(await getDatabasesPath(), 'notifications.db'),
    onCreate: (db, version) {
      return createNotifierDatabaseTable(db);
    },
    version: 1,
  );

  return database;
}

Future<void> createNotifierDatabaseTable(Database db) {
  return db.execute(
    'CREATE TABLE notifications(id INTEGER PRIMARY KEY, day STRING, month STRING, year STRING, hour STRING, minute STRING)',
  );
}