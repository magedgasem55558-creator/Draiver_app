import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- التحقق من صلاحية المدير ---
  Future<bool> isAdmin(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists && doc.data()?['role'] == 'admin';
  }

  // --- جلب الحلقات ---
  Future<List<Map<String, dynamic>>> loadHalaqatList() async {
    final snapshot = await _db.collection('halaqat').get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  // --- جلب طلاب حلقة ---
  Future<List<Map<String, dynamic>>> loadStudentsByHalaqa(String halaqaId) async {
    final snapshot = await _db.collection('students').where('halaqaId', isEqualTo: halaqaId).get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  // --- إضافة سجل تسميع ---
  Future<void> addRecord(Map<String, dynamic> data) async {
    await _db.collection('records').add(data);
  }

  // --- دوال الإعدادات (فعاليات، خطب، تبرعات) ---
  Future<Map<String, dynamic>?> loadCurrentEvent() => _getDoc('settings', 'next_event');
  Future<void> updateEvent(Map<String, dynamic> data) => _setDoc('settings', 'next_event', data);
  Future<void> deleteEvent() => _deleteDoc('settings', 'next_event');

  Future<Map<String, dynamic>?> loadCurrentKhutba() => _getDoc('settings', 'next_khutba');
  Future<void> updateKhutba(Map<String, dynamic> data) => _setDoc('settings', 'next_khutba', data);
  Future<void> deleteKhutba() => _deleteDoc('settings', 'next_khutba');

  Future<Map<String, dynamic>?> loadDonationInfo() => _getDoc('settings', 'donation_info');
  Future<void> updateDonationInfo(Map<String, dynamic> data) => _setDoc('settings', 'donation_info', data);

  // --- محاضرات ---
  Future<List<Map<String, dynamic>>> loadAllLectures() async {
    final snapshot = await _db.collection('lectures').orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
  Future<void> addLecture(Map<String, dynamic> data) => _db.collection('lectures').add(data);

  // ... باقي الدوال (حذف، تعديل) تتبع نفس النمط

  // --- دوال مساعدة ---
  Future<Map<String, dynamic>?> _getDoc(String coll, String docId) async {
    final doc = await _db.collection(coll).doc(docId).get();
    return doc.exists ? doc.data() : null;
  }
  Future<void> _setDoc(String coll, String docId, Map<String, dynamic> data) =>
      _db.collection(coll).doc(docId).set(data, SetOptions(merge: true));
  Future<void> _deleteDoc(String coll, String docId) =>
      _db.collection(coll).doc(docId).delete();
}
