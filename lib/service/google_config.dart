class GoogleConfig {
  static const String placesApiKey =
      "AIzaSyB55dzOzA9np8T1rn-DpKKqcqGcgbGmgOc";

  static const double defaultZoom = 14.0;

  static final RegExp plusCodeRegex =
  RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$');

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
