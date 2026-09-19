class MacroStepModel {
  final String targetDeviceId;
  final String targetDeviceName;
  final String commandKey;
  final String commandLabel;
  final int delayMs;

  MacroStepModel({
    required this.targetDeviceId,
    required this.targetDeviceName,
    required this.commandKey,
    required this.commandLabel,
    this.delayMs = 500,
  });

  Map<String, dynamic> toJson() => {
    'targetDeviceId': targetDeviceId,
    'targetDeviceName': targetDeviceName,
    'commandKey': commandKey,
    'commandLabel': commandLabel,
    'delayMs': delayMs,
  };

  factory MacroStepModel.fromJson(Map<String, dynamic> json) => MacroStepModel(
    targetDeviceId: json['targetDeviceId'] as String,
    targetDeviceName: json['targetDeviceName'] as String,
    commandKey: json['commandKey'] as String,
    commandLabel: json['commandLabel'] as String,
    delayMs: json['delayMs'] as int? ?? 500,
  );
}

class MacroModel {
  final String id;
  final String name;
  final String description;
  final List<MacroStepModel> steps;

  MacroModel({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'steps': steps.map((s) => s.toJson()).toList(),
  };

  factory MacroModel.fromJson(Map<String, dynamic> json) => MacroModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    steps: (json['steps'] as List<dynamic>)
        .map((s) => MacroStepModel.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}
