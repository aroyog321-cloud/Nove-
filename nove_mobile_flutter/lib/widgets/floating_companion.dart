import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../services/note_service.dart';

class FloatingCompanion extends StatefulWidget {
  const FloatingCompanion({super.key});

  @override
  State<FloatingCompanion> createState() => _FloatingCompanionState();
}

class _FloatingCompanionState extends State<FloatingCompanion>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  final _controller = TextEditingController();
  late final AnimationController _bobController;
  late final Animation<double> _bobAnim;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _bobAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bobController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() => setState(() => _expanded = !_expanded);

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      await NoteService.createNote(text);
      _controller.clear();
    }
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Expanded Card ──────────────────────────────────────────────────
        if (_expanded)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Material(
              borderRadius: BorderRadius.circular(16),
              elevation: 12,
              shadowColor: Colors.black26,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFCF9F3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    const SizedBox(height: 12),
                    Container(
                      width: 32,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E2DC),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                      child: Row(
                        children: [
                          Text(
                            'Quick Note',
                            style: NoveTypography.lora(
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C1C18),
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _toggle,
                            icon: const Icon(Icons.close, size: 18, color: Color(0xFF58413C)),
                          ),
                        ],
                      ),
                    ),
                    // Text Input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        maxLines: 4,
                        style: NoveTypography.caveat(
                          style: const TextStyle(
                            fontSize: 22,
                            color: Color(0xFF58413C),
                          ),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Start typing...',
                          hintStyle: TextStyle(color: Color(0x551C1C18)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // Footer
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NoveColors.terracotta,
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Save Note',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Bubble ────────────────────────────────────────────────────────
        if (!_expanded)
          Positioned(
            top: 100,
            left: 16,
            child: AnimatedBuilder(
              animation: _bobAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, _bobAnim.value),
                child: child,
              ),
              child: GestureDetector(
                onTap: _toggle,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDCF49),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFDCF49).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(child: Text('✍️', style: TextStyle(fontSize: 26))),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
