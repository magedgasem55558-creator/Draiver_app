import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../globals.dart';
import 'driver/driver_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;
  bool isAdminLogin = false;   // false = سائق، true = مدير

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => isLoading = true);
    try {
      if (isAdminLogin) {
        // دخول المدير
        await AuthService().signInAdmin(emailCtrl.text.trim(), passCtrl.text.trim());
        // AuthGate سيعيد التوجيه تلقائياً بعد نجاح الدخول
      } else {
        // دخول السائق
        final result = await AuthService().signInDriver(
          emailCtrl.text.trim(),
          passCtrl.text.trim(),
        );
        if (!mounted) return;
        if (!result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message)),
          );
          setState(() => isLoading = false);
          return;
        }
        // نجاح الدخول -> انتقل مباشرة لشاشة السائق
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
          (route) => false,
        );
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الدخول: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isAdminLogin ? 'دخول المدير' : 'دخول السائق')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
            const SizedBox(height: 12),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'كلمة المرور'), obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                  : const Text('دخول'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => setState(() => isAdminLogin = !isAdminLogin),
              child: Text(isAdminLogin ? 'الدخول كسائق' : 'الدخول كمدير'),
            ),
          ],
        ),
      ),
    );
  }
}