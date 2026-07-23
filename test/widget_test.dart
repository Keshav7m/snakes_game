// Widget tests for the Snakes Game.
//
// The loading page runs a finite animation, so pumpAndSettle can advance
// through it to the start screen. The game screen runs a continuous ticker,
// so once we're in the game we advance frames manually with tester.pump(...)
// instead of pumpAndSettle (which would time out on an endless animation).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_game/main.dart';

void main() {
  testWidgets('Shows the loading page first', (WidgetTester tester) async {
    await tester.pumpWidget(const SnakesGameApp());

    // The splash/loading page is displayed on launch.
    expect(find.byType(LoadingPage), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('Advances to the start screen with the color picker', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SnakesGameApp());

    // Let the loading animation finish and the navigation settle.
    await tester.pumpAndSettle();

    // We should now be on the start screen.
    expect(find.byType(StartScreen), findsOneWidget);
    expect(find.text('Pick your snake color'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Play'), findsOneWidget);
  });

  testWidgets('Tapping Play starts the game with score zero', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SnakesGameApp());
    await tester.pumpAndSettle(); // reach the start screen

    // Start the game.
    await tester.tap(find.widgetWithText(FilledButton, 'Play'));

    // Finish the page transition without settling (the game loops forever).
    await tester.pump(); // start the transition
    await tester.pump(const Duration(milliseconds: 400)); // complete it

    // The game board is up and the score starts at zero.
    expect(find.byType(SnakeGame), findsOneWidget);
    expect(find.text('Score: 0'), findsOneWidget);
  });
}
