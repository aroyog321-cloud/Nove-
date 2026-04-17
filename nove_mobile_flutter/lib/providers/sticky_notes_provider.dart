import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sticky_note.dart';
import 'package:uuid/uuid.dart';

const _key = 'sticky_notes_v1';
const _uuid = Uuid();

class StickyNotesNotifier extends StateNotifier<List<StickyNote>> {
  StickyNotesNotifier() : super([]);

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    final list = jsonDecode(raw) as List;
    state = list.map((m) => StickyNote.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.map((n) => n.toMap()).toList()));
  }

  Future<void> createNote(String title, StickyColor color, [String content = '']) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final note = StickyNote(
      id: 'sticky_${now}_${_uuid.v4().substring(0, 6)}',
      title: title,
      content: content,
      color: color,
      createdAt: now,
    );
    state = [note, ...state];
    await _save();
  }

  Future<void> deleteNote(String id) async {
    state = state.where((n) => n.id != id).toList();
    await _save();
  }

  Future<void> clearAll() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final stickyNotesProvider = StateNotifierProvider<StickyNotesNotifier, List<StickyNote>>(
  (ref) => StickyNotesNotifier(),
);
