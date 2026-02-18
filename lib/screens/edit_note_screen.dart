import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? existing;

  const EditNoteScreen({super.key, this.existing});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existing?.title ?? '');
    _contentController =
        TextEditingController(text: widget.existing?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  void _insertNewLine() {
    final text = _contentController.text;
    final sel = _contentController.selection;

    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;

    final newText = text.replaceRange(start, end, '\n');
    _contentController.text = newText;
    _contentController.selection =
        TextSelection.collapsed(offset: start + 1);
  }
  bool _hasChanges() {
    final originalTitle = widget.existing?.title ?? '';
    final originalContent = widget.existing?.content ?? '';

    return _titleController.text != originalTitle || _contentController.text != originalContent;


  }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text;

    final note = Note(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, note);
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 2),
      ),
    );
  }

  /// Handles both normal Enter and Numpad Enter
  bool _isEnterKey(KeyEvent event) {
    final lk = event.logicalKey;
    final pk = event.physicalKey;

    if (lk == LogicalKeyboardKey.enter ||
        lk == LogicalKeyboardKey.numpadEnter ||
        pk == PhysicalKeyboardKey.enter ||
        pk == PhysicalKeyboardKey.numpadEnter) {
      return true;
    }

    // Emulator sometimes reports it differently
    final label = lk.keyLabel.toLowerCase();
    if (label == 'enter' || label == 'return') {
      return true;
    }

    return false;
  }

  @override
Widget build(BuildContext context) {
  final isEditing = widget.existing != null;

  return PopScope(
    canPop: false,
    onPopInvoked: (didPop) async {
      if (didPop) return;

      if (_hasChanges()) {
        final shouldSave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Unsaved Changes"),
            content: const Text("Do you want to save your changes?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Discard"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Save"),
              ),
            ],
          ),
        );

        if (shouldSave == true) {
          _save();
        } else {
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            tooltip: 'Save',
            onPressed: _save,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// TITLE FIELD
            TextField(
              focusNode: _titleFocus,
              controller: _titleController,
              decoration: _fieldDecoration('Title'),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _contentFocus.requestFocus(),
            ),

            const SizedBox(height: 12),

            /// NOTE FIELD
            Expanded(
              child: Focus(
                onKeyEvent: (node, event) {
                  if (event is! KeyDownEvent) {
                    return KeyEventResult.ignored;
                  }

                  if (_contentFocus.hasFocus &&
                      _isEnterKey(event)) {
                    _insertNewLine();
                    return KeyEventResult.handled;
                  }

                  return KeyEventResult.ignored;
                },
                child: TextField(
                  focusNode: _contentFocus,
                  controller: _contentController,
                  decoration: _fieldDecoration('Note'),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: null,
                  expands: true,

                  //  Fix: start typing from TOP
                  textAlignVertical: TextAlignVertical.top,
                  textAlign: TextAlign.start,

                  scrollPadding:
                      const EdgeInsets.all(20),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}