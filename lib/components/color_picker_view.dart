import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorPickerView extends StatefulWidget {
  final Function(Color) onColorSelected;
  final AnimationController animationController;
  final Color? selectedColor; // Added to receive the selected color

  const ColorPickerView({
    Key? key,
    required this.onColorSelected,
    required this.animationController,
    this.selectedColor,
  }) : super(key: key);

  @override
  _ColorPickerViewState createState() => _ColorPickerViewState();
}

class _ColorPickerViewState extends State<ColorPickerView>
    with TickerProviderStateMixin {
  String? _userName;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _buttonAnimationController;
  late Animation<Offset> _buttonAnimation;

  final Map<Color, List<String>> colorMeanings = {
    const Color.fromARGB(255, 156, 31, 22): ["passionate", "full of energy"],
    Colors.orange: ["enthusiastic", "vibrant"],
    const Color.fromARGB(255, 212, 193, 14): ["cheerful", "optimistic"],
    Colors.green: ["balanced", "harmonious"],
    Colors.blue: ["calm", "trustworthy"],
    Colors.purple: ["creative", "wise"],
    Colors.pink: ["compassionate", "loving"],
    Colors.teal: ["refreshed", "rejuvenated"],
  };

  final Map<Color, String> colorToImageMap = {
    const Color.fromARGB(255, 156, 31, 22): 'assets/introduction_animation/red_paint.png',
    const Color.fromRGBO(255, 152, 0, 1): 'assets/introduction_animation/orange_paint.png',
    const Color.fromARGB(255, 212, 193, 14): 'assets/introduction_animation/yellow_paint.png',
    const Color.fromARGB(255, 76, 175, 80): 'assets/introduction_animation/green_paint.png',
    const Color.fromARGB(255, 33, 150, 243): 'assets/introduction_animation/blue_paint.png',
    const Color.fromARGB(255, 156, 39, 176): 'assets/introduction_animation/purple_paint.png',
    const Color.fromRGBO(233, 30, 99, 1): 'assets/introduction_animation/pink_paint.png',
    const Color.fromRGBO(0, 150, 136, 1): 'assets/introduction_animation/teal_paint.png',
  };

  @override
  void initState() {
    super.initState();

    // Initialize fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Initialize button animation controller
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonAnimation = Tween<Offset>(
      begin: const Offset(0, 5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.fastOutSlowIn,
    ));

    _loadUserName();

    // Preload images
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages();
      _startAnimations();
    });
  }

  // Start animations based on whether a color is selected
  void _startAnimations() {
    _fadeController.forward(from: 0.0);
    if (widget.selectedColor != null) {
      _buttonAnimationController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(ColorPickerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedColor != widget.selectedColor) {
      setState(() {
        _fadeController.forward(from: 0.0);
        if (widget.selectedColor != null) {
          _buttonAnimationController.forward(from: 0.0);
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  // Load user name from SharedPreferences
  void _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
    });
  }

  // Preload images to improve performance
  void _preloadImages() {
    final context = this.context;
    for (var imagePath in colorToImageMap.values) {
      precacheImage(AssetImage(imagePath), context);
    }
  }

  // Handle color tap events
  void _onColorTap(Color color) {
    final wasColorNull = widget.selectedColor == null;

    if (widget.selectedColor?.value != color.value) {
      widget.onColorSelected(color); // Notify parent to update the state

      if (wasColorNull) {
        _buttonAnimationController.forward(from: 0.0);
      }

      _fadeController.forward(from: 0.0);
    }
  }

  // Build the text that describes the meaning of the selected color
  Widget _buildColorMeaningText() {
    final selectedColor = widget.selectedColor;

    if (selectedColor == null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: const Text(
          'Tip: Choose a color to get started!',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Ensure the correct color key is used for matching
    final feelings = colorMeanings.entries
        .firstWhere(
          (entry) => entry.key.value == selectedColor.value,
          orElse: () => MapEntry(Colors.transparent, ["", ""]),
        )
        .value;

    if (feelings.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: const Text(
          'No meaning found for this color.',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final firstFeeling = feelings[0];
    final secondFeeling = feelings[1];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.white70,
          ),
          children: [
            const TextSpan(text: "You feel "),
            TextSpan(
              text: firstFeeling,
              style: TextStyle(
                color: selectedColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: " and "),
            TextSpan(
              text: secondFeeling,
              style: TextStyle(
                color: selectedColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: "."),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = widget.selectedColor;

    // Determine the correct image to display
    final imagePath = selectedColor != null
        ? colorToImageMap[selectedColor] ??
            'assets/introduction_animation/white_paint.png'
        : 'assets/introduction_animation/white_paint.png';

    // Animations with staggered timing
    final welcomeImageAnimation = Tween<Offset>(
      begin: const Offset(4, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.0, 0.2, curve: Curves.fastOutSlowIn),
    ));

    final welcomeTextAnimation = Tween<Offset>(
      begin: const Offset(2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.1, 0.3, curve: Curves.fastOutSlowIn),
    ));

    final colorPickerAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.2, 0.4, curve: Curves.fastOutSlowIn),
    ));

    final colorData = [
      {
        'color': const Color.fromARGB(255, 156, 31, 22),
        'gradient': const LinearGradient(
          colors: [
            Color.fromARGB(255, 163, 45, 37),
            Color.fromARGB(171, 56, 9, 5)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
        'name': 'Red'
      },
      {
        'color': const Color.fromRGBO(255, 152, 0, 1),
        'gradient': const LinearGradient(
          colors: [
            Color.fromRGBO(255, 115, 0, 1),
            Color.fromRGBO(83, 26, 0, 1)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
        'name': 'Orange'
      },
      {
        'color': const Color.fromARGB(255, 212, 193, 14),
        'gradient': const LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 230, 0),
            Color.fromARGB(255, 116, 94, 0)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
        'name': 'Yellow'
      },
      {
        'color': const Color.fromARGB(255, 76, 175, 80),
        'gradient': const LinearGradient(
          colors: [
            Colors.green,
            Color.fromARGB(213, 24, 63, 26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
        'name': 'Green'
      },
      {
        'color': const Color.fromARGB(255, 33, 150, 243),
        'gradient': const LinearGradient(
          colors: [
            Colors.blue,
            Color.fromARGB(255, 0, 59, 107),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
        'name': 'Blue'
      },
      {
        'color': const Color.fromARGB(255, 156, 39, 176),
        'gradient': const LinearGradient(
          colors: [
            Colors.purple,
            Color.fromARGB(255, 80, 0, 94),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
        'name': 'Purple'
      },
      {
        'color': const Color.fromRGBO(233, 30, 99, 1),
        'gradient': const LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 41, 113),
            Color.fromARGB(255, 94, 14, 41),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
        'name': 'Pink'
      },
      {
        'color': const Color.fromRGBO(0, 150, 136, 1),
        'gradient': const LinearGradient(
          colors: [
            Colors.teal,
            Color.fromARGB(255, 0, 87, 78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
        'name': 'Teal'
      },
    ];

    return Padding(
      padding:
          const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Image
          SlideTransition(
            position: welcomeImageAnimation,
            child: Container(
              constraints:
                  const BoxConstraints(maxWidth: 350, maxHeight: 350),
              child: Image.asset(
                imagePath, // Display the selected color's image or default
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 27),
          // Question Text
          SlideTransition(
            position: welcomeTextAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'What color do you feel like today, $_userName?',
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Color Picker Swatches
          SlideTransition(
            position: colorPickerAnimation,
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: colorData.length,
                  itemBuilder: (context, index) {
                    final color = colorData[index]['color'] as Color;
                    final gradient =
                        colorData[index]['gradient'] as LinearGradient;
                    final colorName = colorData[index]['name'] as String;
                    final isSelected =
                        widget.selectedColor?.value == color.value;

                    return GestureDetector(
                      onTap: () => _onColorTap(color),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: gradient,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.6),
                                        blurRadius: 20,
                                        spreadRadius: 7,
                                      ),
                                    ]
                                  : [],
                            ),
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(height: 5),
                          Flexible(
                            child: Text(
                              colorName,
                              style: TextStyle(
                                fontSize: 12,
                                foreground: isSelected
                                    ? (Paint()
                                      ..shader = LinearGradient(
                                        colors: [
                                          color,
                                          color.withOpacity(0.6)
                                        ],
                                      ).createShader(const Rect.fromLTWH(
                                          0.0, 0.0, 200.0, 70.0)))
                                    : null,
                                color: isSelected ? null : Colors.white70,
                                shadows: isSelected
                                    ? [
                                        Shadow(
                                          blurRadius: 15,
                                          color: color.withOpacity(0.6),
                                          offset: const Offset(0, 0),
                                        ),
                                      ]
                                    : [],
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Color Meaning Text
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildColorMeaningText(),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Save Color Button
          if (widget.selectedColor != null)
            SlideTransition(
              position: _buttonAnimation,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.selectedColor != null) {
                    _showColorSavedNotification(widget.selectedColor!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: widget.selectedColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  shadowColor: Colors.black,
                ),
                child: const Text(
                  "Save Color",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 40.0),
        ],
      ),
    );
  }

  // Show an overlay notification when the color is saved
  void _showColorSavedNotification(Color color) {
    // Show an overlay notification with the selected color
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
              color: color, // Use the selected color for the alert background
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
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Color saved successfully.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Remove the overlay after a few seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
