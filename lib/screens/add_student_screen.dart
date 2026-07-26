import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';   // إذا كنت تستخدم خدمة موحدة
import '../services/firestore_service.dart';

// داخل _AddStudentScreenState:

Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  final name = _nameCtrl.text.trim();
  final email = _emailCtrl.text.trim();
  final password = _passCtrl.text.trim();
  final halaqaId = _selectedHalaqaId;

  if (name.isEmpty || email.isEmpty || password.isEmpty || halaqaId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يرجى ملء جميع الحقول')),
    );
    return;
  }

  try {
    String parentUid;

    // 1. محاولة إنشاء حساب ولي الأمر
    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      parentUid = userCred.user!.uid;

      // 2. حفظ ولي الأمر في Firestore
      await FirebaseFirestore.instance.collection('parents').doc(parentUid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // إذا كان البريد موجودًا نبحث عن parentId
        final snap = await FirebaseFirestore.instance
            .collection('parents')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (snap.docs.isEmpty) {
          throw Exception('البريد موجود لكن لا يوجد ولي أمر مسجل');
        }
        parentUid = snap.docs.first.id;
      } else {
        rethrow;
      }
    }

    // 3. إضافة الطالب
    await FirebaseFirestore.instance.collection('students').add({
      'name': name,
      'parentId': parentUid,
      'halaqaId': halaqaId,
      'totalPoints': 0,
      'totalLines': 0,
      'joinDate': FieldValue.serverTimestamp(),
      'isActive': true,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت إضافة $name بنجاح ✅')),
      );
      _nameCtrl.clear();
      _emailCtrl.clear();
      _passCtrl.clear();
      setState(() => _selectedHalaqaId = null);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }
}

