import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String? _userName;
  Color _selectedColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadColor();
  }

  void _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 50.0), // Spacing for top alignment
            Text(
              'Welcome back, $_userName!',
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'What color do you feel like today?',
                  textStyle: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
              pause: const Duration(milliseconds: 500),
              displayFullTextOnTap: true,
            ),
            const SizedBox(height: 40.0),
            _buildColorOptions(),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                _storeColor(_selectedColor);
                // Implement your navigation to the Interaction screen
              },
              child: const Text('Save Color'),
            ),
            const SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOptions() {
    List<Map<String, dynamic>> colors = [
      {"name": "Red", "color": Colors.red},
      {"name": "Blue", "color": Colors.blue},
      {"name": "Green", "color": Colors.green},
      {"name": "Yellow", "color": Colors.yellow},
      {"name": "Orange", "color": Colors.orange},
      {"name": "Purple", "color": Colors.purple},
      {"name": "Pink", "color": Colors.pink},
      {"name": "Grey", "color": Colors.grey},
    ];

    return GridView.builder(
      shrinkWrap: true,
      itemCount: colors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 swatches per row
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        final colorItem = colors[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = colorItem['color'];
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorItem['color'],
                  shape: BoxShape.circle,
                  boxShadow: _selectedColor == colorItem['color']
                      ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            spreadRadius: 5,
                            blurRadius: 15,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                colorItem['name'],
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _storeColor(Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_color', color.value);
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
}
