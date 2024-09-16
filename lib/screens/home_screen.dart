import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats_your_color/themes/app_theme.dart';
import 'package:whats_your_color/components/color_picker_view.dart';
import 'package:whats_your_color/components/top_navigation_bar.dart';
import 'package:whats_your_color/views/interaction_view.dart';
import 'package:whats_your_color/views/statistics_view.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late AnimationController _animationController;
  Color? selectedColor;
  bool isLoading = true;
  String currentView = 'colorPicker';
  String? userId;
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _loadUserId();
    _loadSelectedColor();
    _animationController.forward();

    _startHeartbeat();
  }

  @override
  void dispose() {
    _deregisterUser();
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _stopHeartbeat();
    super.dispose();
  }

  void _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUserId = prefs.getString('user_id');

    if (savedUserId != null) {
      userId = savedUserId;
      _registerUser(userId!);
    } else {
      _registerUser();
    }
  }

  void _registerUser([String? existingUserId]) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.104:3000/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': existingUserId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userId = data['userId'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId!);
      }
    } catch (e) {
      print('Failed to register user: $e');
    }
  }

  void _deregisterUser() async {
    if (userId == null) return;

    try {
      await http.post(
        Uri.parse('http://192.168.0.104:3000/api/deregister'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
    } catch (e) {
      print('Failed to deregister user: $e');
    }
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

    if (selectedColor != null && userId != null) {
      _sendColorToServer(selectedColor!, userId!);
    }
  }

  void _saveSelectedColor(Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_color', color.value);
  }

  void _sendColorToServer(Color color, String userId) async {
    try {
      await http.post(
        Uri.parse('http://192.168.0.104:3000/api/color'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'color': color.value.toString()}),
      );
    } catch (e) {
      print('Failed to send color to server: $e');
    }
  }

  void _sendHeartbeat() async {
    if (userId == null) return;

    try {
      await http.post(
        Uri.parse('http://192.168.0.104:3000/api/heartbeat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
    } catch (e) {
      print('Failed to send heartbeat: $e');
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _sendHeartbeat();
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
  }

  void _onColorSelected(Color color) {
    setState(() {
      selectedColor = color;  // Visually update the selected color
    });
  }

  void _onSaveColorPressed() {
    if (selectedColor != null && userId != null) {
      _saveSelectedColor(selectedColor!);
      _sendColorToServer(selectedColor!, userId!);
    }
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 930),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Adding a CurvedAnimation with an interval
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        );

        final slideAnimation = Tween<Offset>(
          begin: const Offset(4.0, 0.0), // Slide in from right
          end: Offset.zero,
        ).animate(curvedAnimation);

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
      child: _getViewForCurrentView(),
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
    );
  }

  Widget _getViewForCurrentView() {
    switch (currentView) {
      case 'interaction':
        return InteractionView(
          animationController: _animationController,
          selectedColor: selectedColor,
          key: ValueKey<String>(currentView), // Provide a unique key for each view
        );
      case 'statistics':
        return StatisticsView(
          animationController: _animationController,
          key: ValueKey<String>(currentView), // Provide a unique key for each view
        );
      default:
        return ColorPickerView(
          animationController: _animationController,
          onColorSelected: _onColorSelected,
          onSaveColorPressed: _onSaveColorPressed,
          selectedColor: selectedColor,
          key: ValueKey<String>(currentView), // Provide a unique key for each view
        );
    }
  }
}
