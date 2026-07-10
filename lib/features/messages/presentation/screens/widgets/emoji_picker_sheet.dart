import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';

/// Represents a single emoji item with keywords for search filtering.
class EmojiItem {
  final String char;
  final List<String> keywords;

  const EmojiItem(this.char, this.keywords);
}

/// Helper method to display the custom emoji picker bottom sheet.
Future<String?> showEmojiPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const EmojiPickerSheet(),
  );
}

class EmojiPickerSheet extends StatefulWidget {
  const EmojiPickerSheet({super.key});

  @override
  State<EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<EmojiPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Smileys';

  static const Map<String, String> _categoryIcons = {
    'Smileys': '😀',
    'Hearts': '❤️',
    'Gestures': '👍',
    'Activities': '🎉',
    'Food & Animals': '🐱',
  };

  static final Map<String, List<EmojiItem>> _categorizedEmojis = {
    'Smileys': const [
      EmojiItem('😀', ['smile', 'happy', 'grin']),
      EmojiItem('😃', ['smile', 'happy', 'joy']),
      EmojiItem('😄', ['smile', 'happy', 'laugh']),
      EmojiItem('😁', ['grin', 'teeth', 'smile']),
      EmojiItem('😆', ['laugh', 'squint', 'haha', 'lol']),
      EmojiItem('😅', ['sweat', 'laugh', 'relief', 'cold sweat']),
      EmojiItem('😂', ['joy', 'tears', 'laugh', 'haha', 'lol']),
      EmojiItem('🤣', ['rofl', 'rolling', 'laugh', 'haha', 'lol']),
      EmojiItem('😊', ['blush', 'smile', 'proud', 'happy']),
      EmojiItem('😇', ['halo', 'angel', 'innocent']),
      EmojiItem('🙂', ['slight smile']),
      EmojiItem('🙃', ['upside down']),
      EmojiItem('😉', ['wink', 'flirt']),
      EmojiItem('😌', ['relieved', 'calm']),
      EmojiItem('😍', ['heart eyes', 'love', 'like']),
      EmojiItem('🥰', ['hearts', 'love', 'warm']),
      EmojiItem('😘', ['kiss', 'blow kiss', 'love']),
      EmojiItem('😗', ['kissing']),
      EmojiItem('😙', ['kissing smile']),
      EmojiItem('😚', ['kissing closed eyes']),
      EmojiItem('😋', ['yum', 'delicious', 'tongue', 'food']),
      EmojiItem('😛', ['tongue']),
      EmojiItem('😜', ['wink tongue', 'crazy', 'goofy']),
      EmojiItem('🤪', ['zany', 'goofy', 'wild', 'crazy']),
      EmojiItem('😝', ['squint tongue']),
      EmojiItem('🤑', ['money mouth', 'rich']),
      EmojiItem('🤗', ['hug', 'open hands']),
      EmojiItem('🤔', ['thinking', 'ponder', 'hmm']),
      EmojiItem('🤭', ['hand over mouth', 'giggle']),
      EmojiItem('🤫', ['shush', 'quiet', 'silent']),
      EmojiItem('🤥', ['lying', 'pinocchio']),
      EmojiItem('😶', ['no mouth', 'silent']),
      EmojiItem('😐', ['neutral', 'meh']),
      EmojiItem('😑', ['expressionless']),
      EmojiItem('😬', ['grimace', 'awkward']),
      EmojiItem('🙄', ['roll eyes', 'bored', 'meh']),
      EmojiItem('😏', ['smirk', 'sneaky']),
      EmojiItem('😣', ['persevere', 'struggle', 'hurt']),
      EmojiItem('😥', ['sad sweat', 'relief']),
      EmojiItem('😮', ['open mouth', 'surprise', 'wow']),
      EmojiItem('🤐', ['zipper mouth', 'secret']),
      EmojiItem('😯', ['hushed']),
      EmojiItem('😪', ['sleepy', 'tired']),
      EmojiItem('😫', ['tired', 'exhausted']),
      EmojiItem('🥱', ['yawn', 'bored']),
      EmojiItem('😴', ['sleeping', 'zzz', 'tired']),
      EmojiItem('🤤', ['drool']),
      EmojiItem('😒', ['unamused', 'unimpressed', 'meh']),
      EmojiItem('😓', ['cold sweat', 'stress']),
      EmojiItem('😔', ['pensive', 'sad']),
      EmojiItem('😕', ['confused']),
      EmojiItem('😲', ['astonished', 'shocked', 'wow']),
      EmojiItem('☹️', ['frown']),
      EmojiItem('🙁', ['slight frown']),
      EmojiItem('😖', ['confounded']),
      EmojiItem('😞', ['disappointed', 'sad']),
      EmojiItem('😟', ['worried', 'sad']),
      EmojiItem('😤', ['triumph', 'steam', 'angry']),
      EmojiItem('😢', ['cry', 'sad', 'tear']),
      EmojiItem('😭', ['sob', 'crying', 'sad']),
      EmojiItem('😦', ['frowning open mouth']),
      EmojiItem('😧', ['anguished']),
      EmojiItem('😨', ['fear', 'scared']),
      EmojiItem('😩', ['weary']),
      EmojiItem('🤯', ['mind blown', 'explode', 'shock']),
      EmojiItem('😰', ['anxious', 'sweat']),
      EmojiItem('😱', ['scream', 'scared', 'shock']),
      EmojiItem('🥵', ['hot', 'red', 'fever']),
      EmojiItem('🥶', ['cold', 'blue', 'freeze']),
      EmojiItem('😳', ['flushed', 'embarrassed']),
      EmojiItem('😵', ['dizzy', 'dead']),
      EmojiItem('🥴', ['woozy', 'drunk']),
      EmojiItem('😠', ['angry', 'mad']),
      EmojiItem('😡', ['rage', 'angry']),
      EmojiItem('🤬', ['cursing', 'swear', 'angry']),
      EmojiItem('😷', ['mask', 'sick']),
      EmojiItem('🤒', ['thermometer', 'sick']),
      EmojiItem('🤕', ['bandage', 'hurt', 'injury']),
      EmojiItem('🤢', ['nauseous', 'green', 'sick']),
      EmojiItem('🤮', ['vomit', 'puke', 'sick']),
      EmojiItem('🤧', ['sneeze', 'cold']),
      EmojiItem('🥳', ['party', 'celebrate']),
      EmojiItem('🥺', ['pleading', 'puppy eyes', 'sad']),
      EmojiItem('🤠', ['cowboy']),
      EmojiItem('🤡', ['clown']),
      EmojiItem('👻', ['ghost', 'spooky', 'halloween']),
      EmojiItem('💀', ['skull', 'dead', 'laugh']),
      EmojiItem('👽', ['alien']),
      EmojiItem('👾', ['monster', 'game']),
      EmojiItem('🤖', ['robot']),
      EmojiItem('💩', ['poop', 'shit']),
    ],
    'Hearts': const [
      EmojiItem('❤️', ['red heart', 'love', 'like']),
      EmojiItem('🧡', ['orange heart', 'love']),
      EmojiItem('💛', ['yellow heart', 'love']),
      EmojiItem('💚', ['green heart', 'love']),
      EmojiItem('💙', ['blue heart', 'love']),
      EmojiItem('💜', ['purple heart', 'love']),
      EmojiItem('🖤', ['black heart', 'love']),
      EmojiItem('🤍', ['white heart', 'love']),
      EmojiItem('🤎', ['brown heart', 'love']),
      EmojiItem('💔', ['broken heart', 'sad']),
      EmojiItem('❣️', ['heart exclamation']),
      EmojiItem('💕', ['two hearts', 'love']),
      EmojiItem('💞', ['revolving hearts', 'love']),
      EmojiItem('💓', ['beating heart', 'love']),
      EmojiItem('💗', ['growing heart', 'love']),
      EmojiItem('💖', ['sparkling heart', 'love']),
      EmojiItem('💘', ['arrow heart', 'love']),
      EmojiItem('💝', ['ribbon heart', 'love']),
      EmojiItem('💟', ['heart decoration']),
      EmojiItem('💌', ['love letter']),
      EmojiItem('💋', ['kiss mark', 'lips']),
    ],
    'Gestures': const [
      EmojiItem('👍', ['thumbs up', 'ok', 'yes', 'agree', 'like']),
      EmojiItem('👎', ['thumbs down', 'no', 'dislike']),
      EmojiItem('✊', ['raised fist', 'power']),
      EmojiItem('👊', ['fist bump']),
      EmojiItem('🤛', ['left fist']),
      EmojiItem('🤜', ['right fist']),
      EmojiItem('✌️', ['peace', 'victory']),
      EmojiItem('👌', ['ok hand', 'perfect']),
      EmojiItem('🤏', ['pinching']),
      EmojiItem('🤞', ['fingers crossed', 'hope']),
      EmojiItem('🤝', ['handshake', 'agree', 'deal']),
      EmojiItem('🙏', ['pray', 'hands', 'thank you', 'please']),
      EmojiItem('👏', ['clap', 'applaud', 'bravo']),
      EmojiItem('🙌', ['raising hands', 'celebrate', 'hooray']),
      EmojiItem('👐', ['open hands']),
      EmojiItem('🤲', ['palms up']),
      EmojiItem('💪', ['bicep', 'muscle', 'strength', 'strong']),
      EmojiItem('🧠', ['brain', 'smart', 'think']),
      EmojiItem('👀', ['eyes', 'look', 'see']),
      EmojiItem('🗣', ['speaking head']),
      EmojiItem('👤', ['silhouette']),
    ],
    'Activities': const [
      EmojiItem('🎉', ['tada', 'party', 'celebrate', 'congrats']),
      EmojiItem('🎊', ['confetti', 'party']),
      EmojiItem('🎈', ['balloon', 'party']),
      EmojiItem('🎁', ['gift', 'present', 'birthday']),
      EmojiItem('🎂', ['cake', 'birthday']),
      EmojiItem('✨', ['sparks', 'shine', 'magic', 'sparkles']),
      EmojiItem('⭐', ['star']),
      EmojiItem('🌟', ['glowing star']),
      EmojiItem('🔥', ['fire', 'hot', 'lit', 'cool']),
      EmojiItem('💥', ['collision', 'explosion', 'bam']),
      EmojiItem('💯', ['100', 'perfect', 'score']),
      EmojiItem('🚀', ['rocket', 'ship', 'space', 'launch']),
      EmojiItem('🌈', ['rainbow']),
      EmojiItem('☀️', ['sun', 'hot', 'weather']),
      EmojiItem('⚡', ['lightning', 'high voltage', 'electric']),
      EmojiItem('❄️', ['snowflake', 'cold', 'winter']),
      EmojiItem('🏆', ['trophy', 'win', 'prize']),
      EmojiItem('⚽', ['soccer', 'football', 'sport']),
      EmojiItem('🏀', ['basketball', 'sport']),
      EmojiItem('🏈', ['football', 'sport']),
      EmojiItem('🎮', ['game controller', 'play']),
      EmojiItem('🎯', ['bullseye', 'target', 'hit']),
      EmojiItem('🔮', ['crystal ball', 'magic']),
      EmojiItem('👑', ['crown', 'king', 'queen']),
    ],
    'Food & Animals': const [
      EmojiItem('🐶', ['dog', 'puppy', 'pet', 'animal']),
      EmojiItem('🐱', ['cat', 'kitten', 'pet', 'animal']),
      EmojiItem('🐭', ['mouse', 'animal']),
      EmojiItem('🐹', ['hamster', 'animal']),
      EmojiItem('🐰', ['rabbit', 'bunny', 'animal']),
      EmojiItem('🦊', ['fox', 'animal']),
      EmojiItem('🐻', ['bear', 'animal']),
      EmojiItem('🐼', ['panda', 'animal']),
      EmojiItem('🐨', ['koala', 'animal']),
      EmojiItem('🐯', ['tiger', 'animal']),
      EmojiItem('🦁', ['lion', 'animal']),
      EmojiItem('🐮', ['cow', 'animal']),
      EmojiItem('🐷', ['pig', 'animal']),
      EmojiItem('🐸', ['frog', 'animal']),
      EmojiItem('🐵', ['monkey', 'animal']),
      EmojiItem('🐔', ['chicken', 'animal']),
      EmojiItem('🐧', ['penguin', 'animal']),
      EmojiItem('🐦', ['bird', 'animal']),
      EmojiItem('🐺', ['wolf', 'animal']),
      EmojiItem('🐝', ['bee', 'bug', 'animal']),
      EmojiItem('🦋', ['butterfly', 'bug']),
      EmojiItem('🕷', ['spider', 'bug']),
      EmojiItem('🐙', ['octopus', 'sea', 'animal']),
      EmojiItem('🐬', ['dolphin', 'sea', 'animal']),
      EmojiItem('🐳', ['whale', 'sea', 'animal']),
      EmojiItem('🦈', ['shark', 'sea', 'animal']),
      EmojiItem('🐊', ['crocodile', 'animal']),
      EmojiItem('🐫', ['camel', 'animal']),
      EmojiItem('🐘', ['elephant', 'animal']),
      EmojiItem('🦒', ['giraffe', 'animal']),
      EmojiItem('🐎', ['horse', 'animal']),
      EmojiItem('🍕', ['pizza', 'food']),
      EmojiItem('🍔', ['burger', 'food']),
      EmojiItem('🍟', ['fries', 'food']),
      EmojiItem('🌭', ['hotdog', 'food']),
      EmojiItem('🍿', ['popcorn', 'food']),
      EmojiItem('🍩', ['donut', 'food']),
      EmojiItem('🍪', ['cookie', 'food']),
      EmojiItem('🍰', ['cake', 'food']),
      EmojiItem('🍫', ['chocolate', 'food']),
      EmojiItem('🍭', ['lollipop', 'food']),
      EmojiItem('🍦', ['icecream', 'food']),
      EmojiItem('🍎', ['apple', 'fruit', 'food']),
      EmojiItem('🍌', ['banana', 'fruit', 'food']),
      EmojiItem('🍉', ['watermelon', 'fruit', 'food']),
      EmojiItem('🍓', ['strawberry', 'fruit', 'food']),
      EmojiItem('🥑', ['avocado', 'food']),
      EmojiItem('🌶️', ['pepper', 'spicy', 'food']),
      EmojiItem('🌽', ['corn', 'food']),
      EmojiItem('🥕', ['carrot', 'food']),
      EmojiItem('🥩', ['meat', 'food']),
      EmojiItem('🍣', ['sushi', 'food']),
      EmojiItem('🍜', ['ramen', 'noodles', 'food']),
      EmojiItem('☕', ['coffee', 'drink']),
      EmojiItem('🍺', ['beer', 'drink']),
      EmojiItem('🍷', ['wine', 'drink']),
    ],
  };

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchCtrl.text.trim().toLowerCase();
    });
  }

  List<EmojiItem> _getFilteredEmojis() {
    if (_searchQuery.isEmpty) {
      return _categorizedEmojis[_selectedCategory] ?? const [];
    }

    final List<EmojiItem> results = [];
    for (final categoryList in _categorizedEmojis.values) {
      for (final item in categoryList) {
        if (item.keywords.any((kw) => kw.contains(_searchQuery))) {
          if (!results.any((ex) => ex.char == item.char)) {
            results.add(item);
          }
        }
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredEmojis();
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Container(
      height: 480 + bottomInset,
      decoration: const BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadii.xxl),
          topRight: Radius.circular(AppRadii.xxl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm + bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Search bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceInput,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.dividerDark),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search emoji...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: _searchCtrl.clear,
                    child: const Icon(
                      Icons.clear,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Category Bar (Only visible when search is empty)
          if (_searchQuery.isEmpty)
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _categoryIcons.entries.map((entry) {
                  final category = entry.key;
                  final icon = entry.value;
                  final isSelected = _selectedCategory == category;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),

          // Grid View of Emojis
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No emojis found',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                : GridView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: AppSpacing.xs,
                      mainAxisSpacing: AppSpacing.xs,
                    ),
                    itemBuilder: (context, index) {
                      final emoji = filtered[index].char;
                      return InkWell(
                        onTap: () => Navigator.of(context).pop(emoji),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
