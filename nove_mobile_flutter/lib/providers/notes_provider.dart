import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/note_service.dart';
import '../models/note.dart';

/// State for notes list
class NotesState {
  final List<Note> notes;
  final bool isLoading;
  final String? searchQuery;

  NotesState({this.notes = const [], this.isLoading = false, this.searchQuery});

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? searchQuery,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier for notes management
class NotesNotifier extends StateNotifier<NotesState> {
  NotesNotifier() : super(NotesState(isLoading: true));

  /// Load all notes
  Future<void> loadNotes() async {
    state = state.copyWith(isLoading: true);
    try {
      final notes = await NoteService.getAllNotes();
      state = state.copyWith(notes: notes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Search notes
  Future<void> search(String query) async {
    state = state.copyWith(isLoading: true, searchQuery: query);
    try {
      final notes = await NoteService.searchNotes(query);
      state = state.copyWith(notes: notes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Create a new note
  Future<Note> createNote(
    String content, {
    String colorLabel = '#FFFFFF',
  }) async {
    final note = await NoteService.createNote(content, colorLabel: colorLabel);
    await loadNotes();
    return note;
  }

  /// Update a note
  Future<void> updateNote(String id, {String? content, bool? isPinned}) async {
    await NoteService.updateNote(id, content: content, isPinned: isPinned);
    await loadNotes();
  }

  /// Delete a note
  Future<void> deleteNote(String id) async {
    await NoteService.deleteNote(id);
    await loadNotes();
  }

  /// Toggle pin status
  Future<void> togglePin(String id) async {
    await NoteService.togglePin(id);
    await loadNotes();
  }
}

/// Provider for notes
final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  return NotesNotifier();
});

/// Provider for database initialization
final databaseInitProvider = FutureProvider<void>((ref) async {
  // Database is initialized automatically when first accessed
  await NoteService.getAllNotes();
});
