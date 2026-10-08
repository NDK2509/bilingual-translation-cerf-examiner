import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/daily_mission.dart';
import '../providers/mission_provider.dart';
import '../widgets/choose_gift_dialog.dart';
import '../theme/app_colors.dart';

class MissionsRewardsScreen extends StatefulWidget {
  const MissionsRewardsScreen({super.key});

  @override
  State<MissionsRewardsScreen> createState() => _MissionsRewardsScreenState();
}

class _MissionsRewardsScreenState extends State<MissionsRewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _getMissionIcon(String key) {
    switch (key) {
      case 'translation':
        return Icons.translate_rounded;
      case 'cloze':
        return Icons.edit_note_rounded;
      case 'trophy':
        return Icons.emoji_events_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'bookmark':
        return Icons.bookmark_added_rounded;
      default:
        return Icons.military_tech_rounded;
    }
  }

  IconData _getGiftIcon(String iconKey) {
    switch (iconKey) {
      case 'coffee':
        return Icons.local_cafe_rounded;
      case 'gamepad':
        return Icons.sports_esports_rounded;
      case 'movie':
        return Icons.movie_creation_rounded;
      case 'pizza':
        return Icons.restaurant_rounded;
      case 'book':
        return Icons.auto_stories_rounded;
      case 'music':
        return Icons.headphones_rounded;
      case 'star':
        return Icons.star_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  void _showAddWishlistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Add Reward to Wishlist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What would you love to do as a reward when you reach 100 EXP?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'e.g. 1 hour of guilt-free YouTube',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Provider.of<MissionProvider>(context, listen: false)
                    .addCustomWishlist(text);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Add Reward', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context);

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
            Icon(Icons.card_giftcard_rounded, color: Color(0xFFF59E0B), size: 24),
            SizedBox(width: 8),
            Text(
              'Missions & Gifts',
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
              SafeArea(
                child: Column(
                  children: [
                    // --- HERO EXP STATUS CARD ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      child: _buildExpHeroCard(context, missionProvider),
                    ),

                    // --- TABS (Missions vs Claimed Gifts) ---
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: const Color(0xFF040711),
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        unselectedLabelStyle: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        splashFactory: NoSplash.splashFactory,
                        tabs: [
                          Tab(
                            height: 40,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Today's Missions (${missionProvider.dailyMissions.length})",
                              ),
                            ),
                          ),
                          Tab(
                            height: 40,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Gifts History (${missionProvider.claimedGifts.length})',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildMissionsTab(context, missionProvider),
                          _buildGiftsHistoryTab(context, missionProvider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hero Card with EXP progress & gift unlock button
  Widget _buildExpHeroCard(
    BuildContext context,
    MissionProvider missionProvider,
  ) {
    final exp = missionProvider.currentExp;
    final isFull = exp >= 100;
    final progress = (exp / 100.0).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFull
              ? [const Color(0xFFB45309), const Color(0xFFE11D48)]
              : [AppColors.surfaceElevated, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFull
              ? const Color(0xFFF59E0B)
              : AppColors.borderLight.withValues(alpha: 0.5),
          width: isFull ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFull ? const Color(0xFFF59E0B) : AppColors.primary)
                .withValues(alpha: isFull ? 0.35 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isFull
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: isFull ? Colors.white : const Color(0xFFF59E0B),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DAILY EXP GOAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$exp',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' / 100 EXP',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isFull)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '🎁 GIFT UNLOCKED!',
                    style: TextStyle(
                      color: Color(0xFFE11D48),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              else
                Text(
                  '${100 - exp} EXP to gift',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                isFull ? const Color(0xFFFBBF24) : AppColors.primary,
              ),
            ),
          ),

          if (isFull) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFB45309),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
                icon: const Icon(Icons.card_giftcard_rounded, size: 22),
                label: const Text(
                  'Choose What You Want To Do! 🎁',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                onPressed: () => ChooseGiftDialog.show(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- TAB 1: MISSIONS ---
  Widget _buildMissionsTab(
    BuildContext context,
    MissionProvider missionProvider,
  ) {
    final missions = missionProvider.dailyMissions;
    final unclaimedCount = missionProvider.unclaimedMissionsCount;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        if (unclaimedCount > 1) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF047857)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$unclaimedCount missions ready to claim!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF065F46),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final claimed = missionProvider.claimAllCompleted();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Claimed +$claimed EXP!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text(
                    'Claim All',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Missions List
        ...missions.map((m) => _buildMissionCard(context, m, missionProvider)),

        const SizedBox(height: 16),

        // Hint Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: const [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '3 missions reset daily at midnight. Reach 100 EXP to unlock your daily reward treat!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissionCard(
    BuildContext context,
    DailyMission mission,
    MissionProvider provider,
  ) {
    final isCompleted = mission.isCompleted;
    final isClaimed = mission.isClaimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: AppColors.premiumCardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isClaimed
                          ? AppColors.success
                          : (isCompleted
                              ? const Color(0xFFF59E0B)
                              : AppColors.primary))
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getMissionIcon(mission.iconKey),
                  color: isClaimed
                      ? AppColors.success
                      : (isCompleted
                          ? const Color(0xFFF59E0B)
                          : AppColors.primary),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      mission.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '+${mission.expReward} EXP',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress & Action Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${mission.current} / ${mission.target}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          isClaimed
                              ? 'Claimed'
                              : (isCompleted ? 'Ready!' : 'In progress'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isClaimed
                                ? AppColors.success
                                : (isCompleted
                                    ? const Color(0xFFF59E0B)
                                    : AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: mission.progressRatio,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceElevated,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isClaimed
                              ? AppColors.success
                              : (isCompleted
                                  ? const Color(0xFFF59E0B)
                                  : AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (isClaimed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_rounded, color: AppColors.success, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Done',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isCompleted)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final reward = provider.claimMissionExp(mission.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Claimed +$reward EXP!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text(
                    'Claim',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                )
              else
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
        ],
      ),
    );
  }

  // --- TAB 2: GIFTS HISTORY & WISHLIST ---
  Widget _buildGiftsHistoryTab(
    BuildContext context,
    MissionProvider missionProvider,
  ) {
    final gifts = missionProvider.claimedGifts;
    final wishlist = missionProvider.customWishlist;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Wishlist Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppColors.premiumCardDecoration(radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFEC4899),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'MY REWARD WISHLIST',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    onPressed: () => _showAddWishlistDialog(context),
                  ),
                ],
              ),
              if (wishlist.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No custom rewards yet. Tap + to add treats you want to earn!',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: wishlist.map((item) {
                    return Chip(
                      backgroundColor: AppColors.surfaceElevated,
                      label: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      deleteIcon: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      onDeleted: () => missionProvider.removeCustomWishlist(item),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'CLAIMED GIFTS LOG',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),

        if (gifts.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
            decoration: AppColors.premiumCardDecoration(radius: 20),
            child: Column(
              children: const [
                Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.textMuted,
                  size: 48,
                ),
                SizedBox(height: 14),
                Text(
                  'No Gifts Claimed Yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Complete 3 daily missions to earn 100 EXP and choose a reward you love!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...gifts.map((g) {
            String dateFormatted = g.claimedAt;
            try {
              final dt = DateTime.parse(g.claimedAt);
              dateFormatted =
                  '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            } catch (_) {}

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: AppColors.premiumCardDecoration(radius: 18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getGiftIcon(g.iconKey),
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Unlocked on $dateFormatted',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (g.customNote != null && g.customNote!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '"${g.customNote}"',
                            style: const TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
