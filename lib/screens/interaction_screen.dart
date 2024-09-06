import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InteractionScreen extends StatefulWidget {
  const InteractionScreen({super.key});

  @override
  InteractionScreenState createState() => InteractionScreenState();
}

class InteractionScreenState extends State<InteractionScreen> with SingleTickerProviderStateMixin {
  Color _selectedColor = Colors.white;
  String _interactionMessage = 'Touch another phone to compare colors!';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadColor();

    // Initialize the animation controller and animation for pulsing effect
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the animation controller when the widget is removed from the tree
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Color Interaction'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Adding the pulsing effect to the selected color
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              _interactionMessage,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(24),
              ),
              onPressed: _startNfcInteraction,
              child: const Icon(Icons.compare_arrows),
            ),
          ],
        ),
      ),
    );
  }

  void _loadColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? colorValue = prefs.getInt('selected_color');
    if (colorValue != null) {
      setState(() {
        _selectedColor = Color(colorValue);
      });
    }
  }

  void _startNfcInteraction() {
    // Placeholder for NFC logic
    setState(() {
      _interactionMessage = 'Colors compared! (Simulated)';
    });
  }
}
