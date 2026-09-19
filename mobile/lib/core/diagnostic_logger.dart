import 'dart:convert';
import 'package:flutter/foundation.dart';

class LogEntry {
  final DateTime timestamp;
  final String device;
  final String transport;
  final String protocol;
  final int frequency;
  final String command;
  final String status;
  final String? detail;

  LogEntry({
    required this.timestamp,
    required this.device,
    required this.transport,
    required this.protocol,
    required this.frequency,
    required this.command,
    required this.status,
    this.detail,
  });

  String get timeFormatted {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'device': device,
    'transport': transport,
    'protocol': protocol,
    'frequency': frequency,
    'command': command,
    'status': status,
    if (detail != null) 'detail': detail,
  };

  @override
  String toString() {
    return '[$timeFormatted] Device: $device | Transport: $transport | Proto: $protocol | Freq: ${frequency}Hz | Cmd: $command | Status: $status';
  }
}

class DiagnosticLogger extends ChangeNotifier {
  static final DiagnosticLogger instance = DiagnosticLogger._internal();
  DiagnosticLogger._internal();

  final List<LogEntry> _logs = [];
  final int _maxLogs = 200;

  List<LogEntry> get logs => List.unmodifiable(_logs);

  void log({
    required String device,
    required String transport,
    required String protocol,
    required int frequency,
    required String command,
    required String status,
    String? detail,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      device: device,
      transport: transport,
      protocol: protocol,
      frequency: frequency,
      command: command,
      status: status,
      detail: detail,
    );

    if (_logs.length >= _maxLogs) {
      _logs.removeAt(0);
    }
    _logs.add(entry);

    if (kDebugMode) {
      print(entry.toString());
    }

    notifyListeners();
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }

  String exportAsText() {
    final sb = StringBuffer();
    sb.writeln('=== RemoteOne Diagnostic Logs ===');
    sb.writeln('Generated at: ${DateTime.now().toIso8601String()}\n');
    for (final entry in _logs) {
      sb.writeln(entry.toString());
    }
    return sb.toString();
  }

  String exportAsJson() {
    final list = _logs.map((e) => e.toJson()).toList();
    return jsonEncode({
      'app': 'RemoteOne',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'logs': list,
    });
  }
}
