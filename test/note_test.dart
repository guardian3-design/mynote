// Flutter testing library
import 'package:flutter_test/flutter_test.dart';

// Import the Note model
import 'package:mynote/models/note.dart';

void main() {
  // =========================================================
  // TEST 1: Note stores all values correctly
  // =========================================================
  test('Note object stores values correctly', () {
    final now = DateTime.now();

    final note = Note(
      id: '1',
      title: 'Test',
      content: 'Hello',
      folder: 'CSIT 112',
      category: 'Homework',
      tags: ['week3', 'exam'],
      createdAt: now,
      updatedAt: now,
    );

    expect(note.id, '1');
    expect(note.title, 'Test');
    expect(note.content, 'Hello');
    expect(note.folder, 'CSIT 112');
    expect(note.category, 'Homework');
    expect(note.tags.length, 2);
    expect(note.tags.contains('week3'), true);
    expect(note.tags.contains('exam'), true);
  });

  // =========================================================
  // TEST 2: Title can be empty (Untitled allowed)
  // =========================================================
  test('Note title can be empty (Untitled allowed)', () {
    final note = Note(
      id: '2',
      title: '',
      content: 'Content only',
      folder: 'General',
      category: 'General',
      tags: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    expect(note.title, '');
  });

  // =========================================================
  // TEST 3: Different notes must have different IDs
  // =========================================================
  test('Different notes have different IDs', () {
    final note1 = Note(
      id: '1',
      title: 'A',
      content: 'One',
      folder: 'Work',
      category: 'Work',
      tags: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final note2 = Note(
      id: '2',
      title: 'B',
      content: 'Two',
      folder: 'Personal',
      category: 'Personal',
      tags: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    expect(note1.id != note2.id, true);
  });

  // =========================================================
  // TEST 4: Note converts to Map and back correctly
  // =========================================================
  test('Note toMap and fromMap preserve data', () {
    final now = DateTime.now();

    final original = Note(
      id: '123',
      title: 'Map Test',
      content: 'Testing serialization',
      folder: 'AMAT 240',
      category: 'Courses',
      tags: ['lecture', 'matrix'],
      createdAt: now,
      updatedAt: now,
    );

    final map = original.toMap();
    final recreated = Note.fromMap(map);

    expect(recreated.id, original.id);
    expect(recreated.title, original.title);
    expect(recreated.content, original.content);
    expect(recreated.folder, original.folder);
    expect(recreated.category, original.category);
    expect(recreated.tags, original.tags);
    expect(recreated.createdAt.millisecondsSinceEpoch,
        original.createdAt.millisecondsSinceEpoch);
    expect(recreated.updatedAt.millisecondsSinceEpoch,
        original.updatedAt.millisecondsSinceEpoch);
  });

  // =========================================================
  // TEST 5: Backward compatibility (older notes without new fields)
  // =========================================================
  test('Note.fromMap works with old data (no folder/tags)', () {
    final oldMap = {
      'id': 'legacy',
      'title': 'Old Note',
      'content': 'This was created before folders',
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    final note = Note.fromMap(oldMap);

    expect(note.folder, 'General');
    expect(note.category, 'General');
    expect(note.tags.isEmpty, true);
  });
}