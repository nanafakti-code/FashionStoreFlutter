// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_store_flutter/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FashionStoreApp());

    // Verify that the app loads - basic smoke test
    expect(find.byType(FashionStoreApp), findsOneWidget);
  });
}
