import '../config/env.dart';

class GoogleConfig {
  static const String placesApiKey = Env.googleMapsKey;

  static const double defaultZoom = 14.0;

  static const String darkMapStyle = '''
  [
    {"elementType":"geometry","stylers":[{"color":"#212121"}]},
    {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#383838"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}
  ]
  ''';
}
