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

Future openNotyfiersDatabases() async {
  final database = await openDatabase(
    join(await getDatabasesPath(), 'to_do_test.db'),
    onCreate: (db, version) {
      return createNotifyerDatabaseTable(db);
    },
    version: 1,
  );

  return database;
}

Future<void> createNotifyerDatabaseTable(Database db) {
  return db.execute(
    'CREATE TABLE todos(id INTEGER PRIMARY KEY, day STRING, month STRING, year STRING, hour STRING, minute STRING)',
  );
}