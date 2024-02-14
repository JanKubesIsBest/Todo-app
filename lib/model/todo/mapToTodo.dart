import 'package:unfuckyourlife/model/todo/Todo.dart';

Todo mapToTodo(Map<String, dynamic> map) {
  return Todo(name: map["name"], description: map["description"], created: DateTime.parse(map["created"]), deadline: map['deadlineId'], id: map['id'], channel: map['channelId'], isRecuring: map['isRecuring'], durationOfRecuring: map["durationOfRecuring"]);
}