// home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats_your_color/themes/app_theme.dart';
import 'package:whats_your_color/components/color_picker_view.dart';
import 'package:whats_your_color/components/top_navigation_bar.dart';
import 'package:whats_your_color/views/interaction_view.dart';
import 'package:whats_your_color/views/statistics_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  Color? selectedColor;
  bool isLoading = true;
  String currentView = 'colorPicker'; // Track the current view

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _loadSelectedColor();
    _animationController.forward();
  }

  void _loadSelectedColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedColorValue = prefs.getInt('selected_color');
    setState(() {
      if (savedColorValue != null) {
        selectedColor = Color(savedColorValue);
      }
      isLoading = false;
    });
  }

  void _saveSelectedColor(Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_color', color.value);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onColorSelected(Color color) {
    setState(() {
      selectedColor = color;
    });
    _saveSelectedColor(color);
  }

  // Navigation callbacks
  void _navigateToInteraction() {
    setState(() {
      currentView = 'interaction';
    });
  }

  void _navigateToStatistics() {
    setState(() {
      currentView = 'statistics';
    });
  }

  void _navigateBack() {
    setState(() {
      currentView = 'colorPicker';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.nearlyBlack,
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        backgroundColor: AppTheme.nearlyBlack,
        appBar: TopNavigationBar(
          onBackPressed: _navigateBack,
          onInteractionPressed: _navigateToInteraction,
          onStatisticsPressed: _navigateToStatistics,
          showBackButton: currentView != 'colorPicker',
        ),
        body: _buildCurrentView(),
      );
    }
  }

  Widget _buildCurrentView() {
    switch (currentView) {
      case 'interaction':
        return InteractionView(
          animationController: _animationController,
          selectedColor: selectedColor,
        );
      case 'statistics':
        return const StatisticsView(); // Placeholder view
      default:
        return ColorPickerView(
          animationController: _animationController,
          onColorSelected: _onColorSelected,
          selectedColor: selectedColor,
        );
    }
  }
}
