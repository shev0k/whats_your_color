import 'package:whats_your_color/themes/app_theme.dart';
import '../components/care_view.dart';
import '../components/center_next_button.dart';
import '../components/mood_diary_vew.dart';
import '../components/relax_view.dart';
import '../components/splash_view.dart';
import '../components/top_back_skip_view.dart';
import '../components/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats_your_color/screens/home_screen.dart';

class IntroductionAnimationScreen extends StatefulWidget {
  const IntroductionAnimationScreen({super.key});

  @override
  IntroductionAnimationScreenState createState() =>
      IntroductionAnimationScreenState();
}

class IntroductionAnimationScreenState
    extends State<IntroductionAnimationScreen> with TickerProviderStateMixin {
  AnimationController? _animationController;
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8));
    _animationController?.animateTo(0.0);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _nameController.dispose();
    super.dispose();
  }

void _signUpClick() async {
  String name = _nameController.text;
  if (name.isNotEmpty) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setBool('hasSeenIntroduction', true);

    // Navigate to the HomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } else {
    // Show a prettier error or warning from the top
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10, // Adjust for status bar
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 138, 116, 199),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Please enter your name.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert the OverlayEntry into the Overlay
    Overlay.of(context).insert(overlayEntry);

    // Remove the overlay after a few seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nearlyBlack,
      resizeToAvoidBottomInset: false,
      body: ClipRect(
        child: Stack(
          children: [
            SplashView(
              animationController: _animationController!,
            ),
            RelaxView(
              animationController: _animationController!,
            ),
            CareView(
              animationController: _animationController!,
            ),
            MoodDiaryVew(
              animationController: _animationController!,
            ),
            WelcomeView(
              animationController: _animationController!,
              nameController: _nameController,
            ),
            TopBackSkipView(
              onBackClick: _onBackClick,
              onSkipClick: _onSkipClick,
              animationController: _animationController!,
            ),
            CenterNextButton(
              animationController: _animationController!,
              onNextClick: () {
                if (_animationController!.value > 0.6 &&
                    _animationController!.value <= 0.8) {
                  _signUpClick();
                } else {
                  _onNextClick();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onSkipClick() {
    _animationController?.animateTo(0.8,
        duration: const Duration(milliseconds: 1200));
  }

  void _onBackClick() {
    if (_animationController!.value >= 0 &&
        _animationController!.value <= 0.2) {
      _animationController?.animateTo(0.0);
    } else if (_animationController!.value > 0.2 &&
        _animationController!.value <= 0.4) {
      _animationController?.animateTo(0.2);
    } else if (_animationController!.value > 0.4 &&
        _animationController!.value <= 0.6) {
      _animationController?.animateTo(0.4);
    } else if (_animationController!.value > 0.6 &&
        _animationController!.value <= 0.8) {
      _animationController?.animateTo(0.6);
    } else if (_animationController!.value > 0.8 &&
        _animationController!.value <= 1.0) {
      _animationController?.animateTo(0.8);
    }
  }

  void _onNextClick() {
    if (_animationController!.value >= 0 &&
        _animationController!.value <= 0.2) {
      _animationController?.animateTo(0.4);
    } else if (_animationController!.value > 0.2 &&
        _animationController!.value <= 0.4) {
      _animationController?.animateTo(0.6);
    } else if (_animationController!.value > 0.4 &&
        _animationController!.value <= 0.6) {
      _animationController?.animateTo(0.8);
    }
  }
}
