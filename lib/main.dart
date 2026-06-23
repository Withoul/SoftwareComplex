import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:complex_flutter/screens/splash_screen.dart';
import 'package:complex_flutter/services/storage_service.dart';
import 'package:complex_flutter/theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  
  // Force portrait orientation
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    debugPrint("Error setting orientation: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _studyTimer;
  int _accumulatedSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startStudyTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopStudyTimer();
    super.dispose();
  }

  void _startStudyTimer() {
    if (_studyTimer != null) return;
    _studyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _accumulatedSeconds++;
      if (_accumulatedSeconds >= 10) {
        StorageService().addStudyTime(10);
        StorageService().markStudyDay(); // Mark study day on study activity
        _accumulatedSeconds = 0;
      }
    });
  }

  void _stopStudyTimer() {
    if (_studyTimer != null) {
      _studyTimer!.cancel();
      _studyTimer = null;
      if (_accumulatedSeconds > 0) {
        StorageService().addStudyTime(_accumulatedSeconds);
        StorageService().markStudyDay();
        _accumulatedSeconds = 0;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startStudyTimer();
    } else {
      _stopStudyTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimuladorComplex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.background,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
