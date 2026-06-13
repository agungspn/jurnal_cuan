import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../models/alarm_model.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();

  factory AlarmService() => _instance;
  AlarmService._internal();

  static const String _prefsKey = 'jurnal_cuan_alarms';

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ──────────────────────────────────────────────
  // INISIALISASI
  // ──────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    // Inisialisasi timezone
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Konfigurasi Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Minta izin notifikasi (Android 13+)
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notifikasi di-tap: ${response.payload}');
  }

  // ──────────────────────────────────────────────
  // SCHEDULE NOTIFICATION (HARIAN BERULANG)
  // ──────────────────────────────────────────────

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    if (!alarm.isEnabled) return;

    final tz.TZDateTime scheduledTime = _nextInstanceOfTime(
      alarm.hour,
      alarm.minute,
    );

    // ✅ Gunakan 'final' bukan 'const' karena ada nilai dinamis (alarm.title)
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'trading_alarm_channel',
      'Pengingat Trading',
      channelDescription: 'Notifikasi pengingat sesi trading harian',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        'Saatnya melakukan review jurnal trading.',
        htmlFormatBigText: false,
        contentTitle: '🔔 ${alarm.title}',
        htmlFormatContentTitle: false,
      ),
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      alarm.id,
      '🔔 ${alarm.title}',
      'Saatnya melakukan review jurnal trading.',
      scheduledTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: alarm.id.toString(),
    );

    debugPrint(
      'Alarm dijadwalkan: ${alarm.title} → '
      '${alarm.hour.toString().padLeft(2, '0')}:'
      '${alarm.minute.toString().padLeft(2, '0')} setiap hari',
    );
  }

  /// Hitung waktu berikutnya dari jam & menit yang diberikan
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // Jika waktu sudah lewat hari ini, jadwalkan besok
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ──────────────────────────────────────────────
  // CANCEL NOTIFICATION
  // ──────────────────────────────────────────────

  Future<void> cancelAlarm(int id) async {
    await _notificationsPlugin.cancel(id);
    debugPrint('Alarm dibatalkan: id=$id');
  }

  Future<void> cancelAllAlarms() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('Semua alarm dibatalkan');
  }

  // ──────────────────────────────────────────────
  // SHARED PREFERENCES — SIMPAN & MUAT ALARM
  // ──────────────────────────────────────────────

  Future<void> saveAlarms(List<AlarmModel> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = alarms.map((a) => a.toJson()).toList();
    await prefs.setStringList(_prefsKey, encoded);
  }

  Future<List<AlarmModel>> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey);
    if (raw == null || raw.isEmpty) return _defaultAlarms();
    return raw.map((s) => AlarmModel.fromJson(s)).toList();
  }

  /// Alarm default saat pertama kali buka
  List<AlarmModel> _defaultAlarms() {
    return [
      AlarmModel(
        id: 1,
        title: 'Sesi London Buka',
        hour: 14,
        minute: 0,
        isEnabled: true,
      ),
      AlarmModel(
        id: 2,
        title: 'Sesi New York Buka',
        hour: 19,
        minute: 30,
        isEnabled: true,
      ),
      AlarmModel(
        id: 3,
        title: 'Review Jurnal Harian',
        hour: 21,
        minute: 0,
        isEnabled: false,
      ),
      AlarmModel(
        id: 4,
        title: 'Sesi Asia Buka',
        hour: 7,
        minute: 0,
        isEnabled: false,
      ),
    ];
  }

  // ──────────────────────────────────────────────
  // HELPER — Generate ID unik berdasarkan timestamp
  // ──────────────────────────────────────────────

  int generateId() {
    return DateTime.now().millisecondsSinceEpoch % 100000;
  }

  /// Re-schedule semua alarm aktif saat app restart
  Future<void> rescheduleActiveAlarms(List<AlarmModel> alarms) async {
    for (final alarm in alarms) {
      if (alarm.isEnabled) {
        await scheduleAlarm(alarm);
      }
    }
  }
}