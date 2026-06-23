import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/calendar_grid.dart';
import '../components/progress_bar.dart';
import '../services/storage_service.dart';
import '../utils/helpers.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final StorageService _storageService = StorageService();

  late int _year;
  late int _month;

  List<String> _studyDays = [];
  int _currentStreak = 0;
  String? _complexExamDate;
  String _hoursStudied = '0.0';

  final List<String> _motivationalQuotes = [
    '"La persistencia es el camino al éxito."',
    '"El conocimiento es poder."',
    '"Cada día es una nueva oportunidad de aprender."',
    '"La disciplina es el puente entre metas y logros."',
    '"No cuentes los días, haz que los días cuenten."',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month - 1; // 0-indexed month (0 = Enero, 11 = Diciembre)
    _loadData();
  }

  Future<void> _loadData() async {
    final days = await _storageService.getStudyDays();
    final streak = await _storageService.getCurrentStreak();
    final examDate = await _storageService.getComplexExamDate();
    final timeData = await _storageService.getStudyTime();

    // Calculate active study time for current displayed month/year
    int secondsThisMonth = 0;
    timeData.forEach((dateStr, sec) {
      try {
        final parts = dateStr.split('-');
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        if (y == _year && (m - 1) == _month) {
          secondsThisMonth += sec;
        }
      } catch (_) {}
    });

    final hours = (secondsThisMonth / 3600.0).toStringAsFixed(1);

    if (mounted) {
      setState(() {
        _studyDays = days;
        _currentStreak = streak;
        _complexExamDate = examDate;
        _hoursStudied = hours;
      });
    }
  }

  void _handlePrevMonth() {
    setState(() {
      if (_month == 0) {
        _month = 11;
        _year--;
      } else {
        _month--;
      }
    });
    _loadData();
  }

  void _handleNextMonth() {
    setState(() {
      if (_month == 11) {
        _month = 0;
        _year++;
      } else {
        _month++;
      }
    });
    _loadData();
  }

  void _handleSelectDay(String dateStr) {
    final isExam = dateStr == _complexExamDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isExam ? 'Quitar Marcador' : 'Marcar Examen Complexivo'),
          content: Text(
            isExam
                ? '¿Deseas quitar el marcador de Examen Complexivo para el $dateStr?'
                : '¿Deseas marcar el día $dateStr como la fecha de tu Examen Complexivo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                final newDate = isExam ? null : dateStr;
                await _storageService.saveComplexExamDate(newDate);
                if (mounted) {
                  Navigator.of(context).pop();
                }
                _loadData();
              },
              child: const Text('Aceptar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  String? _getExamCountdown() {
    if (_complexExamDate == null) return null;
    try {
      final exam = DateTime.parse(_complexExamDate!);
      final today = DateTime.now();

      final examClear = DateTime(exam.year, exam.month, exam.day);
      final todayClear = DateTime(today.year, today.month, today.day);

      final diffDays = examClear.difference(todayClear).inDays;

      if (diffDays == 0) {
        return '🏁 ¡Es HOY! Mucha suerte en tu Examen Complexivo.';
      } else if (diffDays < 0) {
        return 'El Examen Complexivo fue hace ${diffDays.abs()} día(s).';
      } else {
        return '🎯 Faltan $diffDays día(s) para tu Examen Complexivo.';
      }
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysThisMonth = _studyDays.where((d) {
      try {
        final parts = d.split('-');
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        return y == _year && (m - 1) == _month;
      } catch (_) {
        return false;
      }
    }).length;

    const monthGoal = 20;
    final progress = daysThisMonth / monthGoal;
    final quote = _motivationalQuotes[_month % _motivationalQuotes.length];
    final countdownText = _getExamCountdown();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 30.0, 24.0, 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CalendarGrid(
                year: _year,
                month: _month,
                studyDays: _studyDays,
                complexExamDate: _complexExamDate,
                onPrevMonth: _handlePrevMonth,
                onNextMonth: _handleNextMonth,
                onSelectDay: _handleSelectDay,
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _complexExamDate != null ? const Color(0xFFE65100) : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: _complexExamDate != null ? const Color(0xFFD84315) : AppColors.outlineVariant,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _complexExamDate != null ? Ionicons.bookmark : Ionicons.information_circle_outline,
                      size: 22.0,
                      color: _complexExamDate != null ? AppColors.white : AppColors.textPrimary,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        countdownText ??
                            'Toca un día en el calendario para marcar tu fecha de Examen Complexivo.',
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: _complexExamDate != null ? FontWeight.w600 : FontWeight.w500,
                          color: _complexExamDate != null ? AppColors.white : AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'MÉTRICAS DE ${getMonthName(_month).toUpperCase()}',
                      style: AppTypography.labelSm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.inversePrimary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                daysThisMonth.toString(),
                                style: AppTypography.headlineLg.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                  fontSize: 38.0,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Días estudiados',
                                style: AppTypography.bodySm.copyWith(color: AppColors.inversePrimary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1.0,
                          height: 40.0,
                          color: AppColors.white.withOpacity(0.15),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${_hoursStudied}h',
                                style: AppTypography.headlineLg.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                  fontSize: 38.0,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Tiempo total',
                                style: AppTypography.bodySm.copyWith(color: AppColors.inversePrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Ionicons.flame,
                            size: 24.0,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_currentStreak días consecutivos',
                                style: AppTypography.bodyMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                'Racha actual de estudio',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.inversePrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meta mensual: $monthGoal días',
                          style: AppTypography.bodySm.copyWith(color: AppColors.inversePrimary),
                        ),
                        Text(
                          '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    ProgressBar(
                      progress: progress,
                      height: 8.0,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Center(
                  child: Text(
                    quote,
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
