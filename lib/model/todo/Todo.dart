import 'package:unfuckyourlife/model/database/retrieve.dart';

class Todo {
  // Id is assigned automatically
  final int? id;
  final String name;
  final String description;
  final DateTime created;
  final int deadline;
  final int channel;

  // Id is not required, bcs we don't even use it when building components.
  const Todo({
    required this.channel,
    required this.created,
    required this.name,
    required this.description,
    required this.deadline,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      // Needs to be done, bcs SQL does not know DateTime
      'created': created.toIso8601String(),
      'deadlineId': deadline,
      'channelId': channel,
    };
  }

  // Will be useful when printing
  @override
  String toString() {
    return 'Todo{todo_name: $name, description: $description, deadline: $deadline, created: $created, channel: $channel}';
  }

  Future<DateTime> getDeadline() async {
    List<Map<String, dynamic>> mapedNotifList = await retrieveNotificationsById(deadline);
    
    if (mapedNotifList.isNotEmpty) {
      Map<String, dynamic> mapedNotif = mapedNotifList[0];
      return DateTime(mapedNotif['year'], mapedNotif['month'], mapedNotif['day'], mapedNotif['hour'], mapedNotif['minute']);
    }
    else {
      // should not happen
      print("!!!!!!!!!!!!!! Notifier was not found.");
      return DateTime.now();
    }
  }
}