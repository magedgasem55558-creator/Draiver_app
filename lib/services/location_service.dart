import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  Timer? _timer;
  bool _isTracking = false;

  Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    return true;
  }

  void startTracking(String driverId) async {
    if (!await checkPermissions()) return;
    _isTracking = true;

    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!_isTracking) return;
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await Supabase.instance.client.from('driver_locations').insert({
          'driver_id': driverId,
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      } catch (e) {
        // سجل الخطأ إن أردت
      }
    });
  }

  void stopTracking() {
    _isTracking = false;
    _timer?.cancel();
    _timer = null;
  }
}