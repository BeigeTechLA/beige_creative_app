import '../config/env.dart';

class GoogleConfig {
  static const String placesApiKey = Env.googleMapsKey;

  static const double defaultZoom = 14.0;

  static const String darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1d1d1d"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1d1d1d"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}
]
''';
}

// // ================= DARK MAP STYLE =================
// static const String _darkMapStyle = '''
// [
//   {"elementType":"geometry","stylers":[{"color":"#1d1d1d"}]},
//   {"elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
//   {"elementType":"labels.text.stroke","stylers":[{"color":"#1d1d1d"}]},
//   {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
//   {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}
// ]
// ''';