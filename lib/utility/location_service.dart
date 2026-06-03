import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  /// 🔍 SEARCH LOCATION FROM TEXT
  static Future<LatLng?> searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        final loc = locations.first;
        return LatLng(loc.latitude, loc.longitude);
      }
    } catch (e) {
      debugPrint("Search location error: $e");
    }
    return null;
  }

  /// 📍 GET ADDRESS FROM LAT LNG
  static Future<String> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        return "${p.subLocality}, ${p.locality}, ${p.administrativeArea}, ${p.postalCode}";
      }
    } catch (e) {
      debugPrint("Reverse geocode error: $e");
    }
    return "";
  }

  /// 📡 GET CURRENT LOCATION
  static Future<LatLng?> getCurrentLocation(BuildContext context) async {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enable location permission from settings"),
          ),
        );
      }
      await Geolocator.openAppSettings();
      return null;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return LatLng(position.latitude, position.longitude);
  }

  /// 🗺️ UPDATE LOCATION + ADDRESS
  static Future<Map<String, dynamic>> updateLocation(LatLng latLng) async {
    String address = await getAddressFromLatLng(latLng);

    return {
      "latLng": latLng,
      "address": address,
    };
  }
}