import 'package:geolocator/geolocator.dart';

Future<bool> checkLocationPermission() async {
  // Check whether location service is enabled
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    return false;
  }

  // Check current permission
  LocationPermission permission = await Geolocator.checkPermission();

  // Request permission if it has not been granted
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // Still denied
  if (permission == LocationPermission.denied) {
    return false;
  }

  // Permanently denied
  if (permission == LocationPermission.deniedForever) {
    return false;
  }

  return permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;
}
