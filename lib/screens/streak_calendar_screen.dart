import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_stats.dart';
import '../providers/translation_provider.dart';
import '../theme/app_colors.dart';

class StreakCalendarScreen extends StatefulWidget {
  const StreakCalendarScreen({super.key});

  @override
  State<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends State<StreakCalendarScreen> {
  late DateTime _displayedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  void _jumpToCurrentMonth() {
    final now = DateTime.now();
    setState(() {
      _displayedMonth = DateTime(now.year, now.month, 1);
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatDateString(DateTime dt) {
    return UserStats.formatDate(dt);
  }

  @override
  Widget build(BuildContext context) {
    final translation = Provider.of<TranslationProvider>(context);
    final stats = translation.stats;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isCurrentMonth = _displayedMonth.year == now.year &&
        _displayedMonth.month == now.month;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 24),
            SizedBox(width: 8),
            Text(
              'Streak Calendar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(
                color: AppColors.border.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.bgGlow,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- TOP HERO CARD ---
                    _buildHeroStreakCard(stats),

                    const SizedBox(height: 16),

                    // --- STATS 4-GRID ---
                    _buildQuickStatsGrid(stats),

                    const SizedBox(height: 20),

                    // --- MILESTONES ---
                    _buildMilestonesBar(stats),

                    const SizedBox(height: 24),

                    // --- CALENDAR CARD ---
                    _buildCalendarCard(stats, today, isCurrentMonth),

                    const SizedBox(height: 16),

                    // --- SELECTED DAY CARD ---
                    _buildSelectedDayCard(stats, today),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hero Card with Fire & Streak count
  Widget _buildHeroStreakCard(UserStats stats) {
    final activeStreak = stats.activeStreak;
    final hasPracticed = stats.hasPracticedToday;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB45309), Color(0xFFE11D48), Color(0xFF7C2D12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFEF4444)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$activeStreak',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Days',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hasPracticed
                      ? '🔥 Streak active for today! Great job!'
                      : (activeStreak > 0
                          ? '⚡ Practice today to keep your streak!'
                          : 'Start a new streak by practicing today!'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick Stats 4-Grid
  Widget _buildQuickStatsGrid(UserStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStat(
            label: 'Current Streak',
            value: '${stats.activeStreak}',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniStat(
            label: 'Best Record',
            value: '${stats.bestStreak}',
            icon: Icons.emoji_events_rounded,
            color: const Color(0xFFFBBF24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniStat(
            label: 'Total Days',
            value: '${stats.practiceDates.length}',
            icon: Icons.calendar_month_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: AppColors.premiumCardDecoration(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Streak Milestones
  Widget _buildMilestonesBar(UserStats stats) {
    final active = stats.activeStreak;
    final milestones = [
      {'days': 3, 'label': '3 Days', 'title': 'Spark'},
      {'days': 7, 'label': '7 Days', 'title': 'Blaze'},
      {'days': 14, 'label': '14 Days', 'title': 'Inferno'},
      {'days': 30, 'label': '30 Days', 'title': 'Legend'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.premiumCardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STREAK MILESTONES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: milestones.map((m) {
              final days = m['days'] as int;
              final isUnlocked = active >= days;

              return Column(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                          : AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isUnlocked
                            ? const Color(0xFFF59E0B)
                            : AppColors.border,
                        width: isUnlocked ? 2 : 1,
                      ),
                      boxShadow: isUnlocked
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        isUnlocked
                            ? Icons.local_fire_department_rounded
                            : Icons.lock_outline_rounded,
                        color: isUnlocked ? const Color(0xFFF59E0B) : AppColors.textMuted,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    m['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                  Text(
                    m['title'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      color: isUnlocked
                          ? const Color(0xFFF59E0B)
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Monthly Calendar Widget
  Widget _buildCalendarCard(
    UserStats stats,
    DateTime today,
    bool isCurrentMonth,
  ) {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;

    // Days in current displayed month
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Monday is 1, Sunday is 7 in Dart
    final weekdayOfFirst = firstDayOfMonth.weekday; // 1 to 7

    // Count how many days practiced this month
    int practicedInThisMonth = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      if (stats.hasPracticedOn(date)) {
        practicedInThisMonth++;
      }
    }

    return Container(
      decoration: AppColors.premiumCardDecoration(radius: 24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Month navigation header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                onPressed: _previousMonth,
              ),
              Row(
                children: [
                  Text(
                    '${_monthName(month)} $year',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (!isCurrentMonth) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _jumpToCurrentMonth,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                onPressed: _nextMonth,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Monthly consistency pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$practicedInThisMonth of $daysInMonth days',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '${((practicedInThisMonth / daysInMonth) * 100).toStringAsFixed(0)}% consistency',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Day of week headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WeekdayHeader('MON'),
              _WeekdayHeader('TUE'),
              _WeekdayHeader('WED'),
              _WeekdayHeader('THU'),
              _WeekdayHeader('FRI'),
              _WeekdayHeader('SAT'),
              _WeekdayHeader('SUN'),
            ],
          ),

          const SizedBox(height: 10),

          // Calendar Grid (6 rows max)
          _buildMonthGrid(
            year: year,
            month: month,
            daysInMonth: daysInMonth,
            startWeekday: weekdayOfFirst,
            stats: stats,
            today: today,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid({
    required int year,
    required int month,
    required int daysInMonth,
    required int startWeekday,
    required UserStats stats,
    required DateTime today,
  }) {
    final List<Widget> rows = [];
    int currentDay = 1;

    // Previous month filler days count
    final leadingBlanks = startWeekday - 1; // 0 for Mon, 6 for Sun
    final prevMonthDays = DateTime(year, month, 0).day;

    for (int row = 0; row < 6; row++) {
      final List<Widget> dayCells = [];

      for (int col = 0; col < 7; col++) {
        final cellIndex = row * 7 + col;

        if (cellIndex < leadingBlanks) {
          // Filler from previous month
          final prevDay = prevMonthDays - leadingBlanks + cellIndex + 1;
          dayCells.add(
            Expanded(
              child: _buildDimmedDayCell('$prevDay'),
            ),
          );
        } else if (currentDay <= daysInMonth) {
          final cellDate = DateTime(year, month, currentDay);
          final isToday = cellDate.year == today.year &&
              cellDate.month == today.month &&
              cellDate.day == today.day;
          final isSelected = cellDate.year == _selectedDay.year &&
              cellDate.month == _selectedDay.month &&
              cellDate.day == _selectedDay.day;
          final isPracticed = stats.hasPracticedOn(cellDate);
          final isFuture = cellDate.isAfter(today);

          dayCells.add(
            Expanded(
              child: _buildActiveDayCell(
                date: cellDate,
                dayNumber: currentDay,
                isToday: isToday,
                isSelected: isSelected,
                isPracticed: isPracticed,
                isFuture: isFuture,
              ),
            ),
          );
          currentDay++;
        } else {
          // Filler for next month
          final nextDay = currentDay - daysInMonth;
          dayCells.add(
            Expanded(
              child: _buildDimmedDayCell('$nextDay'),
            ),
          );
          currentDay++;
        }
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayCells,
          ),
        ),
      );

      if (currentDay > daysInMonth && row >= 3) {
        break;
      }
    }

    return Column(children: rows);
  }

  Widget _buildDimmedDayCell(String text) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveDayCell({
    required DateTime date,
    required int dayNumber,
    required bool isToday,
    required bool isSelected,
    required bool isPracticed,
    required bool isFuture,
  }) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDay = date;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isPracticed
                ? const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isPracticed
                ? null
                : (isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : (isToday ? AppColors.surfaceElevated : Colors.transparent)),
            border: Border.all(
              color: isToday
                  ? AppColors.primary
                  : (isSelected
                      ? AppColors.textSecondary
                      : Colors.transparent),
              width: isToday ? 2.0 : (isSelected ? 1.5 : 0),
            ),
            boxShadow: isPracticed
                ? [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$dayNumber',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: (isToday || isPracticed)
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isPracticed
                      ? Colors.white
                      : (isToday
                          ? AppColors.primary
                          : (isFuture
                              ? AppColors.textMuted
                              : AppColors.textPrimary)),
                ),
              ),
              if (isPracticed)
                Positioned(
                  bottom: 3,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Selected Day Details Card
  Widget _buildSelectedDayCard(UserStats stats, DateTime today) {
    final dateStr = _formatDateString(_selectedDay);
    final isPracticed = stats.hasPracticedOn(_selectedDay);
    final isToday = _selectedDay.year == today.year &&
        _selectedDay.month == today.month &&
        _selectedDay.day == today.day;
    final isFuture = _selectedDay.isAfter(today);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppColors.premiumCardDecoration(radius: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPracticed
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                  : AppColors.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPracticed
                  ? Icons.local_fire_department_rounded
                  : (isToday ? Icons.today_rounded : Icons.calendar_today_rounded),
              color: isPracticed
                  ? const Color(0xFFF59E0B)
                  : (isToday ? AppColors.primary : AppColors.textMuted),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'TODAY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isPracticed
                      ? '🔥 Practiced! Streak maintained on this date.'
                      : (isToday
                          ? 'Not practiced yet today. Do an exercise to keep your streak!'
                          : (isFuture
                              ? 'Upcoming day. Keep up your learning consistency!'
                              : 'No practice recorded on this day.')),
                  style: TextStyle(
                    fontSize: 11,
                    color: isPracticed
                        ? const Color(0xFFF59E0B)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isToday && !isPracticed)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Practice',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  final String text;
  const _WeekdayHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
