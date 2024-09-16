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
    super.key,
    required this.animationController,
    required this.selectedColor,
  });

  @override
  _InteractionViewState createState() => _InteractionViewState();
}

class _InteractionViewState extends State<InteractionView> {
  final _flutterNfcHcePlugin = FlutterNfcHce();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _selectedColorHex = '#FFFFFF';
  bool _isNfcHceRunning = false;
  bool _isNfcReading = false;
  ValueNotifier<dynamic> _nfcResult = ValueNotifier(null);
  bool _isColorMatch = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedColor();
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
            prefs.getString('selected_color') ?? '#FFFFFF'; // Default to white
      });
    }
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
        _isNfcReading = false; // Ensure NFC reading is stopped
        _stopNfcReading(); // Stop reading if it's running
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
        _isNfcHceRunning = false; // Ensure NFC HCE is stopped
        _stopNfcHce(); // Stop HCE if it's running
      });

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final ndef = Ndef.from(tag);
          if (ndef == null) {
            _nfcResult.value = 'Tag is not NDEF formatted';
            return;
          }

          final payload = ndef.cachedMessage?.records.first.payload;

          if (payload != null && payload.isNotEmpty) {
            final message = utf8.decode(payload.sublist(3)); // skip first 3 bytes for encoding info
            _nfcResult.value = 'NFC Data: $message';

            setStateIfMounted(() {
              _isColorMatch = _selectedColorHex.toUpperCase() == message.toUpperCase();
              _playSound(_isColorMatch); // Play the appropriate sound
            });
          } else {
            _nfcResult.value = 'Empty payload';
            setStateIfMounted(() {
              _isColorMatch = false;
              _playSound(_isColorMatch); // Play the sad sound
            });
          }

          // Stop the NFC session after processing
          await NfcManager.instance.stopSession();

          // Prevent the NFC system app from launching again
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
    await _audioPlayer.stop(); // Stop any previous sound before playing a new one
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

  @override
  void dispose() {
    _stopNfcHce();
    _stopNfcReading();
    _audioPlayer.dispose(); // Dispose the audio player when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interaction View'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _toggleNfcHce,
              child: Text(_isNfcHceRunning ? 'Stop NFC HCE' : 'Start NFC HCE'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleNfcReading,
              child: Text(_isNfcReading ? 'Stop NFC Reading' : 'Start NFC Reading'),
            ),
            SizedBox(height: 20),
            ValueListenableBuilder<dynamic>(
              valueListenable: _nfcResult,
              builder: (context, value, _) => Text(
                value != null ? 'NFC Result: $value' : 'Waiting for NFC...',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _isNfcHceRunning
                  ? 'NFC HCE is running with value: $_selectedColorHex'
                  : 'NFC HCE is stopped',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              _isNfcReading ? 'NFC Reading is active' : 'NFC Reading is inactive',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Color Match: $_isColorMatch', // Display true/false based on color match
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
