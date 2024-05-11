import 'package:unfuckyourlife/model/database/channelClass/channel.dart';
import 'package:unfuckyourlife/model/database/open_databases.dart';
import 'package:unfuckyourlife/model/todo/Todo.dart';

Future<void> updateChannelById(Channel newChannel) async {
  final database = await openOurDatabase();

  database.update(
    'channels',
    {'name': newChannel.name, 'notifier': newChannel.deadline, 'isCustom': newChannel.isCustom ? 1 : 0},
      // Ensure that the Todo has a matching id.
    where: 'id = ?',
    // Pass the Todo id as a whereArg to prevent SQL injection.
    whereArgs: [newChannel.id],
  );
}

Future<void> updateNotificationById(int id, DateTime date) async {
  final database = await openOurDatabase();

  database.update(
    'notifications',
    {'day': date.day.toString(), 'month': date.month.toString(), 'year': date.year.toString(), 'hour': date.hour.toString(), 'minute':date.minute.toString()},
      // Ensure that the Todo has a matching id.
    where: 'id = ?',
    // Pass the Todo id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}

Future<void> updateDeadlineById(int id, DateTime date) async {
  final database = await openOurDatabase();

  database.update(
    'deadlines',
    {'day': date.day.toString(), 'month': date.month.toString(), 'year': date.year.toString(),},
    where: 'id = ?',
    // Pass the Todo id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}

Future<void> updateTodoById(Todo todo, Channel newChannel) async{
  final database = await openOurDatabase();

  Todo redirectedTodo = Todo(channel: newChannel.id, created: todo.created, name: todo.name, description: todo.description, deadline: todo.deadline, isRecuring: todo.isRecuring, durationOfRecuring: todo.durationOfRecuring, done: todo.done);

  database.update(
    'todos',
    redirectedTodo.toMap(),
      // Ensure that the Todo has a matching id.
    where: 'id = ?',
    // Pass the Todo id as a whereArg to prevent SQL injection.
    whereArgs: [todo.id],
  );
}
