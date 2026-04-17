import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';
import 'dart:io';
import 'dart:convert';

/// Simple database service using file-based storage
/// This avoids native asset hooks that fail with spaces in paths
class DatabaseService {
  static final List<Note> _notes = [];
  static bool _initialized = false;

  static Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File(join(directory.path, 'nove_notes.json'));
  }

  /// Initialize database
  static Future<void> init() async {
    if (_initialized) return;
    try {
      final file = await _file;
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _notes.clear();
        _notes.addAll(jsonList.map((j) => Note.fromJson(j)));
      }
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
    _initialized = true;
  }

  static Future<void> _save() async {
    try {
      final file = await _file;
      final jsonList = _notes.map((n) => n.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving notes: $e');
    }
  }

  /// Close database
  static Future<void> close() async {
    _notes.clear();
    _initialized = false;
  }

  /// Get all notes sorted by pinned first, then by updated_at
  static Future<List<Note>> getAllNotes() async {
    await init();
    final sorted = List<Note>.from(_notes);
    sorted.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return b.isPinned ? 1 : -1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return sorted;
  }

  /// Get note by id
  static Future<Note?> getNoteById(String id) async {
    await init();
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get pinned notes
  static Future<List<Note>> getPinnedNotes() async {
    await init();
    return _notes.where((note) => note.isPinned).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Get favorite notes
  static Future<List<Note>> getFavoriteNotes() async {
    await init();
    return _notes.where((note) => note.isFavorite).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Search notes by title or content
  static Future<List<Note>> searchNotes(String query) async {
    await init();
    final searchTerm = query.toLowerCase();
    final filtered = _notes
        .where(
          (note) =>
              note.title.toLowerCase().contains(searchTerm) ||
              note.content.toLowerCase().contains(searchTerm),
        )
        .toList();
    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered;
  }

  /// Insert a note
  static Future<int> insertNote(Note note) async {
    await init();
    _notes.add(note);
    await _save();
    return 1;
  }

  /// Update a note
  static Future<int> updateNote(Note note) async {
    await init();
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      await _save();
      return 1;
    }
    return 0;
  }

  /// Delete a note
  static Future<int> deleteNote(String id) async {
    await init();
    final initialLength = _notes.length;
    _notes.removeWhere((note) => note.id == id);
    await _save();
    return initialLength - _notes.length;
  }

  /// Get notes count
  static Future<int> getNotesCount() async {
    await init();
    return _notes.length;
  }

  /// Get notes by category
  static Future<List<Note>> getNotesByCategory(String category) async {
    await init();
    return _notes.where((note) => note.category == category).toList()
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return b.isPinned ? 1 : -1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
  }
}
