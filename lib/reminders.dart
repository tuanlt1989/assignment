import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// One daily, inexact "time to study" notification. Android only.
class Reminders {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static const _id = 1;

  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Keep UTC if the device zone is unknown; the reminder just shifts.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_notify'),
      ),
    );
    _ready = true;
  }

  /// Asks for the Android 13+ notification permission. True if granted.
  /// Never throws: reminders are a nice-to-have and must not block the UI.
  static Future<bool> requestPermission() async {
    if (!supported) return false;
    try {
      return await _requestPermission();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _requestPermission() async {
    await _init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  static Future<void> scheduleDaily({
    required int minutesOfDay,
    required String title,
    required String body,
  }) async {
    if (!supported) return;
    try {
      await _scheduleDaily(minutesOfDay, title, body);
    } catch (_) {
      // Ignore: e.g. plugin unavailable in tests.
    }
  }

  static Future<void> _scheduleDaily(
    int minutesOfDay,
    String title,
    String body,
  ) async {
    await _init();
    await _plugin.cancel(id: _id);
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutesOfDay ~/ 60,
      minutesOfDay % 60,
    );
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: _id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_study',
          'Daily study reminder',
          channelDescription: 'A daily reminder to keep your study streak.',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancel() async {
    if (!supported) return;
    try {
      await _init();
      await _plugin.cancel(id: _id);
    } catch (_) {
      // Ignore.
    }
  }
}
