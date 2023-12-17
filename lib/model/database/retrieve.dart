import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unfuckyourlife/model/database/open_databases.dart';
Future<List<Map<String, dynamic>>> retrieveTodos() async {
  final database = await openDatabase(
    join(await getDatabasesPath(), 'to_do_test.db'),
    onCreate: (db, version) {
      return createTodoTable(db);
    },
    version: 1,
  );
  final List<Map<String, dynamic>> maps = await database.query('todos');
  return maps;
}

