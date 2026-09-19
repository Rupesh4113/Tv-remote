import 'package:flutter_test/flutter_test.dart';
import 'package:remoteone/data/models/macro_model.dart';

void main() {
  group('Macro Model Serialization Tests', () {
    test('MacroModel and MacroStepModel serialization', () {
      final step = MacroStepModel(
        targetDeviceId: 'tv_01',
        targetDeviceName: 'Sony Bravia',
        commandKey: 'POWER',
        commandLabel: 'Turn TV ON',
        delayMs: 300,
      );

      final macro = MacroModel(
        id: 'macro_01',
        name: 'Watch TV',
        description: 'Sequence to power up TV and STB',
        steps: [step],
      );

      final json = macro.toJson();
      expect(json['id'], equals('macro_01'));
      expect((json['steps'] as List).length, equals(1));

      final revived = MacroModel.fromJson(json);
      expect(revived.name, equals('Watch TV'));
      expect(revived.steps.first.delayMs, equals(300));
    });
  });
}
