import 'package:unfuckyourlife/model/database/open_databases.dart';
Future<List<Map<String, dynamic>>> retrieveTodos() async {
  print("retriving todos");
  final database = await openOurDatabase();
  final List<Map<String, dynamic>> maps = await database.query('todos');
  return maps;
}

Future<List<Map<String, dynamic>>> retrieveTodosByChannel(int channelId) async {
  print("retriving todos");
  final database = await openOurDatabase();
  final List<Map<String, dynamic>> maps = await database.query('todos', where: 'channelId = ?', whereArgs: [channelId]);
  return maps;
}

Future<List<Map<String, dynamic>>> retrieveNotifications() async {
  final database = await openOurDatabase();
  final List<Map<String, dynamic>> maps = await database.query('notifications');
  return maps;
}

Future<List<Map<String, dynamic>>> retrieveNotificationsById(int id) async {
  final db = await openOurDatabase();
  final maps = await db.query('notifications', where: 'id = ?', whereArgs: [id]);
  return maps;
}

Future<List<Map<String, dynamic>>> retrieveDeadlinesById(int id) async {
  final db = await openOurDatabase();
  final maps = await db.query('deadlines', where: 'id = ?', whereArgs: [id]);
  return maps;
}

Future<List<Map<String, dynamic>>> retrieveChannels() async {
  final database = await openOurDatabase();
  final List<Map<String, dynamic>> maps = await database.query('channels');
  return maps;
}

Future<List<Map<String, dynamic>>> retrieveChannelById(int id) async {
  final database = await openOurDatabase();
  final List<Map<String, dynamic>> maps = await database.query('channels', where: 'id = ?', whereArgs: [id]);
  return maps;
}

Future<List<Map<String, dynamic>>> retrieveChannelByName(String name) async {
  final database = await openOurDatabase();
  final List<Map<String, dynamic>> maps = await database.query('channels', where: 'name = ?', whereArgs: [name]);
  return maps;
}


Future<List<Map<String, dynamic>>> retrieveDeadlines() async {
  final database = await openOurDatabase();
  final List<Map<String, dynamic>> maps = await database.query('deadlines');
  return maps;
}