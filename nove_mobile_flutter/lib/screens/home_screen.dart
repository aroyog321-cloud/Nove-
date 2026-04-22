import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../theme/tokens.dart';
// Note: Removed the floating_companion.dart import
import 'editor_screen.dart';

const _categories = ['All', 'Work', 'Ideas', 'Personal', 'Urgent', '★ Starred'];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notesProvider.notifier).loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      ref.read(notesProvider.notifier).loadNotes();
    } else {
      ref.read(notesProvider.notifier).search(query);
    }
  }

  void _openNote(Note note) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(note: note)),
    ).then((_) => ref.read(notesProvider.notifier).loadNotes());
  }

  void _createNote() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditorScreen()),
    ).then((_) => ref.read(notesProvider.notifier).loadNotes());
  }

  List<Note> _getFilteredNotes(List<Note> notes) {
    if (_selectedCategory == 'All') return notes;
    if (_selectedCategory == '★ Starred') {
      return notes.where((n) => n.isFavorite).toList();
    }
    return notes
        .where((n) =>
            (n.category ?? '').toLowerCase() ==
            _selectedCategory.toLowerCase())
        .toList();
  }

  Map<String, int> _getCategoryCounts(List<Note> notes) {
    final counts = <String, int>{};
    for (final cat in _categories) {
      if (cat == 'All') {
        counts[cat] = notes.length;
      } else if (cat == '★ Starred') {
        counts[cat] = notes.where((n) => n.isFavorite).length;
      } else {
        counts[cat] = notes
            .where((n) =>
                (n.category ?? '').toLowerCase() == cat.toLowerCase())
            .length;
      }
    }
    return counts;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesState = ref.watch(notesProvider);
    final filteredNotes = _getFilteredNotes(notesState.notes);
    final counts = _getCategoryCounts(notesState.notes);
    final totalNotes = notesState.notes.length;
    final pinnedNotes = notesState.notes.where((n) => n.isPinned).length;

    return Scaffold(
      backgroundColor: NoveColors.bg(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting + search toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getGreeting(),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: NoveColors.secondaryText(context),
                        ),
                      ),
                      Row(
                        children: [
                          _IconBtn(
                            icon: _isSearching
                                ? Icons.close_rounded
                                : Icons.search_rounded,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _isSearching = !_isSearching;
                                if (!_isSearching) {
                                  _searchController.clear();
                                  ref.read(notesProvider.notifier).loadNotes();
                                }
                              });
                            },
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _IconBtn(
                            icon: Icons.sort_rounded,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _showSortSheet(context);
                            },
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    'My Notes',
                    style: GoogleFonts.lora(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: NoveColors.primaryText(context),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Search bar (expandable) ─────────────────────────────
            AnimatedContainer(
              duration: NoveAnimation.fast,
              height: _isSearching ? 56 : 0,
              child: _isSearching
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: NoveColors.inputBg(context),
                          borderRadius: BorderRadius.circular(NoveRadii.lg),
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: _onSearch,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            color: NoveColors.primaryText(context),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search your notes...',
                            hintStyle: GoogleFonts.dmSans(
                              color: NoveColors.mutedText(context),
                            ),
                            prefixIcon: Icon(Icons.search,
                                color: NoveColors.mutedText(context)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // ── Stats row ──────────────────────────────────────────
            if (!_isSearching)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total notes',
                        value: '$totalNotes',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Pinned',
                        value: '$pinnedNotes',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Starred',
                        value:
                            '${notesState.notes.where((n) => n.isFavorite).length}',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            // ── Category Chips ─────────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final isActive = _selectedCategory == cat;
                  final count = counts[cat] ?? 0;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = cat);
                    },
                    child: AnimatedContainer(
                      duration: NoveAnimation.fast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? NoveColors.accent(context)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(NoveRadii.full),
                        border: isActive
                            ? null
                            : Border.all(
                                color: isDark
                                    ? NoveColors.darkBorder
                                    : NoveColors.warmGray300,
                                width: 0.5,
                              ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            cat,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.white
                                  : NoveColors.secondaryText(context),
                            ),
                          ),
                          if (count > 0 && !isActive) ...[
                            const SizedBox(width: 4),
                            Text(
                              '($count)',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: NoveColors.mutedText(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // ── Notes List ─────────────────────────────────────────
            Expanded(
              child: notesState.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: NoveColors.accent(context),
                        strokeWidth: 2,
                      ),
                    )
                  : filteredNotes.isEmpty
                      ? _EmptyState(
                          category: _selectedCategory,
                          onCreateNote: _createNote,
                          isDark: isDark,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                          itemCount: filteredNotes.length,
                          itemBuilder: (_, index) {
                            final note = filteredNotes[index];
                            return _NoteCard(
                              note: note,
                              isDark: isDark,
                              onTap: () => _openNote(note),
                              onDelete: () async {
                                HapticFeedback.mediumImpact();
                                await ref
                                    .read(notesProvider.notifier)
                                    .deleteNote(note.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Note deleted',
                                        style: GoogleFonts.dmSans(),
                                      ),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        textColor: NoveColors.amber,
                                        onPressed: () async {
                                          await ref
                                              .read(notesProvider.notifier)
                                              .createNote(note.content,
                                                  colorLabel:
                                                      note.colorLabel,
                                                  category: note.category);
                                        },
                                      ),
                                      duration:
                                          const Duration(seconds: 4),
                                    ),
                                  );
                                }
                              },
                              onPin: () async {
                                HapticFeedback.mediumImpact();
                                await ref
                                    .read(notesProvider.notifier)
                                    .togglePin(note.id);
                              },
                              onFavorite: () async {
                                HapticFeedback.lightImpact();
                                await ref
                                    .read(notesProvider.notifier)
                                    .toggleFavorite(note.id);
                              },
                              onColorChange: (color) async {
                                HapticFeedback.lightImpact();
                                await ref
                                    .read(notesProvider.notifier)
                                    .updateNote(note.id,
                                        colorLabel: color);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: NoveColors.terracotta.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _createNote,
          backgroundColor: NoveColors.accent(context),
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white, size: 24),
          label: Text(
            'New note',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: NoveColors.cardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: NoveColors.warmGray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sort notes',
              style: GoogleFonts.lora(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: NoveColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 16),
            for (final opt in [
              'Newest first',
              'Oldest first',
              'A → Z',
              'Most words',
            ])
              ListTile(
                title: Text(opt, style: GoogleFonts.dmSans(
                  color: NoveColors.primaryText(context),
                  fontWeight: FontWeight.w500,
                )),
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: NoveColors.cardBg(context),
        borderRadius: BorderRadius.circular(NoveRadii.sm),
        border: Border.all(
            color: NoveColors.cardBorder(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.lora(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: NoveColors.accent(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: NoveColors.mutedText(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Icon Button ─────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _IconBtn({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: NoveColors.cardBg(context),
          borderRadius: BorderRadius.circular(NoveRadii.full),
          border: Border.all(color: NoveColors.cardBorder(context), width: 0.5),
        ),
        child: Icon(icon, size: 18, color: NoveColors.secondaryText(context)),
      ),
    );
  }
}

// ─── Note Card ────────────────────────────────────────────────────────────────
class _NoteCard extends StatelessWidget {
  final Note note;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPin;
  final VoidCallback onFavorite;
  final ValueChanged<String> onColorChange;

  const _NoteCard({
    required this.note,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
    required this.onPin,
    required this.onFavorite,
    required this.onColorChange,
  });

  Color _parseBorderColor(BuildContext context) {
    try {
      if (note.colorLabel == '#FFFFFF' || note.colorLabel.isEmpty) {
        return NoveColors.terracotta;
      }
      return Color(int.parse(note.colorLabel.replaceFirst('#', '0xFF')));
    } catch (_) {
      return NoveColors.terracotta;
    }
  }

  String _timeLabel() {
    final now = DateTime.now();
    final updated = DateTime.fromMillisecondsSinceEpoch(note.updatedAt);
    final diff = now.difference(updated);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(updated);
  }

  void _showContextMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: NoveColors.cardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NoveColors.warmGray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: NoveColors.bg(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title.isNotEmpty ? note.title : 'Untitled',
                        style: GoogleFonts.lora(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: NoveColors.primaryText(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.isPinned)
                      const Icon(Icons.push_pin,
                          size: 14, color: NoveColors.terracotta),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _ContextAction(
                icon: Icons.edit_outlined,
                label: 'Edit note',
                onTap: () {
                  Navigator.pop(context);
                  onTap();
                },
              ),
              _ContextAction(
                icon: note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                label: note.isPinned ? 'Unpin note' : 'Pin note',
                onTap: () {
                  Navigator.pop(context);
                  onPin();
                },
              ),
              _ContextAction(
                icon: note.isFavorite ? Icons.star : Icons.star_outline,
                label: note.isFavorite ? 'Remove from starred' : 'Add to starred',
                onTap: () {
                  Navigator.pop(context);
                  onFavorite();
                },
              ),
              // Color picker row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.palette_outlined,
                        size: 20, color: NoveColors.secondaryText(context)),
                    const SizedBox(width: 12),
                    Text(
                      'Color label',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: NoveColors.primaryText(context),
                      ),
                    ),
                    const Spacer(),
                    for (final c in [
                      '#C0452A',
                      '#F5C842',
                      '#5DCAA5',
                      '#85B7EB',
                      '#ED93B1',
                      '#FFFFFF',
                    ])
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          onColorChange(c);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 6),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: c == '#FFFFFF'
                                ? Colors.transparent
                                : Color(int.parse(
                                    c.replaceFirst('#', '0xFF'))),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: note.colorLabel == c
                                  ? NoveColors.terracotta
                                  : NoveColors.warmGray300,
                              width: note.colorLabel == c ? 2.5 : 1,
                            ),
                          ),
                          child: c == '#FFFFFF'
                              ? const Icon(Icons.block,
                                  size: 12, color: NoveColors.warmGray400)
                              : null,
                        ),
                      ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              _ContextAction(
                icon: Icons.share_outlined,
                label: 'Share note',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _ContextAction(
                icon: Icons.delete_outline,
                label: 'Delete note',
                color: NoveColors.error,
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _parseBorderColor(context);
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: NoveColors.error,
          borderRadius: BorderRadius.circular(NoveRadii.lg),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 22),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: NoveColors.cardBg(context),
            borderRadius: BorderRadius.circular(NoveRadii.lg),
            border: Border.all(
                color: NoveColors.cardBorder(context), width: 0.5),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Color bar
                Container(
                  width: 4,
                  constraints: const BoxConstraints(minHeight: 80),
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(NoveRadii.lg),
                      bottomLeft: Radius.circular(NoveRadii.lg),
                    ),
                  ),
                ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if ((note.category ?? '').isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: borderColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                note.category!.toUpperCase(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: borderColor,
                                  letterSpacing: 1,
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          Text(
                            _timeLabel(),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: NoveColors.mutedText(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        note.title.isNotEmpty ? note.title : 'Untitled',
                        style: GoogleFonts.lora(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: NoveColors.primaryText(context),
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Preview
                      Text(
                        note.content.isNotEmpty ? note.content : ' ',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: NoveColors.secondaryText(context),
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Footer
                      Row(
                        children: [
                          if (note.isPinned)
                            Icon(Icons.push_pin_rounded,
                                size: 13,
                                color: NoveColors.accent(context)),
                          if (note.isFavorite)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.star_rounded,
                                  size: 13, color: NoveColors.amber),
                            ),
                          const Spacer(),
                          if (note.wordCount > 0)
                            Text(
                              note.readTimeMinutes > 0
                                  ? '${note.wordCount} words · ${note.readTimeMinutes.ceil()} min'
                                  : '${note.wordCount} words',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: NoveColors.mutedText(context),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Context Menu Action ──────────────────────────────────────────────────────
class _ContextAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ContextAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? NoveColors.primaryText(context);
    return ListTile(
      leading: Icon(icon, size: 20, color: c),
      title: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          color: c,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String category;
  final VoidCallback onCreateNote;
  final bool isDark;

  const _EmptyState({
    required this.category,
    required this.onCreateNote,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? NoveColors.cardDark
                  : NoveColors.warmGray100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              category == '★ Starred'
                  ? Icons.star_outline
                  : Icons.edit_note_rounded,
              size: 36,
              color: NoveColors.warmGray400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            category == 'All'
                ? 'Your first note is\none tap away.'
                : 'No notes in "$category" yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: NoveColors.primaryText(context),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + below to create one.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: NoveColors.mutedText(context),
            ),
          ),
        ],
      ),
    );
  }
}