import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../services/note_service.dart';
import '../theme/tokens.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final Note? note;

  const EditorScreen({super.key, this.note});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late TextEditingController _contentController;
  late bool _isPinned;
  late bool _isNewNote;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.note == null;
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _isPinned = widget.note?.isPinned ?? false;

    _contentController.addListener(() {
      setState(() {
        _hasChanges = true;
      });
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveAndClose() async {
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      if (!_isNewNote && widget.note != null) {
        await ref.read(notesProvider.notifier).deleteNote(widget.note!.id);
      }
      if (mounted) Navigator.pop(context);
      return;
    }

    if (_isNewNote) {
      await ref.read(notesProvider.notifier).createNote(content);
    } else if (_hasChanges && widget.note != null) {
      await NoteService.updateNote(
        widget.note!.id,
        content: content,
        isPinned: _isPinned,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  void _togglePin() {
    setState(() {
      _isPinned = !_isPinned;
      _hasChanges = true;
    });
  }

  int _getWordCount() {
    return _contentController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final content = _contentController.text;
    final wordCount = _getWordCount();
    final charCount = content.length;

    return Scaffold(
      backgroundColor: NoveColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: NoveColors.warmGray200, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  TextButton.icon(
                    onPressed: _saveAndClose,
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                      color: NoveColors.warmGray500,
                    ),
                    label: const Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 16,
                        color: NoveColors.warmGray500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  // Right Actions
                  Row(
                    children: [
                      // Pin Button
                      Container(
                        decoration: BoxDecoration(
                          color: _isPinned
                              ? NoveColors.warmGray200
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(NoveRadii.sm),
                        ),
                        child: IconButton(
                          onPressed: _togglePin,
                          icon: Icon(
                            Icons.push_pin,
                            size: 20,
                            color: _isPinned
                                ? NoveColors.warmGray900
                                : NoveColors.warmGray400,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Save/Publish Button
                      ElevatedButton(
                        onPressed: _saveAndClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NoveColors.terracotta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Publish',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Editor
            Expanded(
              child: Stack(
                children: [
                  // Ruled Lines
                  Positioned.fill(
                    child: CustomPaint(
                      painter: RuledBackgroundPainter(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      autofocus: _isNewNote,
                      textAlignVertical: TextAlignVertical.top,
                      cursorColor: NoveColors.terracotta,
                      style: const TextStyle(
                        fontFamily: 'Caveat',
                        fontSize: 26,
                        color: NoveColors.warmGray900,
                        height: 1.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Start writing your legacy...',
                        hintStyle: TextStyle(
                          fontFamily: 'Caveat',
                          fontSize: 26,
                          color: NoveColors.warmGray300,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: NoveColors.cream,
                border: Border(
                  top: BorderSide(color: NoveColors.warmGray200, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${wordCount.toString().padLeft(2, '0')} WORDS',
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: NoveColors.warmGray400,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(DateTime.now()).toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: NoveColors.warmGray400,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '${charCount.toString().padLeft(2, '0')} CHARS',
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: NoveColors.warmGray400,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RuledBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NoveColors.warmGray200.withOpacity(0.5)
      ..strokeWidth = 1;

    const double lineHeight = 39.0; // Matches Caveat 26 with height 1.5 (26 * 1.5 = 39)
    const double topOffset = 24.0 + 38.0; // contentPadding + first line adjustment

    for (double y = topOffset; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(24, y), Offset(size.width - 24, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

