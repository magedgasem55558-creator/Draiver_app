import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class LocationService {
  Timer? _timer;
  bool _isTracking = false;

  /// التحقق من الصلاحيات وتفعيل خدمة الموقع
  Future<String?> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'يرجى تفعيل خدمة الموقع (GPS) من إعدادات الهاتف';
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'يجب منح صلاحية الموقع لبدء التتبع';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'صلاحية الموقع مرفوضة بشكل دائم. الرجاء تفعيلها من إعدادات التطبيق';
    }

    return null;
  }

  void startTracking(String driverId) async {
    if (_isTracking) return;

    final error = await checkPermissions();
    if (error != null) {
      debugPrint('❌ $error');
      return;
    }

    _isTracking = true;
    debugPrint('✅ بدء تتبع الإحداثيات للسائق: $driverId');

    // إرسال أول نقطة فوراً
    _sendLocation(driverId);

    // ⏱️ تغيير المدة إلى 3 ثوانٍ بدلاً من 30 ثانية
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
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
