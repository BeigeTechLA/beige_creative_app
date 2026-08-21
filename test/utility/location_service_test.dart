import 'package:beige_creative_app/utility/location_exception.dart';
import 'package:beige_creative_app/utility/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {}

class MockGeocodingPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeocodingPlatform {}

void main() {
  late MockGeolocatorPlatform mockGeolocator;
  late MockGeocodingPlatform mockGeocoding;

  setUpAll(() {
    registerFallbackValue(const LocationSettings());
  });

  setUp(() {
    mockGeolocator = MockGeolocatorPlatform();
    mockGeocoding = MockGeocodingPlatform();
    GeolocatorPlatform.instance = mockGeolocator;
    GeocodingPlatform.instance = mockGeocoding;
  });

  group('LocationService.getAddressFromLatLng', () {
    test('returns formatted address on success', () async {
      final placemark = Placemark(
        subLocality: 'Sub',
        locality: 'Locality',
        administrativeArea: 'Admin',
        postalCode: '12345',
      );

      when(() => mockGeocoding.placemarkFromCoordinates(1.0, 2.0))
          .thenAnswer((_) async => [placemark]);

      final address = await LocationService.getAddressFromLatLng(const LatLng(1.0, 2.0));
      expect(address, 'Sub, Locality, Admin, 12345');
    });

    test('omits null or empty fields', () async {
      final placemark = Placemark(
        subLocality: '',
        locality: 'Locality',
        administrativeArea: null,
        postalCode: '12345',
      );

      when(() => mockGeocoding.placemarkFromCoordinates(1.0, 2.0))
          .thenAnswer((_) async => [placemark]);

      final address = await LocationService.getAddressFromLatLng(const LatLng(1.0, 2.0));
      expect(address, 'Locality, 12345');
    });

    test('returns empty string if placemarks are empty', () async {
      when(() => mockGeocoding.placemarkFromCoordinates(1.0, 2.0))
          .thenAnswer((_) async => []);

      final address = await LocationService.getAddressFromLatLng(const LatLng(1.0, 2.0));
      expect(address, '');
    });

    test('returns empty string on exception', () async {
      when(() => mockGeocoding.placemarkFromCoordinates(1.0, 2.0))
          .thenThrow(Exception('API error'));

      final address = await LocationService.getAddressFromLatLng(const LatLng(1.0, 2.0));
      expect(address, '');
    });
  });

  group('LocationService.getCurrentLocation', () {
    final position = Position(
      longitude: 2.0,
      latitude: 1.0,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 1.0,
      altitudeAccuracy: 1.0,
      heading: 1.0,
      headingAccuracy: 1.0,
      speed: 1.0,
      speedAccuracy: 1.0,
    );

    test('returns LatLng when location services enabled and permission granted', () async {
      when(() => mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission()).thenAnswer((_) async => LocationPermission.whileInUse);
      when(() => mockGeolocator.getCurrentPosition(locationSettings: any(named: 'locationSettings')))
          .thenAnswer((_) async => position);

      final result = await LocationService.getCurrentLocation();
      expect(result.latitude, 1.0);
      expect(result.longitude, 2.0);
    });

    test('requests permission if denied and returns LatLng if granted', () async {
      when(() => mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission()).thenAnswer((_) async => LocationPermission.denied);
      when(() => mockGeolocator.requestPermission()).thenAnswer((_) async => LocationPermission.whileInUse);
      when(() => mockGeolocator.getCurrentPosition(locationSettings: any(named: 'locationSettings')))
          .thenAnswer((_) async => position);

      final result = await LocationService.getCurrentLocation();
      expect(result.latitude, 1.0);
      expect(result.longitude, 2.0);
      verify(() => mockGeolocator.requestPermission()).called(1);
    });

    test('throws LocationException with serviceDisabled if services are disabled', () async {
      when(() => mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => false);

      expect(
        () => LocationService.getCurrentLocation(),
        throwsA(
          isA<LocationException>().having(
            (e) => e.status,
            'status',
            LocationStatus.serviceDisabled,
          ),
        ),
      );
    });

    test('throws LocationException with permanentlyDenied if permission denied forever', () async {
      when(() => mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission()).thenAnswer((_) async => LocationPermission.deniedForever);

      expect(
        () => LocationService.getCurrentLocation(),
        throwsA(
          isA<LocationException>().having(
            (e) => e.status,
            'status',
            LocationStatus.permanentlyDenied,
          ),
        ),
      );
    });

    test('throws LocationException with denied if permission denied', () async {
      when(() => mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission()).thenAnswer((_) async => LocationPermission.denied);
      when(() => mockGeolocator.requestPermission()).thenAnswer((_) async => LocationPermission.denied);

      expect(
        () => LocationService.getCurrentLocation(),
        throwsA(
          isA<LocationException>().having(
            (e) => e.status,
            'status',
            LocationStatus.denied,
          ),
        ),
      );
    });
  });
}
