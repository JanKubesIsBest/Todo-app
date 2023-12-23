import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

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
      required DateTime scheduledNotificationDateTime}) async {
    // Todo make work with channels
    int id = await addNewNotifier(scheduledNotificationDateTime);
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

  Future<void> showDailyAtTime(DateTime startNotifyingAt) async {
    print("show daily");
    // TODO: make work with channels.
    int id = await addNewNotifier(startNotifyingAt);
    notificationsPlugin.periodicallyShow(id, "Repeat", "Repeat", RepeatInterval.daily, await notificationDetails());
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}
