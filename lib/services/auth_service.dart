import '../models/driver.dart';
import 'api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../globals.dart'; // ← تمت الإضافة

enum UserType { admin, driver }

class AuthService {
  final ApiService _api = ApiService();

  /// تسجيل دخول المدير (باستخدام Supabase Auth)
  Future<void> signInAdmin(String email, String password) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// تسجيل دخول السائق (بحث في جدول drivers)
  Future<({bool success, String message})> signInDriver(
      String email, String password) async {
    try {
      final drivers = await _api.get('drivers', filters: {'email': email});
      if (drivers.isEmpty) {
        return (success: false, message: 'البريد الإلكتروني غير موجود');
      }
      final driver = drivers.first;
      if (driver['password'] != password) {
        return (success: false, message: 'كلمة المرور غير صحيحة');
      }
      // حفظ بيانات السائق في المتغيرات العامة
      currentDriverId = driver['id'];
      currentDriverName = driver['name'];
      return (success: true, message: 'تم الدخول');
    } catch (e) {
      return (success: false, message: 'حدث خطأ: $e');
    }
  }

  /// تسجيل الخروج (للجميع)
  Future<void> signOut() async {
    // إذا كان المدير مسجل
    await Supabase.instance.client.auth.signOut();
    // تنظيف بيانات السائق
    currentDriverId = null;
    currentDriverName = null;
  }
}