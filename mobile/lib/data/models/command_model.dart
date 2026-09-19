class RemoteCommand {
  final String key;
  final String label;
  final String? irHex;
  final List<int>? irPattern;
  final Map<String, dynamic>? wifiPayload;
  final String? bleBytes;

  RemoteCommand({
    required this.key,
    required this.label,
    this.irHex,
    this.irPattern,
    this.wifiPayload,
    this.bleBytes,
  });

  factory RemoteCommand.fromJson(String key, Map<String, dynamic> json) {
    return RemoteCommand(
      key: key,
      label: json['label'] as String? ?? key,
      irHex: json['ir_hex'] as String?,
      irPattern: (json['ir_pattern'] as List<dynamic>?)?.map((e) => e as int).toList(),
      wifiPayload: json['wifi_payload'] as Map<String, dynamic>?,
      bleBytes: json['ble_bytes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'ir_hex': irHex,
    'ir_pattern': irPattern,
    'wifi_payload': wifiPayload,
    'ble_bytes': bleBytes,
  };
}
