import 'package:flutter/material.dart';

class WelcomeView extends StatelessWidget {
  final AnimationController animationController;
  final TextEditingController nameController;

  const WelcomeView({
    super.key,
    required this.animationController,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();

    final firstHalfAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
            .animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.6,
          0.8,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
    final secondHalfAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-1, 0))
            .animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.8,
          1.0,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    final welcomeFirstHalfAnimation =
        Tween<Offset>(begin: const Offset(2, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.6,
        0.8,
        curve: Curves.fastOutSlowIn,
      ),
    ));

    final welcomeImageAnimation =
        Tween<Offset>(begin: const Offset(4, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.6,
        0.8,
        curve: Curves.fastOutSlowIn,
      ),
    ));

    return GestureDetector(
      onTap: () {
        focusNode.unfocus(); // Unfocus the text field when tapping outside
      },
      child: SlideTransition(
        position: firstHalfAnimation,
        child: SlideTransition(
          position: secondHalfAnimation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: welcomeImageAnimation,
                  child: Container(
                    constraints:
                        const BoxConstraints(maxWidth: 350, maxHeight: 350),
                    child: Image.asset(
                      'assets/introduction_animation/welcome.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SlideTransition(
                  position: welcomeFirstHalfAnimation,
                  child: const Text(
                    "Welcome",
                    style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const Padding(
                  padding:
                      EdgeInsets.only(left: 64, right: 64, top: 16, bottom: 16),
                  child: Text(
                    "Discover your mood's color and brighten your day with our app.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 80, right: 80, top: 0, bottom: 0),
                  child: TextField(
                    controller: nameController,
                    focusNode: focusNode,
                    style: const TextStyle(color: Colors.white, fontSize: 14.0),
                    decoration: const InputDecoration(
                      labelText: "How should we call you?",
                      labelStyle: TextStyle(color: Colors.white70, fontSize: 14.5),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 138, 116, 199)),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 138, 116, 199)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
