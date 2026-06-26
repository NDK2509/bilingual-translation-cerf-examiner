import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_provider.dart';
import '../models/saved_word.dart';
import '../theme/app_colors.dart';
import 'flashcard_practice_screen.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _expandedWords = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpand(String word) {
    setState(() {
      if (_expandedWords.contains(word)) {
        _expandedWords.remove(word);
      } else {
        _expandedWords.add(word);
      }
    });
  }

  void _deleteWord(BuildContext context, VocabularyProvider provider, SavedWord word) async {
    final deletedWord = word;
    await provider.removeWord(word.word);

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${deletedWord.word}"', style: const TextStyle(color: AppColors.textPrimary)),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primary,
          onPressed: () {
            provider.saveWord(deletedWord);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vocabProvider = Provider.of<VocabularyProvider>(context);
    final allWords = vocabProvider.vocabulary;

    // Filter words by search query
    final filteredWords = allWords.where((w) {
      final query = _searchQuery.toLowerCase();
      return w.word.toLowerCase().contains(query) ||
          w.definition.toLowerCase().contains(query);
    }).toList();

    // Stats
    final totalWords = allWords.length;
    final masteredCount = allWords.where((w) => w.masteryLevel >= 100).length;
    final averageMastery = totalWords == 0
        ? 0.0
        : allWords.map((w) => w.masteryLevel).reduce((a, b) => a + b) / totalWords;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved Vocabulary', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (totalWords > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.textSecondary),
              tooltip: 'Clear All',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Clear Vocabulary?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    content: const Text('Are you sure you want to delete all saved words? This cannot be undone.', style: TextStyle(color: AppColors.textSecondary)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          vocabProvider.clearAll();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Clear All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
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
              Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppColors.bgGlow))),
              Column(
                children: [
                  // Header Stats Card (Glassmorphism style)
                  if (totalWords > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: Container(
                        decoration: AppColors.glassCardDecoration(color: AppColors.surface, radius: 20),
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn('Total Words', '$totalWords', AppColors.primary),
                            _buildStatColumn('Avg Mastery', '${averageMastery.toStringAsFixed(0)}%', AppColors.secondary),
                            _buildStatColumn('Mastered', '$masteredCount', AppColors.success),
                          ],
                        ),
                      ),
                    ),

                  // Search Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search words or translations...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                        fillColor: AppColors.surface,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),

                  // Word List or Empty State
                  Expanded(
                    child: filteredWords.isEmpty
                        ? _buildEmptyState(totalWords)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: filteredWords.length,
                            itemBuilder: (context, index) {
                              final word = filteredWords[index];
                              final isExpanded = _expandedWords.contains(word.word);

                              return Padding(
                                key: ValueKey(word.word),
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Dismissible(
                                  key: Key('dismiss_${word.word}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1.5),
                                    ),
                                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 28),
                                  ),
                                  onDismissed: (_) => _deleteWord(context, vocabProvider, word),
                                  child: Container(
                                    decoration: AppColors.glassCardDecoration(
                                      color: isExpanded ? AppColors.surfaceElevated : AppColors.surface,
                                      radius: 20,
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => _toggleExpand(word.word),
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Row 1: Word and Bookmark icon
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        word.word,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.textPrimary,
                                                        ),
                                                      ),
                                                      if (word.phonetic.isNotEmpty) ...[
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          word.phonetic,
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            fontStyle: FontStyle.italic,
                                                            color: AppColors.textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                // Mastery Indicator badge
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _getMasteryColor(word.masteryLevel).withOpacity(0.12),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: _getMasteryColor(word.masteryLevel).withOpacity(0.4),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Mastery: ${word.masteryLevel}%',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: _getMasteryColor(word.masteryLevel),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),

                                            // Definition
                                            Text(
                                              word.definition,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            // Mastery Progress Bar
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: word.masteryLevel / 100,
                                                backgroundColor: AppColors.border,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  _getMasteryColor(word.masteryLevel),
                                                ),
                                                minHeight: 4,
                                              ),
                                            ),

                                            // Expandable Context Details
                                            AnimatedCrossFade(
                                              firstChild: const SizedBox.shrink(),
                                              secondChild: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Divider(color: AppColors.border, height: 24),
                                                  const Text(
                                                    'Original Context Sentence:',
                                                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    word.context,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontStyle: FontStyle.italic,
                                                      color: AppColors.textPrimary,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                  if (word.contextExplanation.isNotEmpty) ...[
                                                    const SizedBox(height: 12),
                                                    const Text(
                                                      'Contextual Nuance (Giải thích):',
                                                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      word.contextExplanation,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        height: 1.4,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                  ]
                                                ],
                                              ),
                                              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                              duration: const Duration(milliseconds: 200),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Bottom Action Button (Glowing gradient)
                  if (filteredWords.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FlashcardPracticeScreen(),
                              ),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'PRACTICE FLASHCARDS',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(int totalWords) {
    final isSearching = _searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.border.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.menu_book_rounded,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'No Matching Words' : 'Your Vocabulary is Empty',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try searching with a different spelling or keyword.'
                  : 'Tap on words in the English challenge sentences to save definitions and review them here.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Back to Dashboard', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getMasteryColor(int level) {
    if (level >= 80) return AppColors.success;
    if (level >= 50) return AppColors.warning;
    return AppColors.primary;
  }
}
