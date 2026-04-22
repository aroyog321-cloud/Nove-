import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../services/note_service.dart';
import '../theme/tokens.dart';

const _availableCategories = ['Work', 'Ideas', 'Personal', 'Urgent'];

const _colorLabels = [
  '#C0452A', // Terracotta
  '#F5C842', // Amber
  '#5DCAA5', // Teal
  '#85B7EB', // Blue
  '#ED93B1', // Pink
  '#FFFFFF', // None
];

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
  late String _selectedCategory;
  late String _selectedColor;
  bool _hasChanges = false;
  bool _isSaved = false;
  bool _focusMode = false;

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.note == null;
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _isPinned = widget.note?.isPinned ?? false;
    _selectedCategory = widget.note?.category ?? '';
    _selectedColor = widget.note?.colorLabel ?? '#FFFFFF';

    _contentController.addListener(() {
      setState(() {
        _hasChanges = true;
        _isSaved = false;
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
        // Show confirmation before deleting
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: NoveColors.cardBg(context),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Empty note',
              style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  color: NoveColors.primaryText(context)),
            ),
            content: Text(
              'This note is empty. Would you like to keep it or discard it?',
              style: GoogleFonts.dmSans(
                  color: NoveColors.secondaryText(context)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Keep',
                    style: GoogleFonts.dmSans(
                        color: NoveColors.accent(context),
                        fontWeight: FontWeight.w600)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Discard',
                    style: GoogleFonts.dmSans(color: NoveColors.error)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await ref
              .read(notesProvider.notifier)
              .deleteNote(widget.note!.id);
        }
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) Navigator.pop(context);
      }
      return;
    }

    if (_isNewNote) {
      await ref.read(notesProvider.notifier).createNote(
            content,
            colorLabel: _selectedColor,
            category:
                _selectedCategory.isNotEmpty ? _selectedCategory : null,
          );
    } else if (_hasChanges && widget.note != null) {
      await NoteService.updateNote(
        widget.note!.id,
        content: content,
        isPinned: _isPinned,
        colorLabel: _selectedColor,
        category: _selectedCategory.isNotEmpty ? _selectedCategory : null,
      );
    }

    HapticFeedback.lightImpact();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _autoSave() async {
    final content = _contentController.text.trim();
    if (content.isEmpty || !_hasChanges) return;

    if (!_isNewNote && widget.note != null) {
      await NoteService.updateNote(
        widget.note!.id,
        content: content,
        isPinned: _isPinned,
        colorLabel: _selectedColor,
        category: _selectedCategory.isNotEmpty ? _selectedCategory : null,
      );
      if (mounted) {
        setState(() {
          _isSaved = true;
          _hasChanges = false;
        });
      }
    }
  }

  void _insertFormatting(String prefix, [String? suffix]) {
    final sel = _contentController.selection;
    if (!sel.isValid) return;
    final text = _contentController.text;
    final selected = sel.textInside(text);
    final replacement = suffix != null
        ? '$prefix$selected$suffix'
        : '$prefix$selected';
    final newText = text.replaceRange(sel.start, sel.end, replacement);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: sel.start + replacement.length),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wordCount = _getWordCount();
    final charCount = _contentController.text.length;
    final readTime = (wordCount / 200).ceil().clamp(1, 99);

    return Scaffold(
      backgroundColor: NoveColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ───────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: NoveColors.bg(context),
                border: Border(
                  bottom: BorderSide(
                      color: NoveColors.cardBorder(context), width: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back + actions row
                  Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: _saveAndClose,
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: NoveColors.secondaryText(context)),
                            const SizedBox(width: 4),
                            Text(
                              'Notes',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: NoveColors.secondaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Focus mode toggle
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _focusMode = !_focusMode);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _focusMode
                                ? NoveColors.accent(context)
                                    .withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(NoveRadii.full),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.center_focus_strong_outlined,
                                size: 14,
                                color: _focusMode
                                    ? NoveColors.accent(context)
                                    : NoveColors.mutedText(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Focus',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: _focusMode
                                      ? NoveColors.accent(context)
                                      : NoveColors.mutedText(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Pin button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _isPinned = !_isPinned;
                            _hasChanges = true;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _isPinned
                                ? NoveColors.accent(context).withOpacity(0.12)
                                : NoveColors.cardBg(context),
                            borderRadius:
                                BorderRadius.circular(NoveRadii.sm),
                            border: Border.all(
                                color: NoveColors.cardBorder(context),
                                width: 0.5),
                          ),
                          child: Icon(
                            _isPinned
                                ? Icons.push_pin_rounded
                                : Icons.push_pin_outlined,
                            size: 18,
                            color: _isPinned
                                ? NoveColors.accent(context)
                                : NoveColors.mutedText(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Done button
                      GestureDetector(
                        onTap: _saveAndClose,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                            color: NoveColors.accent(context),
                            borderRadius:
                                BorderRadius.circular(NoveRadii.full),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 5),
                              Text(
                                'Done',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Category chips ─────────────────────────────────
                  if (!_focusMode) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 30,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // No category option
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedCategory = '';
                                _hasChanges = true;
                              });
                            },
                            child: AnimatedContainer(
                              duration: NoveAnimation.fast,
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: _selectedCategory.isEmpty
                                    ? NoveColors.accent(context)
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(NoveRadii.full),
                                border: Border.all(
                                  color: _selectedCategory.isEmpty
                                      ? Colors.transparent
                                      : NoveColors.cardBorder(context),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'None',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedCategory.isEmpty
                                      ? Colors.white
                                      : NoveColors.mutedText(context),
                                ),
                              ),
                            ),
                          ),
                          ..._availableCategories.map((cat) {
                            final isActive = _selectedCategory == cat;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedCategory = isActive ? '' : cat;
                                  _hasChanges = true;
                                });
                              },
                              child: AnimatedContainer(
                                duration: NoveAnimation.fast,
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? NoveColors.accent(context)
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(NoveRadii.full),
                                  border: Border.all(
                                    color: isActive
                                        ? Colors.transparent
                                        : NoveColors.cardBorder(context),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.white
                                        : NoveColors.secondaryText(context),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    // ── Color label swatches ───────────────────────────
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Color:',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: NoveColors.mutedText(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ..._colorLabels.map((c) {
                          final isSelected = _selectedColor == c;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedColor = c;
                                _hasChanges = true;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: c == '#FFFFFF'
                                    ? Colors.transparent
                                    : Color(int.parse(
                                        c.replaceFirst('#', '0xFF'))),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? NoveColors.primaryText(context)
                                      : NoveColors.warmGray300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: c == '#FFFFFF'
                                  ? Icon(Icons.close,
                                      size: 10,
                                      color: NoveColors.warmGray400)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Editor Body ────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // Ruled lines background
                  Positioned.fill(
                    child: CustomPaint(
                      painter: RuledBackgroundPainter(
                        lineColor: isDark
                            ? NoveColors.warmGray800.withOpacity(0.6)
                            : NoveColors.warmGray200.withOpacity(0.5),
                      ),
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
                      cursorColor: NoveColors.accent(context),
                      cursorWidth: 2,
                      onChanged: (_) {
                        Future.delayed(
                            const Duration(seconds: 3), _autoSave);
                      },
                      style: GoogleFonts.caveat(
                        fontSize: 26,
                        color: NoveColors.primaryText(context),
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Write freely. Nothing leaves this device.',
                        hintStyle: GoogleFonts.caveat(
                          fontSize: 24,
                          color: NoveColors.mutedText(context),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Formatting Toolbar ─────────────────────────────────────
            if (!_focusMode)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                decoration: BoxDecoration(
                  color: NoveColors.cardBg(context),
                  borderRadius: BorderRadius.circular(NoveRadii.sm),
                  border: Border.all(
                      color: NoveColors.cardBorder(context), width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _FormatBtn(
                      label: 'B',
                      bold: true,
                      onTap: () => _insertFormatting('**', '**'),
                      isDark: isDark,
                    ),
                    _FmtDivider(),
                    _FormatBtn(
                      label: 'I',
                      italic: true,
                      onTap: () => _insertFormatting('_', '_'),
                      isDark: isDark,
                    ),
                    _FmtDivider(),
                    _FormatIconBtn(
                      icon: Icons.format_list_bulleted_rounded,
                      tooltip: 'Bullet list',
                      onTap: () => _insertFormatting('• '),
                      isDark: isDark,
                    ),
                    _FmtDivider(),
                    _FormatIconBtn(
                      icon: Icons.check_box_outlined,
                      tooltip: 'Checkbox',
                      onTap: () => _insertFormatting('☐ '),
                      isDark: isDark,
                    ),
                    _FmtDivider(),
                    _FormatBtn(
                      label: 'H',
                      onTap: () => _insertFormatting('# '),
                      isDark: isDark,
                    ),
                    _FmtDivider(),
                    _FormatIconBtn(
                      icon: Icons.format_quote_rounded,
                      tooltip: 'Quote',
                      onTap: () => _insertFormatting('> '),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

            // ── Bottom Status Bar ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: NoveColors.bg(context),
                border: Border(
                  top: BorderSide(
                      color: NoveColors.cardBorder(context), width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '$wordCount words · $readTime min',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: NoveColors.mutedText(context),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, yyyy').format(DateTime.now()),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: NoveColors.mutedText(context),
                    ),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: _isSaved ? 1 : 0,
                    duration: NoveAnimation.fast,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 12, color: NoveColors.accent(context)),
                        const SizedBox(width: 4),
                        Text(
                          'Saved',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: NoveColors.accent(context),
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
    );
  }
}

// ─── Ruled Background ─────────────────────────────────────────────────────────
class RuledBackgroundPainter extends CustomPainter {
  final Color lineColor;
  const RuledBackgroundPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;
    const double lineHeight = 39.0;
    const double topOffset = 62.0;
    for (double y = topOffset; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(24, y), Offset(size.width - 24, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant RuledBackgroundPainter old) =>
      old.lineColor != lineColor;
}

// ─── Formatting Toolbar Buttons ───────────────────────────────────────────────
class _FormatBtn extends StatelessWidget {
  final String label;
  final bool bold;
  final bool italic;
  final VoidCallback onTap;
  final bool isDark;

  const _FormatBtn({
    required this.label,
    required this.onTap,
    required this.isDark,
    this.bold = false,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                color: NoveColors.secondaryText(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormatIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;

  const _FormatIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Icon(icon, size: 18,
                color: NoveColors.secondaryText(context)),
          ),
        ),
      ),
    );
  }
}

class _FmtDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 20,
      color: NoveColors.cardBorder(context),
    );
  }
}