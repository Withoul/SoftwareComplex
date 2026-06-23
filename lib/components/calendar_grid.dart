import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../utils/helpers.dart';

class CalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final List<String> studyDays;
  final String? complexExamDate;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final Function(String dateStr) onSelectDay;

  const CalendarGrid({
    Key? key,
    required this.year,
    required this.month,
    required this.studyDays,
    this.complexExamDate,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onSelectDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayNames = getDayNames();
    final daysInMonth = getDaysInMonth(year, month);
    final firstDay = getFirstDayOfMonth(year, month);
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    // Build the grid cells
    final List<Widget> dayCells = [];

    // Empty cells before the first day
    for (int i = 0; i < firstDay; i++) {
      dayCells.add(const SizedBox.shrink());
    }

    // Day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final dateStr = '$year-${(month + 1).toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final isToday = dateStr == todayStr;
      final isStudied = studyDays.contains(dateStr);
      final isExamDay = dateStr == complexExamDate;

      dayCells.add(
        GestureDetector(
          onTap: () => onSelectDay(dateStr),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isExamDay
                      ? const Color(0xFFE65100)
                      : (isToday ? AppColors.primary : Colors.transparent),
                ),
                child: Center(
                  child: isExamDay
                      ? const Icon(
                          Ionicons.flag,
                          size: 16.0,
                          color: AppColors.white,
                        )
                      : Text(
                          day.toString(),
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: (isToday || isExamDay) ? FontWeight.w700 : FontWeight.w400,
                            color: (isToday || isExamDay) ? AppColors.white : AppColors.textPrimary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 2.0),
              SizedBox(
                height: 12.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isStudied)
                      Container(
                        width: 6.0,
                        height: 6.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.calendarDot,
                        ),
                      ),
                    if (isExamDay) ...[
                      if (isStudied) const SizedBox(width: 2.0),
                      const Text(
                        'Exam',
                        style: TextStyle(
                          fontSize: 8.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: AppColors.outlineVariant, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calendario de\nEstudio',
                    style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${getMonthName(month)} $year',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onPrevMonth,
                    icon: const Icon(Ionicons.chevron_back),
                    iconSize: 20.0,
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: AppColors.outlineVariant, width: 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    onPressed: onNextMonth,
                    icon: const Icon(Ionicons.chevron_forward),
                    iconSize: 20.0,
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: AppColors.outlineVariant, width: 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          Row(
            children: dayNames.map((name) {
              return Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.9, // slight taller to hold day circle and studied dot comfortably
            ),
            itemCount: dayCells.length,
            itemBuilder: (context, index) {
              return dayCells[index];
            },
          ),
          const SizedBox(height: 16.0),
          const Divider(color: AppColors.surfaceContainerHigh),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.calendarDot,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    'Día estudiado',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    'Examen Complexivo',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
