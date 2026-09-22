import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class RoomSensorData {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final double signalStrengthDbm; // RSSI or simulated room proximity signal (-30 dBm to -95 dBm)
  final String roomZone;
  final DateTime lastSeen;

  const RoomSensorData({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.signalStrengthDbm,
    required this.roomZone,
    required this.lastSeen,
  });

  String get proximityStatus {
    if (signalStrengthDbm >= -45) return 'Very Close (Under cushions / Near couch)';
    if (signalStrengthDbm >= -65) return 'Same Room (In range < 3m)';
    if (signalStrengthDbm >= -80) return 'Nearby Room / Hallway';
    return 'Weak Signal / Far away';
  }

  double get proximityNormalized {
    // Normalizes -95 (0.0) to -35 (1.0)
    final clamped = signalStrengthDbm.clamp(-95.0, -35.0);
    return (clamped - (-95.0)) / 60.0;
  }
}

class FinderBeaconService extends ChangeNotifier {
  HttpServer? _server;
  String _localIp = '127.0.0.1';
  int _port = 8888;
  bool _isRinging = false;
  Timer? _alarmTimer;
  Timer? _soundPulseTimer;
  int _ringSecondsLeft = 0;

  // Sensor state
  RoomSensorData _sensorData = RoomSensorData(
    latitude: 28.6139, // Default sample coordinate
    longitude: 77.2090,
    accuracyMeters: 3.5,
    signalStrengthDbm: -52.0,
    roomZone: 'Living Room (Near Couch)',
    lastSeen: DateTime.now(),
  );

  bool get isRinging => _isRinging;
  int get ringSecondsLeft => _ringSecondsLeft;
  String get localIp => _localIp;
  int get port => _port;
  String get webBeaconUrl => 'http://$_localIp:$_port';
  RoomSensorData get sensorData => _sensorData;

  FinderBeaconService() {
    _initNetworkAndServer();
    _startPeriodicSensorUpdates();
  }

  Future<void> _initNetworkAndServer() async {
    try {
      // Find local Wi-Fi IP address
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback && !addr.isLinkLocal) {
            _localIp = addr.address;
            break;
          }
        }
      }

      // Start embedded HTTP server
      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
      _server!.listen(_handleHttpRequest);
      notifyListeners();
      if (kDebugMode) {
        print('Finder Beacon Server running at http://$_localIp:$_port');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Could not start Finder Beacon Server: $e');
      }
    }
  }

  void _handleHttpRequest(HttpRequest request) async {
    final response = request.response;
    response.headers.contentType = ContentType.html;

    if (request.uri.path == '/ring' || (request.method == 'POST' && request.uri.path == '/ring')) {
      triggerAlarm(durationSeconds: 30);
      response.write('''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>Remote Ringing!</title>
          <style>
            body { background: #0b0f19; color: #fff; font-family: system-ui, sans-serif; text-align: center; padding: 40px 20px; }
            .btn { background: #ff1744; color: #fff; padding: 18px 36px; border-radius: 50px; text-decoration: none; font-size: 20px; font-weight: bold; display: inline-block; margin-top: 24px; box-shadow: 0 0 20px rgba(255,23,68,0.6); }
            .stop { background: #374151; box-shadow: none; margin-left: 10px; }
          </style>
        </head>
        <body>
          <h1 style="color: #00E676;">🔔 Ringing Lost Remote!</h1>
          <p>Your TV remote is now sounding a loud alarm, vibrating, and strobing.</p>
          <a class="btn" href="/ring">Ring Again</a>
          <a class="btn stop" href="/stop">Stop Alarm</a>
          <br><br>
          <a href="/" style="color: #00E5FF; text-decoration: none;">&larr; Back to Radar Status</a>
        </body>
        </html>
      ''');
      await response.close();
      return;
    }

    if (request.uri.path == '/stop') {
      stopAlarm();
      response.redirect(Uri.parse('/'));
      await response.close();
      return;
    }

    // Default status dashboard
    response.write('''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>RemoteOne • Lost Remote Finder</title>
        <style>
          body { background: #0b0f19; color: #e2e8f0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; text-align: center; padding: 30px 16px; margin: 0; }
          .card { background: #151d30; border: 1px solid #1e293b; border-radius: 20px; padding: 24px; max-width: 440px; margin: 0 auto; box-shadow: 0 10px 25px rgba(0,0,0,0.5); }
          .title { font-size: 24px; font-weight: 800; color: #00E5FF; margin-bottom: 8px; }
          .subtitle { font-size: 14px; color: #94a3b8; margin-bottom: 24px; }
          .ring-btn { display: block; width: 85%; margin: 0 auto 20px; background: linear-gradient(135deg, #ff1744, #d500f9); color: white; padding: 20px; border-radius: 50px; font-size: 22px; font-weight: 900; text-decoration: none; box-shadow: 0 0 30px rgba(255,23,68,0.5); letter-spacing: 1px; }
          .ring-btn:active { transform: scale(0.98); }
          .stat { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid #1e293b; font-size: 14px; text-align: left; }
          .stat-val { font-weight: bold; color: #fff; text-align: right; }
          .badge { display: inline-block; background: #00E676; color: #000; font-weight: 800; font-size: 11px; padding: 4px 10px; border-radius: 20px; }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="title">Find My Remote</div>
          <div class="subtitle">RemoteOne Active WiFi Beacon</div>
          
          <a class="ring-btn" href="/ring">🚨 RING REMOTE NOW</a>
          
          <div class="stat">
            <span style="color: #94a3b8;">Status</span>
            <span class="stat-val"><span class="badge">LISTENING IN ROOM</span></span>
          </div>
          <div class="stat">
            <span style="color: #94a3b8;">Estimated Room Zone</span>
            <span class="stat-val">\${_sensorData.roomZone}</span>
          </div>
          <div class="stat">
            <span style="color: #94a3b8;">Signal Proximity</span>
            <span class="stat-val" style="color: #00E5FF;">\${_sensorData.proximityStatus}</span>
          </div>
          <div class="stat">
            <span style="color: #94a3b8;">GPS Coordinates</span>
            <span class="stat-val">\${_sensorData.latitude.toStringAsFixed(4)}&deg; N, \${_sensorData.longitude.toStringAsFixed(4)}&deg; E</span>
          </div>
          <div class="stat">
            <span style="color: #94a3b8;">Location Accuracy</span>
            <span class="stat-val">&plusmn;\${_sensorData.accuracyMeters.toStringAsFixed(1)} m</span>
          </div>
          <div class="stat">
            <span style="color: #94a3b8;">Last Seen Active</span>
            <span class="stat-val">\${_sensorData.lastSeen.hour.toString().padLeft(2, '0')}:\${_sensorData.lastSeen.minute.toString().padLeft(2, '0')}</span>
          </div>
        </div>
      </body>
      </html>
    ''');
    await response.close();
  }

  void _startPeriodicSensorUpdates() {
    // Periodically update sensor & signal readings to simulate room proximity variations
    Timer.periodic(const Duration(seconds: 4), (timer) {
      final now = DateTime.now();
      // Slight sensor jitter simulating room RF signal variations
      final jitter = (now.second % 6) - 3.0;
      final newRssi = (-52.0 + jitter).clamp(-90.0, -35.0);

      _sensorData = RoomSensorData(
        latitude: _sensorData.latitude,
        longitude: _sensorData.longitude,
        accuracyMeters: 3.0 + ((now.second % 4) * 0.3),
        signalStrengthDbm: newRssi,
        roomZone: newRssi >= -50 ? 'Living Room (Under Sofa / Cushions)' : 'Living Room (Coffee Table)',
        lastSeen: now,
      );
      notifyListeners();
    });
  }

  void updateGpsCoordinates({required double lat, required double lng, double accuracy = 3.0}) {
    _sensorData = RoomSensorData(
      latitude: lat,
      longitude: lng,
      accuracyMeters: accuracy,
      signalStrengthDbm: _sensorData.signalStrengthDbm,
      roomZone: _sensorData.roomZone,
      lastSeen: DateTime.now(),
    );
    notifyListeners();
  }

  void triggerAlarm({int durationSeconds = 30}) {
    if (_isRinging) return;
    _isRinging = true;
    _ringSecondsLeft = durationSeconds;
    notifyListeners();

    // Sound pulses and haptics
    _soundPulseTimer?.cancel();
    _soundPulseTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (!_isRinging) {
        timer.cancel();
        return;
      }
      // Play audible alert sound
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.heavyImpact();
    });

    // Countdown timer
    _alarmTimer?.cancel();
    _alarmTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _ringSecondsLeft--;
      if (_ringSecondsLeft <= 0) {
        stopAlarm();
      } else {
        notifyListeners();
      }
    });
  }

  void stopAlarm() {
    _isRinging = false;
    _ringSecondsLeft = 0;
    _soundPulseTimer?.cancel();
    _alarmTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _soundPulseTimer?.cancel();
    _alarmTimer?.cancel();
    _server?.close();
    super.dispose();
  }
}
