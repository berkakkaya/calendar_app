import 'dart:io';

import 'package:calendar_app/utils/parsing.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _i = NotificationService._();
  static NotificationService get i => _i;

  bool _initialized = false;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    "eventNotification",
    "Etkinlik Bildirimleri",
    channelDescription:
        "Yaklaşan etkinlik bildirimleri bu kanal üzerinden iletilir.",
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    actions: [
      AndroidNotificationAction(
        "ok",
        "Tamam",
        cancelNotification: true,
      ),
    ],
    category: AndroidNotificationCategory.event,
    autoCancel: true,
    enableVibration: true,
    visibility: NotificationVisibility.public,
  );

  static const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );

  NotificationService._();

  /// Initializes the notification service.
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    if (Platform.isAndroid) {
      final bool? permissionGot = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();

      if (permissionGot != null) _initialized = permissionGot;
    }

    // Initialize the timezone
    tz.initializeTimeZones();

    final bool? initialized = await _flutterLocalNotificationsPlugin
        .initialize(initializationSettings);

    if (initialized == false) _initialized = false;
  }

  Future<void> scheduleNotification({
    required String eventId,
    required String eventName,
    required DateTime startsAt,
    required int remindAt,
  }) async {
    if (_initialized) return;

    final int id = parseNotificationId(eventId);

    final reminderTime = startsAt.subtract(Duration(minutes: remindAt));
    final convertedReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      "Etkinliğiniz yaklaşıyor",
      '"$eventName" adlı etkinliğinize $remindAt dakika kaldı.',
      convertedReminderTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification({required String eventId}) async {
    if (_initialized) return;

    final int id = parseNotificationId(eventId);

    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (_initialized) return [];

    try {
      return await _flutterLocalNotificationsPlugin.getActiveNotifications();
    } on UnimplementedError {
      return [];
    }
  }
}
