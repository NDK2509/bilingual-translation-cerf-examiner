import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';

class TopicItem {
  final String label;
  final String englishValue;
  final IconData icon;
  final Color color;

  const TopicItem({
    required this.label,
    required this.englishValue,
    required this.icon,
    required this.color,
  });
}

const List<TopicItem> _commonTopics = [
  TopicItem(
    label: 'Any Topic',
    englishValue: '',
    icon: Icons.auto_awesome_rounded,
    color: AppColors.primary,
  ),
  TopicItem(
    label: 'Travel & Tourism',
    englishValue: 'Travel & Tourism',
    icon: Icons.flight_takeoff_rounded,
    color: Color(0xFF38BDF8),
  ),
  TopicItem(
    label: 'Business & Career',
    englishValue: 'Business & Career',
    icon: Icons.business_center_rounded,
    color: Color(0xFF34D399),
  ),
  TopicItem(
    label: 'Technology & AI',
    englishValue: 'Technology & AI',
    icon: Icons.computer_rounded,
    color: Color(0xFFA78BFA),
  ),
  TopicItem(
    label: 'Science & Nature',
    englishValue: 'Science & Nature',
    icon: Icons.eco_rounded,
    color: Color(0xFF4ADE80),
  ),
  TopicItem(
    label: 'Daily Life & Home',
    englishValue: 'Daily Life & Home',
    icon: Icons.home_rounded,
    color: Color(0xFFFB923C),
  ),
  TopicItem(
    label: 'Health & Fitness',
    englishValue: 'Health & Fitness',
    icon: Icons.favorite_rounded,
    color: Color(0xFFF87171),
  ),
  TopicItem(
    label: 'Arts & Entertainment',
    englishValue: 'Arts & Entertainment',
    icon: Icons.palette_rounded,
    color: Color(0xFFF472B6),
  ),
  TopicItem(
    label: 'Food & Cooking',
    englishValue: 'Food & Cooking',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFFBBF24),
  ),
  TopicItem(
    label: 'Politics & Society',
    englishValue: 'Politics & Society',
    icon: Icons.gavel_rounded,
    color: Color(0xFF94A3B8),
  ),
];

class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({super.key});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  final TextEditingController _customTopicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final currentTopic = settings.selectedTopic;
      if (currentTopic != null && currentTopic.isNotEmpty) {
        // Check if current topic is a pre-set common topic
        final exists = _commonTopics.any((t) => t.englishValue.toLowerCase() == currentTopic.toLowerCase());
        if (!exists) {
          _customTopicController.text = currentTopic;
        }
      }
    });
  }

  @override
  void dispose() {
    _customTopicController.dispose();
    super.dispose();
  }

  void _selectTopic(SettingsProvider settings, String topic) {
    settings.updateSelectedTopic(topic.isEmpty ? null : topic);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final currentTopic = settings.selectedTopic ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Choose Practice Topic',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(
                color: AppColors.border.withOpacity(0.3),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Custom Topic Input Field
                      const Text(
                        'Type a Custom Topic',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: AppColors.premiumCardDecoration(radius: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_note_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _customTopicController,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    _selectTopic(settings, value.trim());
                                  }
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'e.g., Space Travel, Climate Change, Chess...',
                                  hintStyle: TextStyle(
                                    color: AppColors.textSecondary.withOpacity(0.5),
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _customTopicController,
                              builder: (context, value, child) {
                                if (value.text.isEmpty) return const SizedBox.shrink();
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      onPressed: () => _customTopicController.clear(),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => _selectTopic(settings, value.text),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Apply',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Common Topics Title
                      const Text(
                        'Common Topics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grid of topics
                      Expanded(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: _commonTopics.length,
                          itemBuilder: (context, index) {
                            final topic = _commonTopics[index];
                            final isSelected = (topic.englishValue.isEmpty && currentTopic.isEmpty) ||
                                (topic.englishValue.isNotEmpty && currentTopic.toLowerCase() == topic.englishValue.toLowerCase());

                            return GestureDetector(
                              onTap: () => _selectTopic(settings, topic.englishValue),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [topic.color.withOpacity(0.25), topic.color.withOpacity(0.05)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [AppColors.surfaceElevated.withOpacity(0.6), AppColors.surface.withOpacity(0.7)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? topic.color
                                        : AppColors.borderLight.withOpacity(0.25),
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: topic.color.withOpacity(0.15),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(
                                            topic.icon,
                                            color: isSelected ? topic.color : AppColors.textSecondary,
                                            size: 24,
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: topic.color,
                                              size: 16,
                                            ),
                                        ],
                                      ),
                                      Text(
                                        topic.label,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
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
