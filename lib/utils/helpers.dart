import 'dart:math';
import '../models/question.dart';

// Fisher-Yates shuffle
List<T> shuffleArray<T>(List<T> array) {
  final shuffled = List<T>.from(array);
  final random = Random();
  for (int i = shuffled.length - 1; i > 0; i--) {
    final j = random.nextInt(i + 1);
    final temp = shuffled[i];
    shuffled[i] = shuffled[j];
    shuffled[j] = temp;
  }
  return shuffled;
}

List<Question> selectRandomQuestions(List<Question> questions, int count, List<int> seenQuestionIds) {
  final n = min(count, questions.length);

  // Separate unseen and seen questions
  final unseen = questions.where((q) => !seenQuestionIds.contains(q.id)).toList();
  final seen = questions.where((q) => seenQuestionIds.contains(q.id)).toList();

  // Shuffle both subsets
  final shuffledUnseen = shuffleArray(unseen);
  final shuffledSeen = shuffleArray(seen);

  // Merge, putting unseen first
  final merged = [...shuffledUnseen, ...shuffledSeen];

  return merged.sublist(0, n);
}

class PreparedQuestion {
  final Question question;
  final List<String> shuffledOptions;
  final int correctIndex;

  PreparedQuestion({
    required this.question,
    required this.shuffledOptions,
    required this.correctIndex,
  });
}

PreparedQuestion prepareQuestion(Question question) {
  final shuffledOptions = shuffleArray(question.opciones);
  final correctIndex = shuffledOptions.indexOf(question.respuestaCorrecta);
  return PreparedQuestion(
    question: question,
    shuffledOptions: shuffledOptions,
    correctIndex: correctIndex,
  );
}

String formatTime(int seconds) {
  final mins = seconds ~/ 60;
  final secs = seconds % 60;
  return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

String getMonthName(int month) {
  final months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
  return months[month];
}

List<String> getDayNames() {
  return ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
}

int getDaysInMonth(int year, int month) {
  // Dart DateTime month is 1-indexed. So month index 0 (Enero) is 1.
  // Next month (month + 2) day 0 gets the last day of this month
  return DateTime(year, month + 2, 0).day;
}

int getFirstDayOfMonth(int year, int month) {
  // weekday: Monday = 1, Sunday = 7
  final weekday = DateTime(year, month + 1, 1).weekday;
  return weekday - 1; // Monday = 0, Sunday = 6
}
