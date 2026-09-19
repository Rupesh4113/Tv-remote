import 'package:flutter/services.dart';

class HapticHelper {
  static bool enabled = true;

  static void buttonPress() {
    if (!enabled) return;
    HapticFeedback.lightImpact();
  }

  static void rockerPress() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  static void powerPress() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }

  static void errorVibrate() {
    if (!enabled) return;
    HapticFeedback.vibrate();
  }
}
