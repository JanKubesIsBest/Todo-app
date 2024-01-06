import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
      String? title,
      String? body,
      String? payLoad,
      required DateTime scheduledNotificationDateTime,
      required Channel channel}) async {
    // Todo make work with channels
    int id = await addNewChannel(channel, scheduledNotificationDateTime);
    notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
        await notificationDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
    // Return the id so you can then connect it with the todos database --> look into docs
    return id;
  }

  Future<List<PendingNotificationRequest>> getActiveNotifications() async {
    return await notificationsPlugin.pendingNotificationRequests();
  }

  Future<void> showDailyAtTime(
      Channel channel, int id, DateTime startNotifying) async {
    print("show daily");
    notificationsPlugin.periodicallyShow(id, channel.name, "Repeat",
        RepeatInterval.daily, await notificationDetails());
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  void showNotificationNow(Channel channel) async {
    await notificationsPlugin.zonedSchedule(
        0,
        channel.name,
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        await notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}

Future<Channel> createNewChannel(
    Channel channel, DateTime startNotifyingAt) async {

  print("Adding new channel");
  int id = await addNewChannel(
    channel,
    startNotifyingAt,
  );

  if (DateTime.now().difference(startNotifyingAt).inSeconds < 0) {
    Timer(startNotifyingAt.difference(DateTime.now()), () {
      NotificationService().showNotificationNow(channel);
      NotificationService().showDailyAtTime(channel, id, startNotifyingAt);
    });
  } else {
    // day - time between now and start notifying time.
    // Example: it is 17, default time is 15. 15 - 17 = -2h
    // -2 + 24 = 22
    // 22 h after 17 is 15
    Duration x = startNotifyingAt.difference(DateTime.now());
    Duration y = Duration(seconds: x.inSeconds + 60 * 60 * 24);
    Timer(y, () {
      NotificationService().showDailyAtTime(channel, id, startNotifyingAt);
    });
  }

  List<Map<String, dynamic>> channelMapList = await retrieveChannelById(id);
  Map<String, dynamic> channelMap = channelMapList[0];

  return Channel(channelMap["id"], channelMap["name"], channelMap["notifier"], channelMap["isCustom"] == 1 ? true : false);
}
