import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart'; // لاستخدام debugPrint

class LocationService {
  Timer? _timer;
  bool _isTracking = false;

  Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('❌ صلاحية الموقع مرفوضة من المستخدم');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('❌ صلاحية الموقع مرفوضة بشكل دائم، يجب تفعيلها من الإعدادات');
      return false;
    }
    return true;
  }

  void startTracking(String driverId) async {
    if (_isTracking) return; // تجنب بدء تتبع مزدوج
    if (!await checkPermissions()) return;

    _isTracking = true;
    debugPrint('✅ بدء تتبع الإحداثيات للسائق: $driverId');

    // إرسال أول نقطة فوراً
    _sendLocation(driverId);

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_isTracking) return;
      _sendLocation(driverId);
    });
  }

  Future<void> _sendLocation(String driverId) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await Supabase.instance.client.from('driver_locations').insert({
        'driver_id': driverId,
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
      debugPrint('📍 تم إرسال الإحداثيات: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('❌ فشل إرسال الإحداثيات: $e');
    }
  }

  void stopTracking() {
    _isTracking = false;
    _timer?.cancel();
    _timer = null;
    debugPrint('⏹️ تم إيقاف تتبع الإحداثيات');
  }
}
