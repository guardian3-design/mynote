//Flutter testing library
import 'package:flutter_test/flutter_test.dart';

//Import the Note model so we can test it
import 'package:mynote/models/note.dart';

void main() {
  //Test 1: is checking that a Note stores values correctly

  test('Note object stores values correctly', () {
    //Create a new Note object
    final note = Note(
      id: '1',
      title: 'Test',
      content: 'Hello',
      updatedAt: DateTime.now(),
    );

    //Verify esch field matches what we passed in
    expect(note.id, '1');
    expect(note.title, 'Test');
    expect(note.content, 'Hello');
  });

  //  NEW TEST #1
  //This test is for Title can be empty,untitled allowed
  test('Note title can be empty (Untitled allowed)', () {
    final note = Note(
      id: '2',
      title: '',
      content: 'Content only',
      updatedAt: DateTime.now(),
    );
    //expecting tittle to be empty string
    expect(note.title, '');
  });

  //  NEW TEST #2
  //This test is for 2 notes should have different IDS
  //important so delete/ edit works properly
  test('Different notes have different IDs', () {
    final note1 = Note(
      id: '1',
      title: 'A',
      content: 'One',
      updatedAt: DateTime.now(),
    );

    final note2 = Note(
      id: '2',
      title: 'B',
      content: 'Two',
      updatedAt: DateTime.now(),
    );
    // IDS myst NOT be the same
    expect(note1.id != note2.id, true);
  });
}
