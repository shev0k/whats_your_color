import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whats_your_color/themes/app_theme.dart';
import 'package:whats_your_color/components/views/home_screen_views/color_picker_view.dart';
import 'package:whats_your_color/components/top_navigation_bar.dart';
import 'package:whats_your_color/components/views/home_screen_views/interaction_view.dart';
import 'package:whats_your_color/components/views/home_screen_views/statistics_view.dart';
import 'package:whats_your_color/services/home_screen/user_service.dart';
import 'package:whats_your_color/services/home_screen/color_service.dart';
import 'package:whats_your_color/services/home_screen/heartbeat_service.dart';

// home screen widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

// state class for home screen
class HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  
  // animations and state variables
  late AnimationController _animationController;
  Color? selectedColor;
  bool isLoading = true;
  String currentView = 'colorPicker';
  String? userId;
  
  late UserService _userService;
  late ColorService _colorService;
  HeartbeatService? _heartbeatService;

  @override
  void initState() {
    super.initState();

    // setup lifecycle observer and animations
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // preload SharedPreferences synchronously
    SharedPreferences.getInstance().then((prefs) {
      _userService = UserService(prefs, baseUrl: 'https://whats-your-color.onrender.com');
      _colorService = ColorService(prefs, baseUrl: 'https://whats-your-color.onrender.com');
      _initData();
    });
  }

  Future<void> _initData() async {
    userId = await _userService.loadUserId();
    selectedColor = await _colorService.loadSelectedColor();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
      _animationController.forward(); // Start animation after data load

      if (userId != null) {
        await _userService.registerUser(userId, color: selectedColor);
        _heartbeatService = HeartbeatService(userId: userId!, baseUrl: 'https://whats-your-color.onrender.com');
        _heartbeatService?.startHeartbeat();
      } else {
        await _userService.registerUser(null, color: selectedColor);
        userId = await _userService.loadUserId();
      }

      if (selectedColor != null && userId != null) {
        await _colorService.sendColorToServer(selectedColor!, userId!);
      }
    }
  }


  @override
  void dispose() {
    // clean up observers, animations, and timers
    if (userId != null) {
      _userService.deregisterUser(userId!);
    }
    _heartbeatService?.stopHeartbeat();
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // handle app state changes
    if (state == AppLifecycleState.paused) {
      if (selectedColor != null && userId != null) {
        _colorService.saveSelectedColor(selectedColor!);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (selectedColor != null && userId != null) {
        _colorService.sendColorToServer(selectedColor!, userId!);
      }
    }
  }

  // handle color selection
  void _onColorSelected(Color color) {
    setState(() {
      selectedColor = color;  // update the selected color
    });
  }

  // handle save color button press
  void _onSaveColorPressed() async {
    if (selectedColor != null) {
      if (userId == null) {
        // Register the user for the first time
        await _userService.registerUser(null, color: selectedColor);
        userId = await _userService.loadUserId();
      }

      if (userId != null) {
        // Save and send the selected color after user registration
        await _colorService.saveSelectedColor(selectedColor!);
        await _colorService.sendColorToServer(selectedColor!, userId!);
      }
    }
  }


  // navigation callbacks for different views
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

  // build the main UI
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

  // build the current view based on navigation
  Widget _buildCurrentView() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 930),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // smooth transition between views
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        );

        final slideAnimation = Tween<Offset>(
          begin: const Offset(4.0, 0.0), // slide in from right
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

  // get the view to display based on the current navigation state
  Widget _getViewForCurrentView() {
    switch (currentView) {
      case 'interaction':
        return InteractionView(
          animationController: _animationController,
          selectedColor: selectedColor,
          key: ValueKey<String>(currentView),
        );
      case 'statistics':
        return StatisticsView(
          animationController: _animationController,
          key: ValueKey<String>(currentView),
        );
      default:
        return ColorPickerView(
          animationController: _animationController,
          onColorSelected: _onColorSelected,
          onSaveColorPressed: _onSaveColorPressed,
          selectedColor: selectedColor,
          key: ValueKey<String>(currentView),
        );
    }
  }
}
