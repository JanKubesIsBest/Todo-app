import 'dart:async';
import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:unfuckyourlife/model/database/retrieve.dart';

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

    final List<Map<String, dynamic>> listChannelMaped =
        await retrieveChannelById(id);
    final Map<String, dynamic> channelMaped = listChannelMaped[0];

    final Channel channelWithRightIds = Channel(
        channelMaped["id"],
        channelMaped["name"],
        channelMaped["notifier"],
        channelMaped["isCustom"] == 1 ? true : false);

    showNotiificationAt(channelWithRightIds, scheduledNotificationDateTime);
    // Return the id so you can then connect it with the todos database --> look into docs
    return id;
  }

  Future<void> showNotiificationAt(Channel channel, DateTime time) async {
    print("Show notif");

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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,);
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

  Future<void> showDailyAtTime(Channel channel, DateTime startNotifying) async {
    print("show daily");

    // notificationsPlugin.show(Random().nextInt(1000000), channel.name, "Repeat", await notificationDetails(),);
    // Notification plugin notification is connected to notification in database
    notificationsPlugin.periodicallyShow(
        channel.id,
        channel.name,
        "Repeat",
        RepeatInterval.daily,
        await notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}

Future<Channel> createNewChannel(
    Channel channel, TimeOfDay notifyAt) async {
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
  print(channelMap);
  final Channel returnChannel = Channel(channelMap["id"], channelMap["name"],
      channelMap["notifier"], channelMap["isCustom"] == 1 ? true : false);


  print("Timer");
  print(startNotifyingAt);
  createPeriodicallNotificationWithTimeCalculation(
      returnChannel, startNotifyingAt);

  // Schedule notification
  print("Scheduling notification");
  NotificationService().showNotiificationAt(returnChannel, startNotifyingAt);

  return returnChannel;
}

Future<void> createPeriodicallNotificationWithTimeCalculation(
    Channel channel, DateTime startNotifyingAt) async {
  var sucess = await AndroidAlarmManager.initialize();
  
  print(startNotifyingAt);
  await AndroidAlarmManager.oneShotAt(startNotifyingAt, channel.id, showNotifications,
    allowWhileIdle: true, exact: true);
  }

// Id is an channel id, which is also name of the timer
void showNotifications(int id) async {
  // I don't know why I have to intialize this
  initializeTimeZones();
  print("hi");

  // Retriving channel
  List<Map<String, dynamic>> channelMapList = await retrieveChannelById(id);
  Map<String, dynamic> channelMap = channelMapList[0];
  final Channel channel = Channel(channelMap["id"], channelMap["name"],
      channelMap["notifier"], channelMap["isCustom"] == 1 ? true : false);

  // Retriving notification for notification time using retrieved channel id
  List<Map<String, dynamic>> notificationMapedList =
      await retrieveNotificationsById(channel.notification);
  Map<String, dynamic> notificationMaped = notificationMapedList[0];

  // I hope there is no delay... There should not be any as exact is set to true
  // Checking if the time is still the same as in the database
  if (notificationMaped["hour"] == DateTime.now().hour &&
      notificationMaped["minute"] == DateTime.now().minute) {
    print("NOW MAKE THE NOTIFICATION");
    print(tz.TZDateTime.from(
        DateTime.now().add(const Duration(seconds: 5)), tz.local));
    print(tz.local);
    print(channel.notification);

    await NotificationService().showDailyAtTime(channel, DateTime.now());
  }
}
