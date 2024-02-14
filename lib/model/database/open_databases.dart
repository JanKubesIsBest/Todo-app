import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> openOurDatabase() async {
  print("open our database");
  final database = await openDatabase(
    join(await getDatabasesPath(), 'appDatabase.db'),
    onCreate: (db, version) {
      print("Creating tables");
      createNotifierDatabaseTable(db);
      createTodoTable(db);
      createChannelDatabase(db);
      createDeadlineDatabaseTable(db);
    },
    version: 1,
  );

  return database;
}

Future<void> createTodoTable(Database db) {
  print("Todos created");
  return db.execute(
    // Bools are in Ints, as you can't do bool in mySQL database, instead you make 0 or 1
    'CREATE TABLE todos(id INTEGER PRIMARY KEY, name TEXT, description TEXT, created STRING, channelId INT, deadlineId int, isRecuring int, durationOfRecuring int)',
  );
}

Future<void> createNotifierDatabaseTable(Database db) {
  print("Notif. database build.");
  // Reoccurring is INT because there is no native way of making bool in SQL
  return db.execute(
    'CREATE TABLE notifications(id INTEGER PRIMARY KEY, day STRING, month STRING, year STRING, hour STRING, minute STRING)',
  );
}

Future<void> createChannelDatabase(Database db) {
  print("Channel database build.");
  // Every custom tod+o has it's own channel column named deadline.
  return db.execute(
    'CREATE TABLE channels(id INTEGER PRIMARY KEY, name STRING, notifier INTEGER, isCustom INTEGER)',
  );
}

Future<void> createDeadlineDatabaseTable(Database db) {
  print("Notif. database build.");
  // Reoccurring is INT because there is no native way of making bool in SQL
  return db.execute(
    'CREATE TABLE deadlines(id INTEGER PRIMARY KEY, day STRING, month STRING, year STRING)',
  );
}