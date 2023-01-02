import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> _getPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getLocation() async {
    final hasPermission = await _getPermission();
    if (!hasPermission) return null;

    try {
      final res = await Geolocator.getCurrentPosition(
          timeLimit: const Duration(seconds: 3));
      return res;
    } catch (e) {
      return null;
    }
  }
}
