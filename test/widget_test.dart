import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

import 'package:mynote/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup Hive for widget tests (creates a temp folder + opens the box)
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('mynote_test_hive_');
    Hive.init(dir.path);
    await Hive.openBox('notesBox');
  });

  tearDownAll(() async {
    await Hive.box('notesBox').close();
  });

  testWidgets('Splash shows MyNote text', (WidgetTester tester) async {
    // logged out state
    SharedPreferences.setMockInitialValues({'mynote_logged_in': false});

    await tester.pumpWidget(const MyNoteApp());

    // Splash should show immediately
    expect(find.text('MyNote'), findsOneWidget);

    // IMPORTANT: let the splash timer finish so no pending timers remain
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('When logged out, app navigates to Login screen after splash',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'mynote_logged_in': false});

    await tester.pumpWidget(const MyNoteApp());

    // Let the 2-second splash timer finish
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Login screen UI checks (must match your LoginScreen text/buttons)
    expect(find.text('Create New Account'), findsOneWidget);
    expect(find.text('Forgot username?'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('When logged in, app navigates to NotesList and shows FAB',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'mynote_logged_in': true});

    await tester.pumpWidget(const MyNoteApp());

    // Let the 2-second splash timer finish
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Notes list screen should have floating action button (+)
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
