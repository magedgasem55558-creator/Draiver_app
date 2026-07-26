import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/role_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _errorMsg = '';

  Future<void> _login() async {
    setState(() => _errorMsg = '');
    try {
      final user = await AuthService().signIn(_emailCtrl.text.trim(), _passCtrl.text);
      if (user != null) {
        final isAdmin = await RoleService().checkAdmin(user.uid);
        if (!isAdmin && user.email != 'hammed@gmail.com') {
          await AuthService().signOut();
          setState(() => _errorMsg = '⛔ لا تملك صلاحية الدخول.');
          return;
        }
      }
    } catch (e) {
      String msg = 'فشل تسجيل الدخول';
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') msg = '❌ لا يوجد حساب بهذا البريد.';
        else if (e.code == 'wrong-password') msg = '❌ كلمة مرور غير صحيحة.';
        else if (e.code == 'too-many-requests') msg = '🚫 تم تعطيل الحساب مؤقتاً.';
      }
      setState(() => _errorMsg = msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏛️ مرحباً بك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
                  const SizedBox(height: 16),
                  TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور')),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: _login, child: const Text('دخول')),
                  if (_errorMsg.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_errorMsg, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
