// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/screens/login_screen.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget( LoginScreen());

    // Verify that the title "App Demo" is present.
    expect(find.text('App Demo'), findsOneWidget);

    // Verify that the text fields for "Tài khoản" and "Mật khẩu" are present.
    expect(find.widgetWithText(TextField, 'Tài khoản'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Mật khẩu'), findsOneWidget);

    // Verify that the "Đăng nhập" button is present.
    expect(find.widgetWithText(ElevatedButton, 'Đăng nhập'), findsOneWidget);

    // Optional: Simulate tapping the login button.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
    await tester.pump();
  });
}
