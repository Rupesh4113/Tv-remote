import 'dart:convert';
import 'package:flutter/services.dart';

class DeviceProfileSummaryModel {
  final String id;
  final String brand;
  final String category;
  final String model;
  final String region;
  final String version;
  final List<String> supportedTransports;
  final String file;

  DeviceProfileSummaryModel({
    required this.id,
    required this.brand,
    required this.category,
    required this.model,
    required this.region,
    required this.version,
    required this.supportedTransports,
    required this.file,
  });

  factory DeviceProfileSummaryModel.fromJson(Map<String, dynamic> json) =>
      DeviceProfileSummaryModel(
        id: json['id'] as String,
        brand: json['brand'] as String,
        category: json['category'] as String,
        model: json['model'] as String,
        region: json['region'] as String? ?? 'Global',
        version: json['version'] as String? ?? '1.0.0',
        supportedTransports: (json['supported_transports'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        file: json['file'] as String? ?? '${json['id']}.json',
      );
}

class ProfileRepository {
  List<DeviceProfileSummaryModel> _cachedSummaries = [];
  final Map<String, Map<String, dynamic>> _cachedProfiles = {};

  Future<List<DeviceProfileSummaryModel>> loadCatalog() async {
    if (_cachedSummaries.isNotEmpty) return _cachedSummaries;

    try {
      final jsonStr = await rootBundle.loadString('assets/profiles/index.json');
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _cachedSummaries = list
          .map((item) => DeviceProfileSummaryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Fallback default profiles if asset bundle not loaded
      _cachedSummaries = [
        DeviceProfileSummaryModel(
          id: 'tv-samsung-smart',
          brand: 'Samsung',
          category: 'TV',
          model: 'Smart TV',
          region: 'Global',
          version: '1.0.0',
          supportedTransports: ['WIFI', 'IR'],
          file: 'tv-samsung-smart.json',
        ),
        DeviceProfileSummaryModel(
          id: 'stb-tata-play',
          brand: 'Tata Play',
          category: 'SET_TOP_BOX',
          model: 'HD / Binge+',
          region: 'India',
          version: '1.0.0',
          supportedTransports: ['IR'],
          file: 'stb-tata-play.json',
        ),
      ];
    }
    return _cachedSummaries;
  }

  Future<Map<String, dynamic>?> loadProfile(String profileId) async {
    if (_cachedProfiles.containsKey(profileId)) {
      return _cachedProfiles[profileId];
    }

    try {
      final jsonStr = await rootBundle.loadString('assets/profiles/$profileId.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      _cachedProfiles[profileId] = data;
      return data;
    } catch (_) {
      return null;
    }
  }
}
