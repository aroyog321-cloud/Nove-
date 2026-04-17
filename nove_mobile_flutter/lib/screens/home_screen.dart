import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../theme/tokens.dart';
import '../widgets/floating_companion.dart';
import 'editor_screen.dart';

const _categories = ['All', 'Work', 'Ideas', 'Personal', 'Urgent'];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

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
    ref.read(notesProvider.notifier).search(query);
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditorScreen(note: note)),
    ).then((_) => ref.read(notesProvider.notifier).loadNotes());
  }

  void _createNote() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditorScreen()),
    ).then((_) => ref.read(notesProvider.notifier).loadNotes());
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);

    // Apply category filter
    final filteredNotes = _selectedCategory == 'All'
        ? notesState.notes
        : notesState.notes
            .where((n) =>
                (n.category ?? '').toLowerCase() ==
                _selectedCategory.toLowerCase())
            .toList();

    return Scaffold(
      backgroundColor: NoveColors.cream,
      body: Stack(
        children: [
          // ── Main Content ──────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'NOVE',
                            style: NoveTypography.lora(
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: NoveColors.terracotta,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Text(
                            'PREMIUM WORKSPACE',
                            style: NoveTypography.dmsans(
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: NoveColors.warmGray500,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: NoveColors.warmGray200,
                        child: const Icon(Icons.person_outline,
                            color: NoveColors.warmGray500, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: NoveColors.warmGray200,
                      borderRadius: BorderRadius.circular(NoveRadii.lg),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      style: NoveTypography.dmsans(
                        style: const TextStyle(
                          fontSize: 15,
                          color: NoveColors.warmGray900,
                        ),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search your archives...',
                        hintStyle: TextStyle(
                          fontFamily: 'DMSans',
                          color: NoveColors.warmGray500,
                        ),
                        prefixIcon:
                            Icon(Icons.search, color: NoveColors.warmGray500),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Filter Chips
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final isActive = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? NoveColors.terracotta
                                : NoveColors.warmGray200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: NoveTypography.dmsans(
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? Colors.white
                                    : NoveColors.warmGray900,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Notes List
                Expanded(
                  child: notesState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: NoveColors.terracotta))
                      : filteredNotes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('✍️',
                                      style: TextStyle(fontSize: 56)),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No notes yet',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: NoveColors.warmGray900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap + to create your first note',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 14,
                                      color: NoveColors.warmGray500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                              itemCount: filteredNotes.length,
                              itemBuilder: (_, index) {
                                final note = filteredNotes[index];
                                return _NoteCard(
                                  note: note,
                                  onTap: () => _openNote(note),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),

          // ── Floating Companion ────────────────────────────────────────
          const FloatingCompanion(),
        ],
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
          backgroundColor: NoveColors.terracotta,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white, size: 28),
          label: const Text(
            'New Note',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Note Card ────────────────────────────────────────────────────────────────
class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const _NoteCard({required this.note, required this.onTap});

  Color _parseColor(String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return NoveColors.warmGray300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        (note.colorLabel == '#FFFFFF' || note.colorLabel.isEmpty)
            ? NoveColors.warmGray300
            : _parseColor(note.colorLabel);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: NoveColors.warmWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border(left: BorderSide(color: borderColor, width: 4)),
          boxShadow: NoveShadows.md,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category tag + time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if ((note.category ?? '').isNotEmpty)
                    Text(
                      '#${note.category!.toUpperCase()}',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: NoveColors.terracotta,
                        letterSpacing: 1.5,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Text(
                    DateFormat('MMM d').format(
                      DateTime.fromMillisecondsSinceEpoch(note.updatedAt),
                    ),
                    style: NoveTypography.dmsans(
                      style: const TextStyle(
                        fontSize: 12,
                        color: NoveColors.warmGray500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                note.title.isNotEmpty ? note.title : 'Untitled',
                style: NoveTypography.lora(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: NoveColors.warmGray900,
                  ),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Preview
              Text(
                note.content.isNotEmpty ? note.content : ' ',
                style: NoveTypography.dmsans(
                  style: const TextStyle(
                    fontSize: 14,
                    color: NoveColors.warmGray700,
                    height: 1.5,
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Footer
              Row(
                children: [
                  if (note.isPinned)
                    const Icon(Icons.push_pin,
                        size: 14, color: NoveColors.warmGray500),
                  if (note.isFavorite)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.star_outline,
                          size: 14, color: NoveColors.warmGray500),
                    ),
                  const Spacer(),
                  if (note.wordCount > 0)
                    Text(
                      '${note.wordCount} words',
                      style: NoveTypography.dmsans(
                        style: const TextStyle(
                          fontSize: 11,
                          color: NoveColors.warmGray400,
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
}
