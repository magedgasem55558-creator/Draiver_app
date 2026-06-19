import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/driver/driver_home_screen.dart';
import 'services/auth_service.dart';



// متغيرات عامة لحفظ بيانات السائق المسجل الدخول (يمكن استبدالها بـ Provider لاحقاً)
String? currentDriverId;
String? currentDriverName;

class DriverTrackerApp extends StatelessWidget {
  const DriverTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // استمع لتغيرات المدير (auth)
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. تحقق من المدير المسجل
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser != null) {
      // المدير مسجل
      return const AdminDashboard();
    }

    // 2. تحقق من السائق المسجل (من خلال المتغير العام)
    if (currentDriverId != null) {
      return const DriverHomeScreen();
    }

    // 3. غير مسجل
    return const LoginScreen();
  }
}