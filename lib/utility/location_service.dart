import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {

  /// ===============================
  /// ✅ GET CURRENT LOCATION (SAFE)
  /// ===============================
  static Future<LatLng?> getCurrentLocation(BuildContext context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnack(context, "Location permission permanently denied.");
        await Geolocator.openAppSettings();
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);

    } catch (e) {
      debugPrint("❌ Get location error: $e");
      _showSnack(context, "Failed to get current location");
      return null;
    }
  }


  /// ===============================
  /// ❌ REMOVE THIS (DON'T USE)
  /// ===============================
  /// ⚠️ Google Places already handle search
  /// This creates conflict — avoid using in UI
  static Future<LatLng?> searchLocation(String query) async {
    try {
      final locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        final loc = locations.first;
        return LatLng(loc.latitude, loc.longitude);
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }
    return null;
  }


  /// ===============================
  /// ✅ LATLNG → ADDRESS (CLEAN)
  /// ===============================
  static Future<String?> getAddressFromLatLng(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isEmpty) return null;

      final p = placemarks.first;

      final parts = <String>[
        if (p.name != null && !_isPlusCode(p.name!)) p.name!,
        if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality!,
        if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
        if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) p.administrativeArea!,
        if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode!,
      ];

      return parts.join(', ');

    } catch (e) {
      debugPrint("❌ Reverse geocode error: $e");
      return null;
    }
  }


  /// ===============================
  /// ✅ COMMON UPDATE FUNCTION 🔥
  /// ===============================
  static Future<void> updateLocation({
    required LatLng latLng,
    required Function(LatLng) onLocationChanged,
    required TextEditingController controller,
  }) async {
    try {
      onLocationChanged(latLng);

      final address = await getAddressFromLatLng(latLng);

      if (address != null) {
        controller.text = address;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }

    } catch (e) {
      debugPrint("❌ Update location error: $e");
    }
  }


  /// ===============================
  /// 🔒 INTERNAL HELPERS
  /// ===============================
  static bool _isPlusCode(String value) {
    return RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$')
        .hasMatch(value);
  }

  static void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}