enum Environment { dev, prod }

class Env {
  static late Environment current;
  static late String apiUrl;
  static late String imageUrl;

  static const String googleMapsKey = String.fromEnvironment(
    'GOOGLE_MAPS_KEY',
    defaultValue: 'AIzaSyB55dzOzA9np8T1rn-DpKKqcqGcgbGmgOc',
  );

  static void init(Environment environment) {
    current = environment;
    switch (environment) {
      case Environment.dev:
        apiUrl = 'https://mobile.beige.app/api/';
        imageUrl = 'https://d1pgtgqp0jru64.cloudfront.net/';
      case Environment.prod:
        apiUrl = 'https://mobile.prod.beige.app/api/';
        imageUrl = 'https://d2jhn32fsulyac.cloudfront.net/';
    }
  }
}