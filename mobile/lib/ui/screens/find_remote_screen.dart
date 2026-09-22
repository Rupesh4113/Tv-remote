import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/finder_beacon_service.dart';

class FindRemoteScreen extends StatefulWidget {
  const FindRemoteScreen({super.key});

  @override
  State<FindRemoteScreen> createState() => _FindRemoteScreenState();
}

class _FindRemoteScreenState extends State<FindRemoteScreen> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finder = Provider.of<FinderBeaconService>(context);
    final sensor = finder.sensorData;
    final isRinging = finder.isRinging;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find My Remote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'How Finder Works',
            onPressed: () => _showHowItWorksDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Radar Visualizer Box
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isRinging ? Colors.redAccent : const Color(0xFF00E5FF).withOpacity(0.3),
                  width: isRinging ? 2.5 : 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated Radar Rings
                  AnimatedBuilder(
                    animation: _radarController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(200, 200),
                        painter: _RadarPainter(
                          progress: _radarController.value,
                          isAlert: isRinging,
                        ),
                      );
                    },
                  ),
                  // Center Icon
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isRinging ? Icons.notifications_active : Icons.settings_remote,
                        size: 48,
                        color: isRinging ? Colors.redAccent : const Color(0xFF00E5FF),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isRinging ? 'RINGING ALARM!' : 'RADAR ACTIVE',
                        style: TextStyle(
                          color: isRinging ? Colors.redAccent : const Color(0xFF00E5FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sound Alarm Action Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRinging ? Colors.redAccent : const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: isRinging ? 12 : 4,
                ),
                icon: Icon(
                  isRinging ? Icons.stop_circle : Icons.volume_up,
                  size: 28,
                  color: Colors.black,
                ),
                label: Text(
                  isRinging
                      ? 'STOP ALARM (${finder.ringSecondsLeft}s left)'
                      : 'PLAY LOUD SOUND ON REMOTE',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                onPressed: () {
                  if (isRinging) {
                    finder.stopAlarm();
                  } else {
                    finder.triggerAlarm(durationSeconds: 30);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            // Room Signal & Proximity Status Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.sensors, color: Color(0xFF00E5FF), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Room Proximity Signal',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: sensor.proximityNormalized,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        sensor.proximityNormalized > 0.7
                            ? const Color(0xFF00E676)
                            : (sensor.proximityNormalized > 0.4 ? Colors.amber : Colors.blueGrey),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimated Zone:', style: TextStyle(color: Colors.white70)),
                        Text(
                          sensor.roomZone,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E676)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Signal Level:', style: TextStyle(color: Colors.white70)),
                        Text(
                          '${sensor.signalStrengthDbm.toStringAsFixed(1)} dBm',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // GPS & Coordinates Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Last Known GPS Location',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Latitude / Longitude:', style: TextStyle(color: Colors.white70)),
                        Text(
                          '${sensor.latitude.toStringAsFixed(4)}°, ${sensor.longitude.toStringAsFixed(4)}°',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Accuracy Radius:', style: TextStyle(color: Colors.white70)),
                        Text(
                          '±${sensor.accuracyMeters.toStringAsFixed(1)} m (Indoor Room)',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Last Active Recorded:', style: TextStyle(color: Colors.white70)),
                        Text(
                          '${sensor.lastSeen.hour.toString().padLeft(2, '0')}:${sensor.lastSeen.minute.toString().padLeft(2, '0')}:${sensor.lastSeen.second.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Web Remote Trigger Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.wifi_tethering, color: Color(0xFF00E676), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Ring from Any Laptop or Phone',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'If this phone is misplaced in the room, visit this local address on any device connected to your home Wi-Fi to ring it:',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              finder.webBeaconUrl,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Color(0xFF00E5FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: 'Copy URL',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: finder.webBeaconUrl));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Finder URL copied to clipboard!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHowItWorksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.radar, color: Color(0xFF00E5FF)),
            SizedBox(width: 10),
            Text('Room-Finder Software'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to find your lost remote in the room:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. 🔊 Audible Alarm: Tap "Play Loud Sound" to make the remote emit continuous high-volume sound pulses and haptics.\n\n'
              '2. 🌐 Remote Ringing: From any laptop or family member\'s mobile on the same Wi-Fi, open the beacon web link to ring this remote without needing physical access.\n\n'
              '3. 📍 GPS & Room Proximity: Shows the last coordinates where the remote was operated and proximity signals indicating if it is under cushions or in another room.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final bool isAlert;

  _RadarPainter({required this.progress, required this.isAlert});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final baseColor = isAlert ? Colors.redAccent : const Color(0xFF00E5FF);

    // Static concentric guide rings
    final guidePaint = Paint()
      ..color = baseColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, maxRadius * 0.33, guidePaint);
    canvas.drawCircle(center, maxRadius * 0.66, guidePaint);
    canvas.drawCircle(center, maxRadius, guidePaint);

    // Dynamic expanding pulse waves
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i * 0.33)) % 1.0;
      final radius = ringProgress * maxRadius;
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0);

      final pulsePaint = Paint()
        ..color = baseColor.withOpacity(opacity * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, pulsePaint);
    }

    // Rotating sweep line
    final sweepAngle = progress * 2 * math.pi;
    final sweepEnd = Offset(
      center.dx + maxRadius * math.cos(sweepAngle),
      center.dy + maxRadius * math.sin(sweepAngle),
    );

    final linePaint = Paint()
      ..color = baseColor.withOpacity(0.5)
      ..strokeWidth = 1.5;

    canvas.drawLine(center, sweepEnd, linePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isAlert != isAlert;
  }
}
