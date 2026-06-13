import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';
import 'services/alarm_service.dart'; // ✅ TAMBAHAN

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init (sudah ada sebelumnya)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ TAMBAHAN — Inisialisasi AlarmService
  final alarmService = AlarmService();
  await alarmService.init();

  // Re-schedule alarm aktif yang tersimpan agar tetap berjalan
  // setelah aplikasi restart
  final savedAlarms = await alarmService.loadAlarms();
  await alarmService.rescheduleActiveAlarms(savedAlarms);

    // Tambahkan ini
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const JurnalCuanApp());
}

class JurnalCuanApp extends StatelessWidget {
  const JurnalCuanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JurnalCuan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}