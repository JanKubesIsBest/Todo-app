import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'insert_and_create.dart';

Future<List<Map<String, dynamic>>> retrieveTodos() async {
  final database = await openDatabase(
    join(await getDatabasesPath(), 'to_do_test.db'),
    onCreate: (db, version) {
      return createTable(db);
    },
    version: 1,
  );
  final List<Map<String, dynamic>> maps = await database.query('todos');
  return maps;
}
