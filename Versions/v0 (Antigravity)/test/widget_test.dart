import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodrescue_labgh/main.dart';

void main() {
  testWidgets('FoodRescue App startup smoke test', (WidgetTester tester) async {
    // Build our app under ProviderScope to enable Riverpod state management.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the Marketplace header is present.
    expect(find.text('FoodRescue Marketplace'), findsOneWidget);

    // Verify that the bottom navigation bar has the five distinct icons.
    // The active tab (Marketplace) uses Icons.storefront.
    expect(find.byIcon(Icons.storefront), findsOneWidget);
    
    // The inactive tabs use outlined icons.
    expect(find.byIcon(Icons.map_outlined), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border_outlined), findsOneWidget);
    expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });
}
