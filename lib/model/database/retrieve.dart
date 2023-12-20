import 'package:unfuckyourlife/model/database/open_databases.dart';
Future<List<Map<String, dynamic>>> retrieveTodos() async {
  final database = await openOurDatabase();
  final List<Map<String, dynamic>> maps = await database.query('todos');
  return maps;
}

Future<List<Map<String, dynamic>>> retrieveNotifications() async {
  final database = await openOurDatabase();
  final List<Map<String, dynamic>> maps = await database.query('notifications');
  return maps;
}

