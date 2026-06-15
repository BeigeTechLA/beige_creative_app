enum Environment { dev, prod }

class Env {
  static late Environment current;
  static late String apiUrl;
  static late String imageUrl;
  static late String socketUrl;

  static const String googleMapsKey = String.fromEnvironment('GOOGLE_MAPS_KEY');

  static void init(Environment environment) {
    current = environment;
    switch (environment) {
      case Environment.dev:
        apiUrl = 'https://mobile.beige.app/api/';
        imageUrl = 'https://d1pgtgqp0jru64.cloudfront.net/';
        // socket.io v4 handshake URL — `socket_io_client` appends
        // `/socket.io/?EIO=4&transport=…` itself, so only host root here.
        // Full backend URL: wss://api.dev.beige.app/socket.io/?EIO=4&transport=websocket
        socketUrl = 'https://api.dev.beige.app';
      case Environment.prod:
        apiUrl = 'https://mobile.prod.beige.app/api/';
        imageUrl = 'https://d2jhn32fsulyac.cloudfront.net/';
        // TODO(M6): prod socket URL — backend to confirm. Placeholder
        // mirrors dev pattern (`api.<env>.beige.app`).
        socketUrl = 'https://api.prod.beige.app';
    }
  }
}