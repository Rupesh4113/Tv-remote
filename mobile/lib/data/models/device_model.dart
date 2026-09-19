enum DeviceCategory { tv, setTopBox, streaming, audio }

enum TransportType { ir, wifi, bluetooth }

class DeviceModel {
  final String id;
  final String name;
  final String brand;
  final DeviceCategory category;
  final String profileId;
  final TransportType activeTransport;
  final String? ipAddress;
  final int? port;
  final String? authKey;
  final String? bleUuid;
  final bool isFavorite;

  DeviceModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.profileId,
    required this.activeTransport,
    this.ipAddress,
    this.port,
    this.authKey,
    this.bleUuid,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'category': category.name,
    'profileId': profileId,
    'activeTransport': activeTransport.name,
    'ipAddress': ipAddress,
    'port': port,
    'authKey': authKey,
    'bleUuid': bleUuid,
    'isFavorite': isFavorite,
  };

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
    id: json['id'] as String,
    name: json['name'] as String,
    brand: json['brand'] as String,
    category: DeviceCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => DeviceCategory.tv,
    ),
    profileId: json['profileId'] as String,
    activeTransport: TransportType.values.firstWhere(
      (e) => e.name == json['activeTransport'],
      orElse: () => TransportType.ir,
    ),
    ipAddress: json['ipAddress'] as String?,
    port: json['port'] as int?,
    authKey: json['authKey'] as String?,
    bleUuid: json['bleUuid'] as String?,
    isFavorite: json['isFavorite'] as bool? ?? false,
  );

  DeviceModel copyWith({
    String? name,
    bool? isFavorite,
    TransportType? activeTransport,
    String? ipAddress,
    int? port,
    String? authKey,
  }) => DeviceModel(
    id: id,
    name: name ?? this.name,
    brand: brand,
    category: category,
    profileId: profileId,
    activeTransport: activeTransport ?? this.activeTransport,
    ipAddress: ipAddress ?? this.ipAddress,
    port: port ?? this.port,
    authKey: authKey ?? this.authKey,
    bleUuid: bleUuid,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}
