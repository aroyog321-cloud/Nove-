import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/tokens.dart';
import '../models/sticky_note.dart';
import '../providers/sticky_notes_provider.dart';

class StickyBoardScreen extends ConsumerStatefulWidget {
  const StickyBoardScreen({super.key});

  @override
  ConsumerState<StickyBoardScreen> createState() => _StickyBoardScreenState();
}

class _StickyBoardScreenState extends ConsumerState<StickyBoardScreen> {
  final _inputController = TextEditingController();
  StickyColor _selectedColor = StickyColor.yellow;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stickyNotesProvider.notifier).loadNotes();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addNote() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      ref.read(stickyNotesProvider.notifier).createNote(text, _selectedColor);
      _inputController.clear();
    }
  }

  void _deleteNote(String id) {
    ref.read(stickyNotesProvider.notifier).deleteNote(id);
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(stickyNotesProvider);

    final leftCol = <StickyNote>[];
    final rightCol = <StickyNote>[];
    for (int i = 0; i < notes.length; i++) {
      if (i % 2 == 0) {
        leftCol.add(notes[i]);
      } else {
        rightCol.add(notes[i]);
      }
    }

    return Scaffold(
      backgroundColor: NoveColors.cream,
      body: Stack(
        children: [
          // Dot Grid Background
          Positioned.fill(
            child: CustomPaint(
              painter: DotGridPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sticky Board',
                        style: NoveTypography.lora(
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: NoveColors.terracotta,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'VISUAL BRAINSTORMING ARENA',
                        style: NoveTypography.dmsans(
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: NoveColors.warmGray500,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Board
                Expanded(
                  child: notes.isEmpty
                      ? const Center(
                          child: Text(
                            'No sticky notes yet.\nAdd one below!',
                            textAlign: TextAlign.center,
                            style: NoveTypography.dmsans(
                              style: const TextStyle(
                                fontSize: 16,
                                color: NoveColors.warmGray500,
                              ),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: leftCol
                                      .map((n) => _StickyCard(
                                            note: n,
                                            onDelete: () => _deleteNote(n.id),
                                          ))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  children: rightCol
                                      .map((n) => _StickyCard(
                                            note: n,
                                            onDelete: () => _deleteNote(n.id),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Input Bar
      bottomSheet: _InputBar(
        controller: _inputController,
        selectedColor: _selectedColor,
        onColorChanged: (c) => setState(() => _selectedColor = c),
        onAdd: _addNote,
      ),
    );
  }
}

class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NoveColors.warmGray300.withOpacity(0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const double spacing = 32.0;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// ─── Sticky Card ─────────────────────────────────────────────────────────────
class _StickyCard extends StatelessWidget {
  final StickyNote note;
  final VoidCallback onDelete;

  const _StickyCard({required this.note, required this.onDelete});

  Color get _bgColor {
    switch (note.color) {
      case StickyColor.yellow:
        return const Color(0xFFF5C842);
      case StickyColor.pink:
        return const Color(0xFFF2C2D8);
      case StickyColor.green:
        return const Color(0xFFC5EDBE);
      case StickyColor.blue:
        return const Color(0xFFB3E5FC);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete sticky?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete();
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Transform.rotate(
        angle: (note.id.hashCode % 3 - 1) * 0.03,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      note.title,
                      style: NoveTypography.dmsans(
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C18),
                        ),
                      ),
                    ),
                  ),
                if (note.content.isNotEmpty)
                  Text(
                    note.content,
                    style: NoveTypography.caveat(
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.3,
                        color: Color(0xFF1C1C18),
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

// ─── Input Bar ────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final StickyColor selectedColor;
  final ValueChanged<StickyColor> onColorChanged;
  final VoidCallback onAdd;

  const _InputBar({
    required this.controller,
    required this.selectedColor,
    required this.onColorChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = {
      StickyColor.yellow: const Color(0xFFF5C842),
      StickyColor.pink: const Color(0xFFF2C2D8),
      StickyColor.green: const Color(0xFFC5EDBE),
      StickyColor.blue: const Color(0xFFB3E5FC),
    };

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E2DC).withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // Color Dots
          Row(
            children: colors.entries.map((e) {
              return GestureDetector(
                onTap: () => onColorChanged(e.key),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: e.value,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedColor == e.key
                          ? NoveColors.terracotta
                          : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 8),
          // Text Input
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontFamily: 'DMSans', fontSize: 14, color: Color(0xFF1C1C18)),
              decoration: const InputDecoration(
                hintText: 'Sticky note text...',
                hintStyle: TextStyle(color: Color(0x661C1C18)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (_) => onAdd(),
            ),
          ),
          const SizedBox(width: 8),
          // Add Button
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: NoveColors.terracotta,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
