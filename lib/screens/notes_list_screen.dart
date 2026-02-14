import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../models/note.dart';
import 'edit_note_screen.dart';

import '../services/auth_service.dart';
import '../auth/login_screen.dart';

class ScrollUpIntent extends Intent {
  const ScrollUpIntent();
}

class ScrollDownIntent extends Intent {
  const ScrollDownIntent();
}

class PageUpIntent extends Intent {
  const PageUpIntent();
}

class PageDownIntent extends Intent {
  const PageDownIntent();
}

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  static const String _boxName = 'notesBox';

  final List<Note> _notes = [];
  final ScrollController _scroll = ScrollController();
  final FocusNode _screenFocus = FocusNode();

  final AuthService _auth = AuthService(); // ✅ added

  Box get _box => Hive.box(_boxName);

  @override
  void initState() {
    super.initState();
    _loadFromHive();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _screenFocus.dispose();
    super.dispose();
  }

  void _loadFromHive() {
    final List<Note> loaded = [];

    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        loaded.add(Note.fromMap(Map<dynamic, dynamic>.from(raw)));
      }
    }

    loaded.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    setState(() {
      _notes
        ..clear()
        ..addAll(loaded);
    });
  }

  Future<void> _saveNoteToHive(Note note) async {
    await _box.put(note.id, note.toMap());
  }

  Future<void> _deleteNoteFromHive(String id) async {
    await _box.delete(id);
  }

  Future<void> _addNewNote() async {
    final created = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => const EditNoteScreen()),
    );

    if (created != null) {
      await _saveNoteToHive(created);

      setState(() {
        _notes.insert(0, created);
      });

      if (_scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    }
  }

  Future<void> _editExistingNote(Note note) async {
    final updated = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => EditNoteScreen(existing: note)),
    );

    if (updated != null) {
      await _saveNoteToHive(updated);

      setState(() {
        final index = _notes.indexWhere((n) => n.id == updated.id);
        if (index != -1) _notes[index] = updated;
        _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      });
    }
  }

  Future<void> _deleteNote(String id) async {
    await _deleteNoteFromHive(id);
    setState(() => _notes.removeWhere((n) => n.id == id));
  }

  void _scrollBy(double delta) {
    if (!_scroll.hasClients) return;

    final target = (_scroll.offset + delta).clamp(
      0.0,
      _scroll.position.maxScrollExtent,
    );

    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
  }

  // LOGOUT
  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // OPTIONAL: RESET ACCOUNT (for professor demo)
  Future<void> _resetAccount() async {
    await _auth.clearAccount();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp): ScrollUpIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): ScrollDownIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft): PageUpIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): PageDownIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ScrollUpIntent: CallbackAction<ScrollUpIntent>(
            onInvoke: (_) => _scrollBy(-80),
          ),
          ScrollDownIntent: CallbackAction<ScrollDownIntent>(
            onInvoke: (_) => _scrollBy(80),
          ),
          PageUpIntent: CallbackAction<PageUpIntent>(
            onInvoke: (_) => _scrollBy(-350),
          ),
          PageDownIntent: CallbackAction<PageDownIntent>(
            onInvoke: (_) => _scrollBy(350),
          ),
        },
        child: Focus(
          autofocus: true,
          focusNode: _screenFocus,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('MyNote'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: _logout,
                ),

                // OPTIONAL demo button (remove if teacher doesn't want it)
                IconButton(
                  icon: const Icon(Icons.person_remove),
                  tooltip: 'Reset Account',
                  onPressed: _resetAccount,
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _addNewNote,
              child: const Icon(Icons.add),
            ),
            body: _notes.isEmpty
                ? const Center(child: Text('No notes yet. Tap + to add one.'))
                : Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView.separated(
                      controller: _scroll,
                      itemCount: _notes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final note = _notes[index];

                        return Dismissible(
                          key: ValueKey(note.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteNote(note.id),
                          child: Card(
                            child: ListTile(
                              title: Text(
                                note.title.isEmpty ? '(Untitled)' : note.title,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                note.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black87),
                              ),
                              onTap: () => _editExistingNote(note),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
