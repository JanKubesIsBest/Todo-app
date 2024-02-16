import 'dart:async';
import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:unfuckyourlife/components/homePage/HomePage.dart';
import 'package:unfuckyourlife/model/database/open_databases.dart';
import 'package:unfuckyourlife/model/database/retrieve.dart';
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
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.high),
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<List<int>> getActiveNotifications() async {
    List<PendingNotificationRequest> notifications =
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

Future<void> showDailyAtTime(int id) async {
  final Channel channel = await getChannel(id);
  var sucess = await AndroidAlarmManager.initialize();

  await NotificationService()
      .showNotiificationAt(channel, DateTime.now().add(Duration(seconds: 5)));

  await AndroidAlarmManager.oneShot(
      const Duration(days: 1), channel.id, showDailyAtTime,
      allowWhileIdle: true, exact: true);
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

  await AndroidAlarmManager.oneShotAt(
      startNotifyingAt, channel.id, showNotifications,
      allowWhileIdle: true, exact: true);
}

// Callback function for channel notification.
// Id is an channel id, which is also name of the timer
void showNotifications(int id) async {
  // Retriving channel
  final Channel channel = await getChannel(id);

  // Retriving notification for notification time using retrieved channel id
  List<Map<String, dynamic>> notificationMapedList =
      await retrieveNotificationsById(channel.notification);
  Map<String, dynamic> notificationMaped = notificationMapedList[0];

  // I hope there is no delay... There should not be any as exact is set to true
  // Checking if the time is still the same as in the database
  if (notificationMaped["hour"] == DateTime.now().hour &&
      notificationMaped["minute"] == DateTime.now().minute) {
    await showDailyAtTime(channel.id);
  }
}

// Create recuring todo
// Also a comeback for recuring Todo.
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

// Recuring oneshot function
Future<void> periodicallyShowTodo(Todo todo) async {
  var sucess = await AndroidAlarmManager.initialize();

  print("One shot at ${todo.durationOfRecuring}");

  DateTime deadline = await todo.getDeadline();

  // todo.id as int should be okay, as I'm asigning it in the _insertTodo function.
  // deadline.difference(DateTime.now()).inSeconds solves the next day problem, as to the duration is also added the difference between now and deadline
  await AndroidAlarmManager.oneShot(
      Duration(
          seconds: todo.durationOfRecuring +
              (deadline.difference(DateTime.now()).inSeconds)),
      todo.id as int,
      addNewTodoThatIsRecuring,
      allowWhileIdle: true,
      exact: true);
}

Future<Channel> getChannel(int id) async {
  final List<Map<String, dynamic>> listChannelMaped =
      await retrieveChannelById(id);
  final Map<String, dynamic> channelMaped = listChannelMaped[0];

  final Channel channel = Channel(channelMaped["id"], channelMaped["name"],
      channelMaped["notifier"], channelMaped["isCustom"] == 1 ? true : false);

  return channel;
}
