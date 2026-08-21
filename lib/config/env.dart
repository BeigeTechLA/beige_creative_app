enum Environment { dev, prod }

class Env {
  static late Environment current;
  static late String apiUrl;
  static late String imageUrl;
  static late String socketUrl;

  static const String googleMapsKey = String.fromEnvironment('GOOGLE_MAPS_KEY');
  static const String chatSocketUrlOverride = String.fromEnvironment(
    'CHAT_SOCKET_URL',
  );

  static void init(Environment environment) {
    current = environment;
    switch (environment) {
      case Environment.dev:
        apiUrl = 'https://mobile.beige.app/api/';
        imageUrl = 'https://d1pgtgqp0jru64.cloudfront.net/';
        // socket.io v4 host. Keep the path/query out of this value; the
        // client sets `/socket.io` + `transport=websocket`.
        socketUrl = chatSocketUrlOverride.isNotEmpty
            ? chatSocketUrlOverride
            : 'https://api2.dev.beige.app';
      case Environment.prod:
        apiUrl = 'https://mobile.prod.beige.app/api/';
        imageUrl = 'https://d2jhn32fsulyac.cloudfront.net/';
        socketUrl = chatSocketUrlOverride.isNotEmpty
            ? chatSocketUrlOverride
            : 'https://api2.prod.beige.app';
    }
  }
}
