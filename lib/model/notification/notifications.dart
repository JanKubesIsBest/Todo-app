import 'dart:async';
import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:unfuckyourlife/components/homePage/HomePage.dart';
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
            importance: Importance.high, icon: '@mipmap/ic_launcher'),
        iOS: DarwinNotificationDetails());
  }
  
  @pragma("vm:entry-point")
  Future<int> scheduleNotification(
      {int id = 0,
      String? payLoad,
      required DateTime scheduledNotificationDateTime,
      required Channel channel}) async {

        return 0;
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
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
