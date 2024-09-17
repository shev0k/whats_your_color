// test/introduction_animation_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats_your_color/components/center_next_button.dart';
import 'package:whats_your_color/components/top_back_skip_bar.dart';
import 'package:whats_your_color/components/views/introduction_screen_views/care_view.dart';
import 'package:whats_your_color/components/views/introduction_screen_views/mood_diary_vew.dart';
import 'package:whats_your_color/components/views/introduction_screen_views/relax_view.dart';
import 'package:whats_your_color/components/views/introduction_screen_views/splash_view.dart';
import 'package:whats_your_color/components/views/introduction_screen_views/welcome_view.dart';
import 'package:whats_your_color/screens/introduction_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IntroductionAnimationScreen Tests', () {
    Widget createWidgetUnderTest() {
      return const MaterialApp(
        home: IntroductionAnimationScreen(),
      );
    }

    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Initial render displays all views', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SplashView), findsOneWidget);
      expect(find.byType(RelaxView), findsOneWidget);
      expect(find.byType(CareView), findsOneWidget);
      expect(find.byType(MoodDiaryVew), findsOneWidget);
      expect(find.byType(WelcomeView), findsOneWidget);
      expect(find.byType(TopBackSkipView), findsOneWidget);
      expect(find.byType(CenterNextButton), findsOneWidget);
    });

    testWidgets('Pressing Next button advances the animation controller',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final nextButton = find.byType(CenterNextButton);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(RelaxView), findsOneWidget);
    });


    testWidgets('Pressing Skip button jumps to a specific animation value',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final skipButton = find.descendant(
        of: find.byType(TopBackSkipView),
        matching: find.text('Skip'),
      );
      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(MoodDiaryVew), findsOneWidget);
    });

    testWidgets('Swipe gestures trigger next and back actions',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.drag(find.byType(IntroductionAnimationScreen), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.byType(RelaxView), findsOneWidget);

      await tester.drag(find.byType(IntroductionAnimationScreen), const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(find.byType(SplashView), findsOneWidget);
    });
  });
}
