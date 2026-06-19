import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> get(String table, {Map<String, dynamic>? filters}) async {
    var query = client.from(table).select();
    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }
    final data = await query;
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final data = await client.from(table).select().eq('id', id).maybeSingle();
    return data;
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    await client.from(table).insert(data);
  }

  Future<void> update(String table, String id, Map<String, dynamic> data) async {
    await client.from(table).update(data).eq('id', id);
  }

  Future<void> delete(String table, String id) async {
    await client.from(table).delete().eq('id', id);
  }

  Future<void> assignStudentToDriver(String studentId, String driverId) async {
    await insert('student_driver', {
      'student_id': studentId,
      'driver_id': driverId,
    });
  }

  Future<void> unassignStudent(String studentId, String driverId) async {
    await client.from('student_driver').delete().eq('student_id', studentId).eq('driver_id', driverId);
  }
}