import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_model.dart';
import '../models/macro_model.dart';

class StorageService {
  static const _kDevicesKey = 'saved_devices_v1';
  static const _kMacrosKey = 'saved_macros_v1';
  static const _kLearnedKey = 'saved_learned_commands_v1';
  static const _kDefaultDeviceIdKey = 'default_device_id';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Devices
  List<DeviceModel> getDevices() {
    final rawList = _prefs.getStringList(_kDevicesKey) ?? [];
    return rawList
        .map((item) => DeviceModel.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveDevice(DeviceModel device) async {
    final devices = getDevices();
    final index = devices.indexWhere((d) => d.id == device.id);
    if (index >= 0) {
      devices[index] = device;
    } else {
      devices.add(device);
    }
    await _saveDeviceList(devices);
  }

  Future<void> deleteDevice(String deviceId) async {
    final devices = getDevices()..removeWhere((d) => d.id == deviceId);
    await _saveDeviceList(devices);
  }

  Future<void> _saveDeviceList(List<DeviceModel> devices) async {
    final rawList = devices.map((d) => jsonEncode(d.toJson())).toList();
    await _prefs.setStringList(_kDevicesKey, rawList);
  }

  // Default device
  String? getDefaultDeviceId() => _prefs.getString(_kDefaultDeviceIdKey);
  Future<void> setDefaultDeviceId(String id) => _prefs.setString(_kDefaultDeviceIdKey, id);

  // Macros
  List<MacroModel> getMacros() {
    final rawList = _prefs.getStringList(_kMacrosKey) ?? [];
    return rawList
        .map((m) => MacroModel.fromJson(jsonDecode(m) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMacro(MacroModel macro) async {
    final macros = getMacros();
    final index = macros.indexWhere((m) => m.id == macro.id);
    if (index >= 0) {
      macros[index] = macro;
    } else {
      macros.add(macro);
    }
    final rawList = macros.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs.setStringList(_kMacrosKey, rawList);
  }

  Future<void> deleteMacro(String macroId) async {
    final macros = getMacros()..removeWhere((m) => m.id == macroId);
    final rawList = macros.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs.setStringList(_kMacrosKey, rawList);
  }

  // Learned Commands
  Map<String, Map<String, dynamic>> getLearnedCommands() {
    final raw = _prefs.getString(_kLearnedKey);
    if (raw == null) return {};
    return (jsonDecode(raw) as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, v as Map<String, dynamic>),
    );
  }

  Future<void> saveLearnedCommand(String buttonName, Map<String, dynamic> commandData) async {
    final map = getLearnedCommands();
    map[buttonName] = commandData;
    await _prefs.setString(_kLearnedKey, jsonEncode(map));
  }

  Future<void> deleteLearnedCommand(String buttonName) async {
    final map = getLearnedCommands()..remove(buttonName);
    await _prefs.setString(_kLearnedKey, jsonEncode(map));
  }

  // Privacy: Delete all data
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
