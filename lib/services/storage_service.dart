import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageKeys {
  static const String userName = '@simulador_user_name';
  static const String studyDays = '@simulador_study_days';
  static const String currentStreak = '@simulador_current_streak';
  static const String bestStreak = '@simulador_best_streak';
  static const String pointsToday = '@simulador_points_today';
  static const String pointsDate = '@simulador_points_date';
  static const String totalAnswered = '@simulador_total_answered';
  static const String totalCorrect = '@simulador_total_correct';
  static const String questionHistory = '@simulador_question_history';
  static const String studyTime = '@simulador_study_time';
  static const String complexExamDate = '@simulador_complex_exam_date';
  static const String profileImage = '@simulador_profile_image';
  static const String quizHistory = '@simulador_quiz_history';
}

class StorageService {
  // Singleton Pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // User Name
  Future<void> saveUserName(String name) async {
    final p = await prefs;
    await p.setString(StorageKeys.userName, name);
  }

  Future<String?> getUserName() async {
    final p = await prefs;
    return p.getString(StorageKeys.userName);
  }

  // Study Days
  Future<List<String>> getStudyDays() async {
    final p = await prefs;
    final data = p.getString(StorageKeys.studyDays);
    if (data == null) return [];
    try {
      return List<String>.from(jsonDecode(data));
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> markStudyDay([String? date]) async {
    final p = await prefs;
    final today = date ?? DateTime.now().toIso8601String().split('T')[0];
    final days = await getStudyDays();
    if (!days.contains(today)) {
      days.add(today);
      await p.setString(StorageKeys.studyDays, jsonEncode(days));
    }
    return days;
  }

  // Streak
  Future<int> getCurrentStreak() async {
    final p = await prefs;
    final streak = p.getString(StorageKeys.currentStreak);
    return streak != null ? int.tryParse(streak) ?? 0 : 0;
  }

  Future<int> getBestStreak() async {
    final p = await prefs;
    final streak = p.getString(StorageKeys.bestStreak);
    return streak != null ? int.tryParse(streak) ?? 0 : 0;
  }

  Future<Map<String, int>> updateStreak() async {
    final days = await getStudyDays();
    if (days.isEmpty) return {'current': 0, 'best': 0};

    // Sort days
    final sorted = List<String>.from(days)..sort();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];

    int currentStreak = 0;
    if (sorted.contains(today) || sorted.contains(yesterday)) {
      currentStreak = 1;
      String checkDate = sorted.contains(today) ? today : yesterday;

      // Count backwards
      for (int i = 1; i < 365; i++) {
        final checkDateTime = DateTime.parse(checkDate).subtract(Duration(days: i));
        final prevDateStr = checkDateTime.toIso8601String().split('T')[0];
        if (sorted.contains(prevDateStr)) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    final p = await prefs;
    await p.setString(StorageKeys.currentStreak, currentStreak.toString());

    final best = await getBestStreak();
    if (currentStreak > best) {
      await p.setString(StorageKeys.bestStreak, currentStreak.toString());
    }

    return {
      'current': currentStreak,
      'best': currentStreak > best ? currentStreak : best,
    };
  }

  // Points Today
  Future<int> getPointsToday() async {
    final p = await prefs;
    final date = p.getString(StorageKeys.pointsDate);
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (date != today) {
      await p.setString(StorageKeys.pointsDate, today);
      await p.setString(StorageKeys.pointsToday, '0');
      return 0;
    }

    final points = p.getString(StorageKeys.pointsToday);
    return points != null ? int.tryParse(points) ?? 0 : 0;
  }

  Future<int> addPoints(int amount) async {
    final p = await prefs;
    final current = await getPointsToday();
    final newPoints = current + amount;
    final today = DateTime.now().toIso8601String().split('T')[0];
    await p.setString(StorageKeys.pointsDate, today);
    await p.setString(StorageKeys.pointsToday, newPoints.toString());
    return newPoints;
  }

  // Stats
  Future<Map<String, int>> getTotalStats() async {
    final p = await prefs;
    final answered = p.getString(StorageKeys.totalAnswered);
    final correct = p.getString(StorageKeys.totalCorrect);
    return {
      'totalAnswered': answered != null ? int.tryParse(answered) ?? 0 : 0,
      'totalCorrect': correct != null ? int.tryParse(correct) ?? 0 : 0,
    };
  }

  Future<Map<String, int>> addToStats(int answered, int correct) async {
    final p = await prefs;
    final stats = await getTotalStats();
    final newAnswered = stats['totalAnswered']! + answered;
    final newCorrect = stats['totalCorrect']! + correct;
    await p.setString(StorageKeys.totalAnswered, newAnswered.toString());
    await p.setString(StorageKeys.totalCorrect, newCorrect.toString());
    return {'totalAnswered': newAnswered, 'totalCorrect': newCorrect};
  }

  // Question History (saves last 10 attempts)
  Future<Map<int, List<bool>>> getQuestionHistory() async {
    final p = await prefs;
    final data = p.getString(StorageKeys.questionHistory);
    if (data == null) return {};
    try {
      final Map<String, dynamic> rawMap = jsonDecode(data);
      final Map<int, List<bool>> history = {};
      rawMap.forEach((key, value) {
        final qId = int.tryParse(key);
        if (qId != null) {
          history[qId] = List<bool>.from(value);
        }
      });
      return history;
    } catch (_) {
      return {};
    }
  }

  Future<Map<int, List<bool>>> recordQuestionAnswer(int questionId, bool isCorrect) async {
    final p = await prefs;
    final history = await getQuestionHistory();
    final qHistory = history[questionId] ?? [];
    qHistory.add(isCorrect);
    
    List<bool> updatedHistory;
    if (qHistory.length > 10) {
      updatedHistory = qHistory.sublist(qHistory.length - 10);
    } else {
      updatedHistory = qHistory;
    }
    history[questionId] = updatedHistory;

    // Convert back to JSON map
    final Map<String, dynamic> rawMap = {};
    history.forEach((key, value) {
      rawMap[key.toString()] = value;
    });

    await p.setString(StorageKeys.questionHistory, jsonEncode(rawMap));
    return history;
  }

  // Study Time (in seconds per day)
  Future<Map<String, int>> getStudyTime() async {
    final p = await prefs;
    final data = p.getString(StorageKeys.studyTime);
    if (data == null) return {};
    try {
      final Map<String, dynamic> raw = jsonDecode(data);
      return raw.map((key, value) => MapEntry(key, value as int));
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, int>> addStudyTime(int seconds) async {
    final p = await prefs;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final timeData = await getStudyTime();
    timeData[today] = (timeData[today] ?? 0) + seconds;
    await p.setString(StorageKeys.studyTime, jsonEncode(timeData));
    return timeData;
  }

  // Complex Exam Date
  Future<String?> getComplexExamDate() async {
    final p = await prefs;
    return p.getString(StorageKeys.complexExamDate);
  }

  Future<void> saveComplexExamDate(String? date) async {
    final p = await prefs;
    if (date != null) {
      await p.setString(StorageKeys.complexExamDate, date);
    } else {
      await p.remove(StorageKeys.complexExamDate);
    }
  }

  // Profile Image
  Future<String?> getProfileImage() async {
    final p = await prefs;
    return p.getString(StorageKeys.profileImage);
  }

  Future<void> saveProfileImage(String? imageUri) async {
    final p = await prefs;
    if (imageUri != null) {
      await p.setString(StorageKeys.profileImage, imageUri);
    } else {
      await p.remove(StorageKeys.profileImage);
    }
  }



  // Quiz History (saves last 20 attempts)
  Future<List<Map<String, dynamic>>> getQuizHistory() async {
    final p = await prefs;
    final data = p.getString(StorageKeys.quizHistory);
    if (data == null) return [];
    try {
      final List<dynamic> raw = jsonDecode(data);
      return raw.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveQuizHistory(List<Map<String, dynamic>> history) async {
    final p = await prefs;
    await p.setString(StorageKeys.quizHistory, jsonEncode(history));
  }

  Future<void> recordQuizAttempt(String mode, int score, int total, List<Map<String, dynamic>> questionsDetail) async {
    final history = await getQuizHistory();
    
    // Format date in Spanish: "29 de Mayo, 2026 - 16:43"
    final now = DateTime.now();
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final dateStr = "${now.day} de ${months[now.month - 1]}, ${now.year} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final entry = {
      'mode': mode,
      'score': score,
      'total': total,
      'date': dateStr,
      'questions': questionsDetail,
    };

    history.insert(0, entry);

    // Keep only last 20 attempts
    final updatedHistory = history.length > 20 ? history.sublist(0, 20) : history;
    await saveQuizHistory(updatedHistory);
  }
}
