import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_hce/flutter_nfc_hce.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class InteractionView extends StatefulWidget {
  final AnimationController animationController;
  final Color? selectedColor;

  const InteractionView({
    Key? key,
    required this.animationController,
    required this.selectedColor,
  }) : super(key: key);

  @override
  _InteractionViewState createState() => _InteractionViewState();
}

class _InteractionViewState extends State<InteractionView>
    with TickerProviderStateMixin {
  final _flutterNfcHcePlugin = FlutterNfcHce();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _selectedColorHex = '#FFFFFF';
  bool _isNfcHceRunning = false;
  bool _isNfcReading = false;
  bool _isColorMatch = false;
  bool _hasRead = false;
  Color? _otherColor;

  late AnimationController _pulsateController;
  late Animation<double> _pulsateAnimation;

  late AnimationController _colorCycleController;
  late Animation<Color?> _colorCycleAnimation;

  final List<Map<String, dynamic>> colorData = [
    {
      'color': Color.fromARGB(255, 156, 31, 22),
      'gradient': LinearGradient(
        colors: [
          Color.fromARGB(255, 163, 45, 37),
          Color.fromARGB(171, 56, 9, 5)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Red',
    },
    {
      'color': Color.fromRGBO(255, 152, 0, 1),
      'gradient': LinearGradient(
        colors: [
          Color.fromRGBO(255, 115, 0, 1),
          Color.fromRGBO(83, 26, 0, 1)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Orange',
    },
    {
      'color': Color.fromARGB(255, 212, 193, 14),
      'gradient': LinearGradient(
        colors: [
          Color.fromARGB(255, 255, 230, 0),
          Color.fromARGB(255, 116, 94, 0)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Yellow',
    },
    {
      'color': Color.fromARGB(255, 76, 175, 80),
      'gradient': LinearGradient(
        colors: [Colors.green, Color.fromARGB(213, 24, 63, 26)],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Green',
    },
    {
      'color': Color.fromARGB(255, 33, 150, 243),
      'gradient': LinearGradient(
        colors: [Colors.blue, Color.fromARGB(255, 0, 59, 107)],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Blue',
    },
    {
      'color': Color.fromARGB(255, 156, 39, 176),
      'gradient': LinearGradient(
        colors: [Colors.purple, Color.fromARGB(255, 80, 0, 94)],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Purple',
    },
    {
      'color': Color.fromRGBO(233, 30, 99, 1),
      'gradient': LinearGradient(
        colors: [
          Color.fromARGB(255, 255, 41, 113),
          Color.fromARGB(255, 94, 14, 41)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Pink',
    },
    {
      'color': Color.fromRGBO(0, 150, 136, 1),
      'gradient': LinearGradient(
        colors: [Colors.teal, Color.fromARGB(255, 0, 87, 78)],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
      ),
      'name': 'Teal',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedColor();

    _pulsateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _pulsateAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulsateController, curve: Curves.easeInOut),
    );

    _colorCycleController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );

    _colorCycleAnimation = _colorCycleController.drive(
      TweenSequence<Color?>(
        [
          TweenSequenceItem(
            tween: ColorTween(begin: Colors.red, end: Colors.orange),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: ColorTween(begin: Colors.orange, end: Colors.yellow),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: ColorTween(begin: Colors.yellow, end: Colors.green),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: ColorTween(begin: Colors.green, end: Colors.cyan),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: ColorTween(begin: Colors.cyan, end: Colors.blue),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: ColorTween(begin: Colors.blue, end: Colors.purple),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: ColorTween(begin: Colors.purple, end: Colors.red),
            weight: 1,
          ),
        ],
      ),
    );

    _startColorCycling();
  }

  Future<void> _loadSelectedColor() async {
    if (widget.selectedColor != null) {
      setStateIfMounted(() {
        _selectedColorHex =
            '#${widget.selectedColor!.value.toRadixString(16).substring(2).toUpperCase()}';
      });
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setStateIfMounted(() {
        _selectedColorHex =
            prefs.getString('selected_color') ?? '#FFFFFF';
      });
    }
  }

  void _startColorCycling() {
    _colorCycleController.repeat();
  }

  void _stopColorCycling() {
    _colorCycleController.stop();
  }

  Future<void> _toggleNfcHce() async {
    if (_isNfcHceRunning) {
      await _stopNfcHce();
    } else {
      await _startNfcHce();
    }
  }

  Future<void> _startNfcHce() async {
    if (!_isNfcHceRunning) {
      var result = await _flutterNfcHcePlugin.startNfcHce(_selectedColorHex);
      print('NFC HCE started with result: $result');

      setStateIfMounted(() {
        _isNfcHceRunning = true;
        _isNfcReading = false;
        _stopNfcReading();
      });
    }
  }

  Future<void> _stopNfcHce() async {
    if (_isNfcHceRunning) {
      await _flutterNfcHcePlugin.stopNfcHce();
      setStateIfMounted(() {
        _isNfcHceRunning = false;
      });
    }
  }

  Future<void> _toggleNfcReading() async {
    if (_isNfcReading) {
      await _stopNfcReading();
    } else {
      await _startNfcReading();
    }
  }

  Future<void> _startNfcReading() async {
    if (!_isNfcReading) {
      setStateIfMounted(() {
        _isNfcReading = true;
        _isNfcHceRunning = false;
        _stopNfcHce();
        _hasRead = false;
      });

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final ndef = Ndef.from(tag);
          if (ndef == null) {
            _showErrorMessage('Tag is not NDEF formatted');
            return;
          }

          final payload = ndef.cachedMessage?.records.first.payload;

          if (payload != null && payload.isNotEmpty) {
            final message =
                utf8.decode(payload.sublist(3));

            if (_isValidHexColor(message)) {
              setStateIfMounted(() {
                _otherColor = Color(int.parse(message.substring(1), radix: 16) + 0xFF000000);
                _isColorMatch =
                    _selectedColorHex.toUpperCase() == message.toUpperCase();
                _hasRead = true;
                _playSound(_isColorMatch);
                _stopColorCycling();
              });
            } else {
              _showErrorMessage('Invalid color data received.');
            }
          } else {
            _showErrorMessage('Empty payload received.');
          }

          await NfcManager.instance.stopSession();
          await _preventNfcSystemApp();

          setStateIfMounted(() {
            _isNfcReading = false;
          });
        },
      );
    }
  }

  Future<void> _stopNfcReading() async {
    if (_isNfcReading) {
      await NfcManager.instance.stopSession();
      setStateIfMounted(() {
        _isNfcReading = false;
      });
    }
  }

  Future<void> _playSound(bool isMatch) async {
    await _audioPlayer.stop();
    if (isMatch) {
      await _audioPlayer.play(AssetSource('sounds/happy_sound.mp3'));
    } else {
      await _audioPlayer.play(AssetSource('sounds/sad_sound.mp3'));
    }
  }

  Future<void> _preventNfcSystemApp() async {
    NfcManager.instance.startSession(onDiscovered: (_) async {
      return;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    await NfcManager.instance.stopSession();
  }

  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  bool _isValidHexColor(String color) {
    final hexColorRegExp = RegExp(r'^#[0-9A-Fa-f]{6}$');
    return hexColorRegExp.hasMatch(color);
  }

  void _showErrorMessage(String message) {
    setStateIfMounted(() {
      _hasRead = true;
      _isColorMatch = false;
      _otherColor = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    _stopNfcHce();
    _stopNfcReading();
    _audioPlayer.dispose();
    _pulsateController.dispose();
    _colorCycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Color(
        int.parse(_selectedColorHex.substring(1), radix: 16) + 0xFF000000);

    final selectedGradient = colorData.firstWhere(
      (element) => element['color'].value == selectedColor.value,
      orElse: () => {
        'gradient': LinearGradient(
          colors: [selectedColor, selectedColor.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
      },
    )['gradient'] as LinearGradient;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 20),

          ScaleTransition(
            scale: _pulsateAnimation,
            child: GestureDetector(
              onTap: _toggleNfcHce,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: selectedGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: selectedColor.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      _isNfcHceRunning ? Icons.stop : Icons.send,
                      color: const Color.fromARGB(166, 255, 255, 255),
                      size: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),

          Container(
            height: 60,
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _hasRead
                  ? RichText(
                      key: ValueKey<bool>(_isColorMatch),
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Colors ',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                        children: [
                          TextSpan(
                            text: _isColorMatch ? 'match' : 'do not match',
                            style: TextStyle(
                              color: _isColorMatch
                                  ? selectedColor
                                  : (_otherColor ?? Colors.white),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: _isColorMatch
                                ? '! You share the same vibe.'
                                : '. You don\'t share the same vibe.',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      _isNfcReading
                          ? "Receiving color... Tap phones."
                          : _isNfcHceRunning
                              ? "Sending color... Tap phones."
                              : "Tap the circles to share or receive colors with other users!",
                      key: ValueKey<String>(
                          _isNfcReading || _isNfcHceRunning ? 'status' : 'instruction'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          const SizedBox(height: 30),

          AnimatedBuilder(
            animation: _colorCycleAnimation,
            builder: (context, child) {
              Color currentColor =
                  _otherColor ?? (_colorCycleAnimation.value ?? Colors.blue);

              final currentGradient = _otherColor != null
                  ? colorData.firstWhere(
                      (element) => element['color'].value == currentColor.value,
                      orElse: () => {
                            'gradient': LinearGradient(
                              colors: [currentColor, currentColor.withOpacity(0.6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomCenter,
                            ),
                          },
                    )['gradient'] as LinearGradient
                  : LinearGradient(
                      colors: [
                        currentColor,
                        currentColor.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomCenter,
                    );

              IconData currentIcon = _isNfcReading ? Icons.stop : Icons.download;

              return ScaleTransition(
                scale: _pulsateAnimation,
                child: GestureDetector(
                  onTap: _toggleNfcReading,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: currentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: currentColor.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          currentIcon,
                          color: const Color.fromARGB(164, 255, 255, 255),
                          size: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
