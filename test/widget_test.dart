import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:formalia/viewmodels/auth_viewmodel.dart';
import 'package:formalia/views/auth/login_screen.dart';

void main() {
  testWidgets('login screen renders key actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthViewModel(),
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNWidgets(2));
    expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
  });
}
