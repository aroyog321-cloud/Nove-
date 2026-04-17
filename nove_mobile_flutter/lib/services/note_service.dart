import 'package:uuid/uuid.dart';
import '../models/note.dart';
import 'database_service.dart';

class NoteService {
  static const _uuid = Uuid();

  /// Calculate read time in minutes
  static double _calculateReadTime(String content) {
    final wordCount = content
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .length;
    return (wordCount / 200).ceil().toDouble().clamp(1, double.infinity);
  }

  /// Calculate word count
  static int _calculateWordCount(String content) {
    return content
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .length;
  }

  /// Extract title from content (first line, truncated to 100 chars)
  static String _extractTitle(String content) {
    final firstLine = content.split('\n').first.trim();
    if (firstLine.isEmpty) return 'Untitled';
    if (firstLine.length > 100) {
      return '${firstLine.substring(0, 97)}...';
    }
    return firstLine;
  }

  /// Get all notes
  static Future<List<Note>> getAllNotes() async {
    return await DatabaseService.getAllNotes();
  }

  /// Get note by id
  static Future<Note?> getNoteById(String id) async {
    return await DatabaseService.getNoteById(id);
  }

  /// Get pinned notes
  static Future<List<Note>> getPinnedNotes() async {
    return await DatabaseService.getPinnedNotes();
  }

  /// Get favorite notes
  static Future<List<Note>> getFavoriteNotes() async {
    return await DatabaseService.getFavoriteNotes();
  }

  /// Search notes
  static Future<List<Note>> searchNotes(String query) async {
    if (query.isEmpty) return getAllNotes();
    return await DatabaseService.searchNotes(query);
  }

  /// Create a new note
  static Future<Note> createNote(
    String content, {
    String? category,
    String colorLabel = '#FFFFFF',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = 'note_${now}_${_uuid.v4().substring(0, 8)}';
    final title = _extractTitle(content);
    final wordCount = _calculateWordCount(content);
    final charCount = content.length;
    final readTimeMinutes = _calculateReadTime(content);

    final note = Note(
      id: id,
      title: title,
      content: content,
      category: category,
      colorLabel: colorLabel,
      isPinned: false,
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
      wordCount: wordCount,
      charCount: charCount,
      readTimeMinutes: readTimeMinutes,
    );

    await DatabaseService.insertNote(note);
    return note;
  }

  /// Update a note
  static Future<Note?> updateNote(
    String id, {
    String? content,
    String? category,
    String? colorLabel,
    bool? isPinned,
    bool? isFavorite,
  }) async {
    final existing = await DatabaseService.getNoteById(id);
    if (existing == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final newContent = content ?? existing.content;
    final title = _extractTitle(newContent);
    final wordCount = _calculateWordCount(newContent);
    final charCount = newContent.length;
    final readTimeMinutes = _calculateReadTime(newContent);

    final updatedNote = existing.copyWith(
      title: title,
      content: newContent,
      category: category ?? existing.category,
      colorLabel: colorLabel ?? existing.colorLabel,
      isPinned: isPinned ?? existing.isPinned,
      isFavorite: isFavorite ?? existing.isFavorite,
      updatedAt: now,
      wordCount: wordCount,
      charCount: charCount,
      readTimeMinutes: readTimeMinutes,
    );

    await DatabaseService.updateNote(updatedNote);
    return updatedNote;
  }

  /// Delete a note
  static Future<bool> deleteNote(String id) async {
    final affected = await DatabaseService.deleteNote(id);
    return affected > 0;
  }

  /// Toggle pin status
  static Future<Note?> togglePin(String id) async {
    final note = await DatabaseService.getNoteById(id);
    if (note == null) return null;
    return await updateNote(id, isPinned: !note.isPinned);
  }

  /// Toggle favorite status
  static Future<Note?> toggleFavorite(String id) async {
    final note = await DatabaseService.getNoteById(id);
    if (note == null) return null;
    return await updateNote(id, isFavorite: !note.isFavorite);
  }

  /// Get notes count
  static Future<int> getNotesCount() async {
    return await DatabaseService.getNotesCount();
  }

  /// Get notes by category
  static Future<List<Note>> getNotesByCategory(String category) async {
    return await DatabaseService.getNotesByCategory(category);
  }

  /// Delete all notes (Danger Zone)
  static Future<void> clearAll() async {
    final notes = await getAllNotes();
    for (final note in notes) {
      await DatabaseService.deleteNote(note.id);
    }
  }
}
