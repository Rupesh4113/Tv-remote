class AppConstants {
  static const String appName = 'RemoteOne';
  static const String appSubtitle = 'Universal TV & Set-Top Box Remote';
  static const String defaultBackendUrl = 'http://10.0.2.2:8000'; // Android emulator localhost

  static const List<String> tvBrands = [
    'Sony', 'Samsung', 'LG', 'Panasonic', 'Philips', 'TCL', 'Hisense',
    'Xiaomi', 'Redmi', 'OnePlus', 'Vu', 'Realme', 'Motorola', 'Toshiba',
    'Haier', 'Kodak', 'Blaupunkt', 'Thomson', 'Akai', 'Onida', 'Videocon',
    'Sansui', 'Lloyd', 'Croma', 'Micromax', 'Intex', 'BPL', 'CloudWalker',
    'iFFALCON', 'Acer', 'Coocaa', 'JVC', 'Nokia', 'Generic'
  ];

  static const List<String> stbProviders = [
    'Tata Play', 'Airtel Digital TV', 'Dish TV', 'd2h', 'Sun Direct',
    'DD Free Dish', 'Den Networks', 'Hathway', 'GTPL', 'Siti Cable',
    'Asianet', 'Generic Cable Box'
  ];

  static const List<String> deviceTypes = [
    'TV', 'Set-Top Box', 'Android TV', 'Google TV', 'Streaming Device', 'Soundbar'
  ];
}
