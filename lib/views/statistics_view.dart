import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class StatisticsView extends StatefulWidget {
  final AnimationController animationController;

  const StatisticsView({Key? key, required this.animationController})
      : super(key: key);

  @override
  _StatisticsViewState createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  int activeUsers = 0;
  Map<String, int> colorSelections = {};
  bool isLoading = true;
  late WebSocketChannel channel;

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
    _connectToWebSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void _connectToWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.0.104:3000'),
    );

    channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['type'] == 'colorSelections') {
        setState(() {
          colorSelections = Map<String, int>.from(data['data']);
          isLoading = false;
        });
      } else if (data['type'] == 'activeUsers') {
        setState(() {
          activeUsers = data['data'];
          isLoading = false;
        });
      }
    }, onError: (error) {
      print('WebSocket error: $error');
    });
  }

  void _preloadImages() {
    final context = this.context;
    for (var imagePath in colorToImageMap.values) {
      precacheImage(AssetImage(imagePath), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = 'assets/introduction_animation/statistics_paint.png';

    String userText;
    if (activeUsers == 0) {
      userText = 'There is no user engaging with the app right now.';
    } else if (activeUsers == 1) {
      userText = 'There is 1 user engaging with the app right now.';
    } else {
      userText = 'There are $activeUsers users engaging with the app right now.';
    }

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
        'name': 'Red',
        'textColor': const Color.fromARGB(255, 226, 140, 140),
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
        'name': 'Orange',
        'textColor': const Color.fromRGBO(255, 218, 121, 1),
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
        'name': 'Yellow',
        'textColor': const Color.fromARGB(255, 255, 244, 153),
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
        'name': 'Green',
        'textColor': const Color.fromARGB(255, 173, 230, 181),
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
        'name': 'Blue',
        'textColor': const Color.fromARGB(255, 173, 218, 255),
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
        'name': 'Purple',
        'textColor': const Color.fromARGB(255, 218, 171, 229),
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
        'name': 'Pink',
        'textColor': const Color.fromARGB(255, 255, 185, 206),
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
        'name': 'Teal',
        'textColor': const Color.fromARGB(255, 154, 235, 224),
      },
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Image
          Container(
            constraints: const BoxConstraints(maxWidth: 350, maxHeight: 350),
            child: Image.asset(
              imagePath, // Display the selected color's image or default
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 30),
          // Total Users Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              userText,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 35),
          // Color Swatches with Numbers
          Column(
            children: [
              GridView.builder(
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
                  final textColor = colorData[index]['textColor'] as Color;
                  final colorName = colorData[index]['name'] as String;

                  // Convert color value to string key used in colorSelections
                  final colorKey = color.value.toString();

                  final userCount = colorSelections[colorKey] ?? 0;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: gradient,
                        ),
                        width: 50,
                        height: 50,
                        child: Center(
                          child: Text(
                            '$userCount',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Flexible(
                        child: Text(
                          colorName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 35),
              // Explanation Text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'The numbers on the color swatches represent the users who picked that color.',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(height: 40.0),
        ],
      ),
    );
  }
}
