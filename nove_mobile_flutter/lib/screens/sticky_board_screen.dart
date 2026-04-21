import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
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
  final Map<String, Offset> _positions = {};
  Timer? _overlayCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stickyNotesProvider.notifier).loadNotes();
    });

    // POLLER: Checks every 500ms to see if the window was destroyed
    _overlayCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      final poppedNote = ref.read(poppedOutNoteProvider);
      if (poppedNote != null) {
        try {
          final isActive = await FlutterOverlayWindow.isActive();
          if (!isActive) {
            ref.read(poppedOutNoteProvider.notifier).state = null;
          }
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _overlayCheckTimer?.cancel();
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
    ref.read(stickyNotesProvider.notifier).moveToTrash(id);
    _positions.remove(id);
  }

  void _updateNoteContent(String id, String content) {
    ref.read(stickyNotesProvider.notifier).updateNoteContent(id, content);
  }

  void _togglePin(String id) {
    ref.read(stickyNotesProvider.notifier).togglePin(id);
  }

  Color _getNoteColor(StickyColor color) {
    switch (color) {
      case StickyColor.yellow: return const Color(0xFFF5C842);
      case StickyColor.pink: return const Color(0xFFF2C2D8);
      case StickyColor.green: return const Color(0xFFC5EDBE);
      case StickyColor.blue: return const Color(0xFFB3E5FC);
    }
  }

  void _minimizeNote(StickyNote note) async {
    final poppedNote = ref.read(poppedOutNoteProvider);
    
    if (poppedNote != null && poppedNote.id != note.id) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Android only allows 1 floating note at a time. Please restore your active note first.')),
        );
      }
      return;
    }

    ref.read(poppedOutNoteProvider.notifier).state = note;
    
    try {
      bool hasPermission = await FlutterOverlayWindow.isPermissionGranted();
      if (!hasPermission) {
        bool? requested = await FlutterOverlayWindow.requestPermission();
        if (requested != true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Overlay Permission is required to float notes.')),
            );
          }
          return;
        }
      }

      final data = jsonEncode({
        'id': note.id,
        'title': note.title,
        'content': note.content,
        'color': _getNoteColor(note.color).value,
        'isBubble': true,
      });

      bool isActive = false;
      try {
        isActive = await FlutterOverlayWindow.isActive();
      } catch (_) {
        isActive = false;
      }

      if (isActive) {
        await FlutterOverlayWindow.resizeOverlay(60, 60, true);
        await FlutterOverlayWindow.shareData("note:$data");
      } else {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          height: 60, 
          width: 60,
          alignment: OverlayAlignment.centerRight,
        );
        await Future.delayed(const Duration(milliseconds: 400));
        await FlutterOverlayWindow.shareData("note:$data");
      }
      
    } catch (e) {
      debugPrint('Overlay blocked or crashed: $e'); 
    }
  }

  Offset _getGridPosition(int index) {
    final double x = 16.0 + (index % 2) * 176.0;
    final double y = 16.0 + (index ~/ 2) * 200.0;
    return Offset(x, y);
  }

  void _arrangeNotes(List<StickyNote> visibleNotes) {
    setState(() {
      for (int i = 0; i < visibleNotes.length; i++) {
        _positions[visibleNotes[i].id] = _getGridPosition(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allNotes = ref.watch(stickyNotesProvider);
    final poppedNote = ref.watch(poppedOutNoteProvider);
    
    final visibleNotes = allNotes.where((n) => n.id != poppedNote?.id).toList();
    visibleNotes.sort((a, b) {
      final aPinned = ref.read(stickyNotesProvider.notifier).isPinned(a.id);
      final bPinned = ref.read(stickyNotesProvider.notifier).isPinned(b.id);
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return Scaffold(
      backgroundColor: NoveColors.cream,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: DotGridPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                          Text(
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
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              try {
                                await FlutterOverlayWindow.closeOverlay();
                              } catch (_) {}
                              ref.read(poppedOutNoteProvider.notifier).state = null;
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Floating note restored.')),
                                );
                              }
                            },
                            icon: const Icon(Icons.settings_backup_restore, color: NoveColors.terracotta),
                            tooltip: 'Restore Floating Note',
                            style: IconButton.styleFrom(backgroundColor: NoveColors.warmGray200),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _arrangeNotes(visibleNotes),
                            icon: const Icon(Icons.grid_view, color: NoveColors.terracotta),
                            tooltip: 'Arrange Board',
                            style: IconButton.styleFrom(backgroundColor: NoveColors.warmGray200),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: visibleNotes.isEmpty
                      ? Center(
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
                          padding: const EdgeInsets.only(bottom: 120),
                          child: SizedBox(
                            height: math.max(1000, (visibleNotes.length / 2).ceil() * 200.0 + 100),
                            width: double.infinity,
                            child: Stack(
                              children: visibleNotes.asMap().entries.map((entry) {
                                final index = entry.key;
                                final note = entry.value;
                                final isPinned = ref.read(stickyNotesProvider.notifier).isPinned(note.id);
                                
                                _positions.putIfAbsent(note.id, () => Offset(
                                   24.0 + math.Random().nextInt(60), 
                                   24.0 + math.Random().nextInt(60)
                                ));
                                final pos = _positions[note.id]!;

                                return Positioned(
                                  key: ValueKey(note.id),
                                  left: pos.dx,
                                  top: pos.dy,
                                  child: SizedBox(
                                    width: 160,
                                    height: 184,
                                    child: _StickyCard(
                                      note: note,
                                      isPinned: isPinned,
                                      onDelete: () => _deleteNote(note.id),
                                      onMinimize: () => _minimizeNote(note),
                                      onTogglePin: () => _togglePin(note.id),
                                      onContentChanged: (newText) => _updateNoteContent(note.id, newText),
                                      onDragUpdate: (details) {
                                        setState(() {
                                          _positions[note.id] = Offset(
                                            math.max(0, pos.dx + details.delta.dx),
                                            math.max(0, pos.dy + details.delta.dy),
                                          );
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
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

class _StickyCard extends StatefulWidget {
  final StickyNote note;
  final bool isPinned;
  final VoidCallback onDelete;
  final VoidCallback onMinimize;
  final VoidCallback onTogglePin;
  final ValueChanged<String> onContentChanged;
  final GestureDragUpdateCallback onDragUpdate;

  const _StickyCard({
    required this.note,
    required this.isPinned,
    required this.onDelete,
    required this.onMinimize,
    required this.onTogglePin,
    required this.onContentChanged,
    required this.onDragUpdate,
  });

  @override
  State<_StickyCard> createState() => _StickyCardState();
}

class _StickyCardState extends State<_StickyCard> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.note.color) {
      case StickyColor.yellow: return const Color(0xFFF5C842);
      case StickyColor.pink: return const Color(0xFFF2C2D8);
      case StickyColor.green: return const Color(0xFFC5EDBE);
      case StickyColor.blue: return const Color(0xFFB3E5FC);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Move to Trash'),
          content: const Text('Move this sticky note to the trash bin?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete();
              },
              child: const Text('Trash', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF31312D).withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onPanUpdate: widget.onDragUpdate,
                  child: Container(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    color: Colors.transparent,
                    child: const Icon(Icons.drag_indicator, size: 20, color: Colors.black26),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onMinimize,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.open_in_new, size: 18, color: Colors.black54),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onTogglePin,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          widget.isPinned ? Icons.push_pin : Icons.push_pin_outlined, 
                          size: 18, 
                          color: widget.isPinned ? NoveColors.terracotta : Colors.black54
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _confirmDelete,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.delete_outline, size: 18, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.note.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  widget.note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NoveTypography.dmsans(
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C18),
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: TextFormField(
                controller: _textController,
                onChanged: widget.onContentChanged,
                maxLines: null,
                expands: true,
                style: NoveTypography.caveat(
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.2,
                    color: Color(0xCC1C1C18),
                  ),
                ),
                decoration: const InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  hintText: 'Write here...',
                  hintStyle: TextStyle(color: Colors.black26),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontFamily: 'DMSans', fontSize: 14, color: Color(0xFF1C1C18)),
              decoration: const InputDecoration(
                hintText: 'Title (optional)...',
                hintStyle: TextStyle(color: Color(0x661C1C18)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (_) => onAdd(),
            ),
          ),
          const SizedBox(width: 8),
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