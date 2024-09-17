import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorPickerView extends StatefulWidget {
  final Function(Color) onColorSelected;
  final AnimationController animationController;
  final Color? selectedColor;
  final Color? savedColor;
  final Function onSaveColorPressed;
  final Function onShareColorPressed;

  const ColorPickerView({
    super.key,
    required this.onColorSelected,
    required this.animationController,
    required this.onSaveColorPressed,
    required this.onShareColorPressed,
    this.selectedColor,
    this.savedColor,
  });

  @override
  ColorPickerViewState createState() => ColorPickerViewState();
}

class ColorPickerViewState extends State<ColorPickerView> with TickerProviderStateMixin {
  String? _userName;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _buttonAnimationController;
  late final Animation<Offset> _buttonAnimation;

  Color? _savedColor;

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

  final List<Map<String, dynamic>> colorData = [
    {
      'color': const Color.fromARGB(255, 156, 31, 22),
      'gradient': const LinearGradient(
        colors: [Color.fromARGB(255, 163, 45, 37), Color.fromARGB(171, 56, 9, 5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Red',
    },
    {
      'color': const Color.fromRGBO(255, 152, 0, 1),
      'gradient': const LinearGradient(
        colors: [Color.fromRGBO(255, 115, 0, 1), Color.fromRGBO(83, 26, 0, 1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Orange',
    },
    {
      'color': const Color.fromARGB(255, 212, 193, 14),
      'gradient': const LinearGradient(
        colors: [Color.fromARGB(255, 255, 230, 0), Color.fromARGB(255, 116, 94, 0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Yellow',
    },
    {
      'color': const Color.fromARGB(255, 76, 175, 80),
      'gradient': const LinearGradient(
        colors: [Colors.green, Color.fromARGB(213, 24, 63, 26)],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Green',
    },
    {
      'color': const Color.fromARGB(255, 33, 150, 243),
      'gradient': const LinearGradient(
        colors: [Colors.blue, Color.fromARGB(255, 0, 59, 107)],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Blue',
    },
    {
      'color': const Color.fromARGB(255, 156, 39, 176),
      'gradient': const LinearGradient(
        colors: [Colors.purple, Color.fromARGB(255, 80, 0, 94)],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Purple',
    },
    {
      'color': const Color.fromRGBO(233, 30, 99, 1),
      'gradient': const LinearGradient(
        colors: [Color.fromARGB(255, 255, 41, 113), Color.fromARGB(255, 94, 14, 41)],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Pink',
    },
    {
      'color': const Color.fromRGBO(0, 150, 136, 1),
      'gradient': const LinearGradient(
        colors: [Colors.teal, Color.fromARGB(255, 0, 87, 78)],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Teal',
    },
  ];

  bool get isColorSaved => widget.selectedColor != null && widget.selectedColor == _savedColor;

  @override
  void initState() {
    super.initState();

    _savedColor = widget.savedColor;

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages();
      _startAnimations();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.animationController.forward(from: 0.0);
    });
  }

  @override
  void didUpdateWidget(ColorPickerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedColor != widget.selectedColor) {
      _startAnimations();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _fadeController.forward(from: 0.0);
    if (widget.selectedColor != null) {
      _buttonAnimationController.forward(from: 0.0);
    }
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
    });
  }

  void _preloadImages() {
    for (var imagePath in colorToImageMap.values) {
      precacheImage(AssetImage(imagePath), context);
    }
  }

  void _onColorTap(Color color) {
    final wasColorNull = widget.selectedColor == null;

    if (widget.selectedColor?.value != color.value) {
      setState(() {
        widget.onColorSelected(color);
      });
      if (wasColorNull) {
        _buttonAnimationController.forward(from: 0.0);
      }
      _fadeController.forward(from: 0.0);
    }

    // Update button visibility
    setState(() {});
  }

  Widget _buildColorMeaningText() {
    final selectedColor = widget.selectedColor;

    if (selectedColor == null) {
      return _buildFadeTransitionText(
        'Tip: Choose a color to get started!',
      );
    }

    final feelings = colorMeanings.entries
        .firstWhere(
          (entry) => entry.key.value == selectedColor.value,
          orElse: () => const MapEntry(Colors.transparent, ["", ""]),
        )
        .value;

    if (feelings.isEmpty) {
      return _buildFadeTransitionText(
        'No meaning found for this color.',
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

  Widget _buildFadeTransitionText(String text) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.white70,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = widget.selectedColor;
    final imagePath = selectedColor != null
        ? colorToImageMap[selectedColor] ??
            'assets/introduction_animation/white_paint.png'
        : 'assets/introduction_animation/white_paint.png';

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

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Image
          SlideTransition(
            position: welcomeImageAnimation,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 350, maxHeight: 350),
              child: Image.asset(
                imagePath,
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
                _buildColorPickerGrid(),
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
          // Save Color or Share Color Button
          if (widget.selectedColor != null)
            SlideTransition(
              position: _buttonAnimation,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isColorSaved
                    ? _buildShareColorButton()
                    : _buildSaveColorButton(),
              ),
            ),
          const SizedBox(height: 40.0),
        ],
      ),
    );
  }

  Widget _buildColorPickerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 45),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 15.0,
        childAspectRatio: 0.85,
      ),
      itemCount: colorData.length,
      itemBuilder: (context, index) {
        final color = colorData[index]['color'] as Color;
        final gradient = colorData[index]['gradient'] as LinearGradient;
        final colorName = colorData[index]['name'] as String;
        final isSelected = widget.selectedColor?.value == color.value;

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
                      ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 20, spreadRadius: 7)]
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
                            colors: [color, color.withOpacity(0.6)],
                          ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)))
                        : null,
                    color: isSelected ? null : Colors.white70,
                    shadows: isSelected
                        ? [Shadow(blurRadius: 15, color: color.withOpacity(0.6), offset: const Offset(0, 0))]
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
    );
  }

  ElevatedButton _buildSaveColorButton() {
    return ElevatedButton(
      key: const ValueKey('saveButton'),
      onPressed: () {
        widget.onSaveColorPressed();  // Save the color only when the button is pressed
        _onSaveColorPressed();
        _showColorSavedNotification(widget.selectedColor!);
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: widget.selectedColor,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
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
    );
  }

  ElevatedButton _buildShareColorButton() {
    return ElevatedButton(
      key: const ValueKey('shareButton'),
      onPressed: () {
        widget.onShareColorPressed(); // Navigate to Interaction View
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: widget.selectedColor,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        shadowColor: Colors.black,
      ),
      child: const Text(
        "Share Your Color!",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _onSaveColorPressed() {
    setState(() {
      _savedColor = widget.selectedColor;
    });
  }

  void _showColorSavedNotification(Color color) {
    late OverlayEntry overlayEntry;
    bool isRemoved = false;

    // To control the sliding and fading animations
    final offset = ValueNotifier<Offset>(Offset.zero);
    final opacity = ValueNotifier<double>(1.0);

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10, // Adjust for status bar
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              // Update the offset based on user's drag
              offset.value = Offset(offset.value.dx + details.delta.dx, 0);
            },
            onHorizontalDragEnd: (details) {
              if (offset.value.dx.abs() > 100) {
                // Remove the overlay if the drag is significant
                if (!isRemoved) {
                  overlayEntry.remove();
                  isRemoved = true;
                }
              } else {
                // Animate back to original position if drag was not enough
                offset.value = Offset.zero;
              }
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([offset, opacity]),
              builder: (context, child) {
                return Opacity(
                  opacity: opacity.value,
                  child: Transform.translate(
                    offset: offset.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color, // Use the selected color for the alert background
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 6.0)],
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
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      // Ensure the overlay is removed only once
      if (!isRemoved) {
        // Smooth fade-out effect before sliding out
        opacity.value = 0.0;
        offset.value = const Offset(300, 0); // Slide out to the right

        Future.delayed(const Duration(milliseconds: 300), () {
          overlayEntry.remove();
          isRemoved = true;
        });
      }
    });
  }
}
