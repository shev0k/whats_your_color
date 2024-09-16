import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HeartbeatService {
  final String userId;
  final String baseUrl;
  Timer? _heartbeatTimer;

  HeartbeatService({required this.userId, required this.baseUrl});

  void startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _sendHeartbeat();
    });
  }

  void stopHeartbeat() {
    _heartbeatTimer?.cancel();
  }

  Future<void> _sendHeartbeat() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/api/heartbeat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
    } catch (e) {
      // no-op
    }
  }
}
