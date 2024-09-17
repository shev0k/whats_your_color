import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats_your_color/main.dart';
import 'package:whats_your_color/screens/home_screen.dart';
import 'package:whats_your_color/screens/introduction_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MyApp Widget Tests', () {
    testWidgets('Displays IntroductionAnimationScreen when hasSeenIntroduction is false',
        (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({'hasSeenIntroduction': false});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasSeenIntroduction = prefs.getBool('hasSeenIntroduction') ?? false;

      // Act
      await tester.pumpWidget(MyApp(hasSeenIntroduction: hasSeenIntroduction));

      // Assert
      expect(find.byType(IntroductionAnimationScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('Displays HomeScreen when hasSeenIntroduction is true',
        (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({'hasSeenIntroduction': true});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasSeenIntroduction = prefs.getBool('hasSeenIntroduction') ?? false;

      // Act
      await tester.pumpWidget(MyApp(hasSeenIntroduction: hasSeenIntroduction));

      // Assert
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(IntroductionAnimationScreen), findsNothing);
    });
  });
}
