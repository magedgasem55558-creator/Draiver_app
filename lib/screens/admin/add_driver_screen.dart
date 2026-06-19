import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddDriverScreen extends StatefulWidget {
  const AddDriverScreen({super.key});

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final vehicleTypeCtrl = TextEditingController();
  final plateNumberCtrl = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    vehicleTypeCtrl.dispose();
    plateNumberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة سائق جديد')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم')),
              TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقم الهاتف')),
              TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
              TextFormField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'كلمة المرور'), obscureText: true),
              TextFormField(controller: vehicleTypeCtrl, decoration: const InputDecoration(labelText: 'نوع المركبة')),
              TextFormField(controller: plateNumberCtrl, decoration: const InputDecoration(labelText: 'رقم اللوحة')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _addDriver,
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                    : const Text('إضافة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addDriver() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await ApiService().insert('drivers', {
        'name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
        'vehicle_type': vehicleTypeCtrl.text.trim(),
        'plate_number': plateNumberCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة السائق')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الإضافة: ${e.toString().split('\n').first}'),
            duration: const Duration(seconds: 5),
          ),
        );
        debugPrint('خطأ إضافة سائق: $e');  // للظهور في الطرفية
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}