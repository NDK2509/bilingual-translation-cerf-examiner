import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_mission.dart';
import '../providers/mission_provider.dart';
import '../theme/app_colors.dart';

class ChooseGiftDialog extends StatefulWidget {
  const ChooseGiftDialog({super.key});

  static Future<ClaimedGift?> show(BuildContext context) {
    return showModalBottomSheet<ClaimedGift>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ChooseGiftDialog(),
    );
  }

  @override
  State<ChooseGiftDialog> createState() => _ChooseGiftDialogState();
}

class _ChooseGiftDialogState extends State<ChooseGiftDialog> {
  String? _selectedOptionId;
  String _selectedTitle = '';
  String _selectedCategory = 'treat';
  String _selectedIconKey = 'coffee';

  final TextEditingController _customRewardController = TextEditingController();
  final TextEditingController _customNoteController = TextEditingController();
  bool _isCustomSelected = false;
  bool _saveToWishlist = true;

  @override
  void initState() {
    super.initState();
    // Default to the first option
    if (defaultRewardOptions.isNotEmpty) {
      _selectedOptionId = defaultRewardOptions.first.id;
      _selectedTitle = defaultRewardOptions.first.title;
      _selectedCategory = defaultRewardOptions.first.category;
      _selectedIconKey = defaultRewardOptions.first.iconKey;
    }
  }

  @override
  void dispose() {
    _customRewardController.dispose();
    _customNoteController.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconKey) {
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'treat':
        return const Color(0xFFF59E0B);
      case 'gaming':
        return const Color(0xFF8B5CF6);
      case 'entertainment':
        return const Color(0xFFEC4899);
      case 'food':
        return const Color(0xFFEF4444);
      case 'relax':
        return const Color(0xFF10B981);
      default:
        return AppColors.primary;
    }
  }

  void _onSelectPreset(RewardOption option) {
    setState(() {
      _selectedOptionId = option.id;
      _selectedTitle = option.title;
      _selectedCategory = option.category;
      _selectedIconKey = option.iconKey;
      _isCustomSelected = false;
    });
  }

  void _onSelectWishlistItem(String item) {
    setState(() {
      _selectedOptionId = 'wishlist_$item';
      _selectedTitle = item;
      _selectedCategory = 'custom';
      _selectedIconKey = 'star';
      _isCustomSelected = false;
    });
  }

  void _onSelectCustom() {
    setState(() {
      _isCustomSelected = true;
      _selectedOptionId = 'custom';
    });
  }

  void _claimReward(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context, listen: false);

    String finalTitle = _selectedTitle;
    String finalCategory = _selectedCategory;
    String finalIcon = _selectedIconKey;

    if (_isCustomSelected) {
      final customText = _customRewardController.text.trim();
      if (customText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please describe the reward you want to do!'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      finalTitle = customText;
      finalCategory = 'custom';
      finalIcon = 'gift';

      if (_saveToWishlist) {
        missionProvider.addCustomWishlist(customText);
      }
    }

    final note = _customNoteController.text.trim();

    final gift = missionProvider.claimGift(
      title: finalTitle,
      category: finalCategory,
      iconKey: finalIcon,
      customNote: note.isNotEmpty ? note : null,
    );

    Navigator.of(context).pop(gift);

    if (gift != null) {
      _showCelebrationDialog(context, gift);
    }
  }

  void _showCelebrationDialog(BuildContext context, ClaimedGift gift) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '🎉 Gift Claimed!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You unlocked your daily 100 EXP reward:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconData(gift.iconKey),
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        gift.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enjoy your well-deserved reward! Keep up the great work learning every day.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text(
                    'Awesome, I will do it!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1.5),
          left: BorderSide(color: AppColors.borderLight, width: 1),
          right: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Dialog Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.white,
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
                            const Text(
                              'Reward Yourself!',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                              child: const Text(
                                '100 EXP FULL',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Choose something you want to do as your gift:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.border, height: 1),

            // Scrollable Content
            Flexible(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Section: Preset Gifts
                  const Text(
                    'POPULAR REWARDS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...defaultRewardOptions.map((opt) {
                    final isSelected = !_isCustomSelected && _selectedOptionId == opt.id;
                    final catColor = _getCategoryColor(opt.category);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => _onSelectPreset(opt),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? catColor.withValues(alpha: 0.15)
                                : AppColors.surfaceElevated.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? catColor
                                  : AppColors.border.withValues(alpha: 0.5),
                              width: isSelected ? 1.8 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: catColor.withValues(alpha: 0.2),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getIconData(opt.iconKey),
                                  color: catColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      opt.description,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected
                                            ? AppColors.textPrimary.withValues(alpha: 0.8)
                                            : AppColors.textSecondary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected ? catColor : AppColors.textMuted,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // User Custom Wishlist if exists
                  if (missionProvider.customWishlist.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'YOUR PERSONAL WISHLIST',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...missionProvider.customWishlist.map((item) {
                      final isSelected = !_isCustomSelected &&
                          _selectedOptionId == 'wishlist_$item';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => _onSelectWishlistItem(item),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : AppColors.surfaceElevated.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 12),

                  // Option: Custom Reward
                  InkWell(
                    onTap: _onSelectCustom,
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isCustomSelected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.surfaceElevated.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isCustomSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: _isCustomSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.edit_note_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Custom Reward (Type your own)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'What do you really want to do today?',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _isCustomSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: _isCustomSelected
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                size: 22,
                              ),
                            ],
                          ),
                          if (_isCustomSelected) ...[
                            const SizedBox(height: 14),
                            TextField(
                              controller: _customRewardController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'e.g. Order bubble tea, Go for bike ride, Buy that book...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderLight,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Checkbox(
                                  value: _saveToWishlist,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) {
                                    setState(() {
                                      _saveToWishlist = val ?? true;
                                    });
                                  },
                                ),
                                const Text(
                                  'Save to my rewards wishlist for future',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                onPressed: () => _claimReward(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.card_giftcard_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Claim This Gift (Spend 100 EXP)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
