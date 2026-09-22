import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'core/constants.dart';
import 'data/database/storage_service.dart';
import 'services/combined_remote_service.dart';
import 'services/finder_beacon_service.dart';
import 'services/macro_runner.dart';
import 'services/remote_controller.dart';
import 'services/voice_command_service.dart';
import 'transports/bluetooth/bluetooth_transport.dart';
import 'transports/ir/ir_transport.dart';
import 'transports/wifi/wifi_transport.dart';
import 'ui/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.init();
  final irTransport = IrTransport();
  await irTransport.initialize();

  final wifiTransport = WiFiTransport();
  await wifiTransport.initialize();

  final bleTransport = BluetoothTransport();
  await bleTransport.initialize();

  final remoteController = RemoteController(
    irTransport: irTransport,
    wifiTransport: wifiTransport,
    bleTransport: bleTransport,
  );

  final combinedService = CombinedRemoteService(remoteController: remoteController);
  final macroRunner = MacroRunner(remoteController: remoteController, storageService: storageService);
  final voiceService = VoiceCommandService(remoteController: remoteController);
  final finderBeaconService = FinderBeaconService();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<IrTransport>.value(value: irTransport),
        Provider<WiFiTransport>.value(value: wifiTransport),
        Provider<BluetoothTransport>.value(value: bleTransport),
        ChangeNotifierProvider<RemoteController>.value(value: remoteController),
        ChangeNotifierProvider<CombinedRemoteService>.value(value: combinedService),
        ChangeNotifierProvider<MacroRunner>.value(value: macroRunner),
        ChangeNotifierProvider<VoiceCommandService>.value(value: voiceService),
        ChangeNotifierProvider<FinderBeaconService>.value(value: finderBeaconService),
      ],
      child: const RemoteOneApp(),
    ),
  );
}

class RemoteOneApp extends StatelessWidget {
  const RemoteOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const WelcomeScreen(),
    );
  }
}
