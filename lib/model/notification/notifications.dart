import 'dart:async';
import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:unfuckyourlife/components/homePage/HomePage.dart';
import 'package:unfuckyourlife/model/database/delete.dart';
import 'package:unfuckyourlife/model/database/open_databases.dart';
import 'package:unfuckyourlife/model/database/retrieve.dart';
import 'package:unfuckyourlife/model/database/update.dart';
import 'package:unfuckyourlife/model/todo/Todo.dart';
import 'package:unfuckyourlife/model/todo/mapToTodo.dart';

import '../database/channelClass/channel.dart';
import '../database/insert_and_create.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('flutter_logo');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.high, icon: '@mipmap/ic_launcher'),
        iOS: DarwinNotificationDetails());
  }

  Future<int> scheduleNotification(
      {int id = 0,
      String? payLoad,
      required DateTime scheduledNotificationDateTime,
      required Channel channel}) async {
    final int id = await addNewChannel(channel, scheduledNotificationDateTime);

    final Channel channelWithRightIds = await getChannel(id);

    showNotiificationAt(channelWithRightIds, scheduledNotificationDateTime);
    // Return the id so you can then connect it with the todos database --> look into docs
    return id;
  }
  
  @pragma("vm:entry-point")
  Future<void> showNotiificationAt(Channel channel, DateTime time) async {
    print("Show notif");

    await configureLocalTimeZone();

    await notificationsPlugin.zonedSchedule(
      // Notification is referenced in notif table in the database
      // This is working
      Random().nextInt(1000000),
      channel.name,
      "TODO Make description",
      tz.TZDateTime.from(time, tz.local),
      await notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<List<int>>? getActiveNotifications() async {
    List<PendingNotificationRequest>? notifications =
        await notificationsPlugin.pendingNotificationRequests();

    List<int> notifId = [];

    for (PendingNotificationRequest notif in notifications) {
      notifId.add(notif.id);
    }

    return notifId;
  }

  Future<List<int>> getPendingNotifications() async {
    List<PendingNotificationRequest> notifications =
        await notificationsPlugin.pendingNotificationRequests();

    List<int> notifId = [];
    for (PendingNotificationRequest notif in notifications) {
      notifId.add(notif.id);
    }
    return notifId;
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}

// Creating channel
Future<Channel> createNewChannel(Channel channel, TimeOfDay notifyAt) async {
  print("Adding new channel");

  DateTime startNotifyingAt = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    notifyAt.hour,
    notifyAt.minute,
  );

  // If the current time is before the start notyfing at, add one day to it.
  if (startNotifyingAt.difference(DateTime.now()).inSeconds < 0) {
    startNotifyingAt = startNotifyingAt.add(const Duration(days: 1));
  }

  // This will add channel and notifier into the database
  int id = await addNewChannel(
    channel,
    startNotifyingAt,
  );

  List<Map<String, dynamic>> channelMapList = await retrieveChannelById(id);
  Map<String, dynamic> channelMap = channelMapList[0];

  final Channel returnChannel = Channel(channelMap["id"], channelMap["name"],
      channelMap["notifier"], channelMap["isCustom"] == 1 ? true : false);

  createPeriodicallNotificationWithTimeCalculation(
      returnChannel, startNotifyingAt);

  return returnChannel;
}

// Oneshot at for channel
Future<void> createPeriodicallNotificationWithTimeCalculation(
    Channel channel, DateTime startNotifyingAt) async {
  var sucess = await AndroidAlarmManager.initialize();

  await AndroidAlarmManager.periodic(const Duration(days: 1), channel.id, showNotifChannel,
      allowWhileIdle: true, exact: true, startAt: startNotifyingAt);
}

@pragma("vm:entry-point")
Future<void> showNotifChannel(int id) async {
  final Channel channel = await getChannel(id);
  
  await NotificationService()
      .showNotiificationAt(channel, DateTime.now().add(Duration(seconds: 5)));
}

@pragma("vm:entry-point")
Future<Channel> getChannel(int id) async {
  final List<Map<String, dynamic>> listChannelMaped =
      await retrieveChannelById(id);
  final Map<String, dynamic> channelMaped = listChannelMaped[0];

  final Channel channel = Channel(channelMaped["id"], channelMaped["name"],
      channelMaped["notifier"], channelMaped["isCustom"] == 1 ? true : false);

  return channel;
}

// Recuring oneshot function
Future<void> periodicallyShowTodo(Todo todo) async {
  var sucess = await AndroidAlarmManager.initialize();

  // TODO: Do start at 
  await AndroidAlarmManager.periodic(Duration(seconds: todo.durationOfRecuring), todo.id as int, makeNewRecuringTodo, startAt: await todo.getDeadline(), allowWhileIdle: true,
      exact: true);
}

Future<void> makeNewRecuringTodo(int id) async {
  // TODO: Handle the case where user deletes his recuring todo
  // Retriving todo
  List<Map<String, dynamic>> todosList = await retrieveTodosById(id);
  Map<String, dynamic> todoMap = todosList[0];
  final Todo todo = mapToTodo(todoMap);
  
  final Todo newTodo = new Todo(durationOfRecuring: todo.durationOfRecuring, isRecuring: todo.isRecuring, channel: todo.channel, created: todo.created, name: todo.name, description: todo.description, deadline: todo.deadline);

  // Only channel id is needed.
  updateTodoById(todo, Channel(todo.channel, "Name", 0, false));
  
}

void addNewTodoThatIsRecuring(int id) async {
  // Retriving channel
  List<Map<String, dynamic>> todosList = await retrieveTodosById(id);
  Map<String, dynamic> todoMap = todosList[0];
  final Todo todo = mapToTodo(todoMap);

  // Scenario for custom is not done yet

  // Retrieving deadline
  DateTime deadline = await todo.getDeadline();

  // add new deadline
  int deadlineId = await addNewDeadline(
    DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
    ).add(Duration(seconds: todo.durationOfRecuring)),
  );

  Todo newTodo = Todo(
      durationOfRecuring: todo.durationOfRecuring,
      isRecuring: todo.isRecuring,
      channel: todo.channel,
      created: todo.created,
      name: todo.name,
      description: todo.description,
      deadline: deadlineId);

  // Get a reference to the database.
  final db = await openOurDatabase();

  int todoInsertedId = await db.insert(
    'todos',
    newTodo.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  Todo newTodoWithRightId = Todo(
      id: todoInsertedId,
      durationOfRecuring: todo.durationOfRecuring,
      isRecuring: todo.isRecuring,
      channel: todo.channel,
      created: todo.created,
      name: todo.name,
      description: todo.description,
      deadline: deadlineId);

  periodicallyShowTodo(newTodoWithRightId);
}