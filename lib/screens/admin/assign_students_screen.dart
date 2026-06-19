import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/student.dart';
import '../../models/driver.dart';

class AssignStudentsScreen extends StatefulWidget {
  const AssignStudentsScreen({super.key});

  @override
  State<AssignStudentsScreen> createState() => _AssignStudentsScreenState();
}

class _AssignStudentsScreenState extends State<AssignStudentsScreen> {
  final ApiService _api = ApiService();

  List<Student> _allStudents = [];
  List<Driver> _allDrivers = [];
  Map<String, List<Student>> _driverStudents = {}; // driverId -> قائمة الطلاب
  List<Student> _unassignedStudents = []; // طلاب بدون سائق

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final studentsRaw = await _api.get('students');
      final driversRaw = await _api.get('drivers');
      final linksRaw = await _api.get('student_driver');

      _allStudents = studentsRaw.map((e) => Student.fromMap(e)).toList();
      _allDrivers = driversRaw.map((e) => Driver.fromMap(e)).toList();

      // بناء علاقة سائق -> طلاب
      final Map<String, List<Student>> driverMap = {
        for (var d in _allDrivers) d.id: <Student>[]
      };
      final Map<String, String> studentDriverLink = {}; // studentId -> driverId
      for (var link in linksRaw) {
        studentDriverLink[link['student_id']] = link['driver_id'];
      }

      final List<Student> unassigned = [];
      for (var student in _allStudents) {
        final driverId = studentDriverLink[student.id];
        if (driverId != null && driverMap.containsKey(driverId)) {
          driverMap[driverId]!.add(student);
        } else {
          unassigned.add(student);
        }
      }

      setState(() {
        _driverStudents = driverMap;
        _unassignedStudents = unassigned;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  // إضافة طالب إلى سائق
  Future<void> _addStudentToDriver(Student student, String driverId) async {
    await _api.assignStudentToDriver(student.id, driverId);
    setState(() {
      _unassignedStudents.remove(student);
      _driverStudents[driverId]?.add(student);
    });
  }

  // إزالة طالب من سائق (يصبح غير مرتبط)
  Future<void> _removeStudentFromDriver(Student student, String driverId) async {
    await _api.unassignStudent(student.id, driverId);
    setState(() {
      _driverStudents[driverId]?.remove(student);
      _unassignedStudents.add(student);
    });
  }

  // البحث يصفي الطلاب غير المرتبطين (لإضافتهم)
  List<Student> get _filteredUnassigned {
    if (_searchQuery.isEmpty) return _unassignedStudents;
    return _unassignedStudents
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ربط الطلاب بالسائقين'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث عن طالب غير مرتبط...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // قسم الطلاب غير المرتبطين
                  if (_unassignedStudents.isNotEmpty) ...[
                    const Text('🚩 طلاب بدون سائق',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._filteredUnassigned.map((student) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text(student.name),
                            trailing: const Icon(Icons.add_circle_outline,
                                color: Colors.green),
                            onTap: () => _showAddToDriverDialog(student),
                          ),
                        )),
                    const Divider(height: 30),
                  ],
                  // قسم السائقين وطلابهم
                  const Text('🚌 السائقون وطلابهم',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._allDrivers.map((driver) =>
                      _buildDriverExpansionTile(driver)),
                ],
              ),
            ),
    );
  }

  Widget _buildDriverExpansionTile(Driver driver) {
    final students = _driverStudents[driver.id] ?? [];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: const Icon(Icons.person, color: Colors.indigo),
        title: Text(driver.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(
            '${students.length} طالب'),
        children: [
          if (students.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('لا يوجد طلاب مرتبطين بعد',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ...students.map((student) => ListTile(
                  leading: const Icon(Icons.face),
                  title: Text(student.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: () =>
                        _removeStudentFromDriver(student, driver.id),
                  ),
                )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                _showAddStudentToDriverDialog(driver);
              },
              icon: const Icon(Icons.add),
              label: const Text('أضف طالباً'),
            ),
          ),
        ],
      ),
    );
  }

  // حوار لإضافة طالب معين إلى سائق (عند الضغط على الطالب)
  void _showAddToDriverDialog(Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('إضافة ${student.name} إلى سائق'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _allDrivers
                .map((driver) => ListTile(
                      title: Text(driver.name),
                      onTap: () {
                        _addStudentToDriver(student, driver.id);
                        Navigator.pop(ctx);
                      },
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  // حوار لإضافة طالب (من غير المرتبطين) إلى سائق معين
  void _showAddStudentToDriverDialog(Driver driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('أضف طالباً إلى ${driver.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: _unassignedStudents.isEmpty
              ? const Text('جميع الطلاب مرتبطون.')
              : ListView(
                  shrinkWrap: true,
                  children: _unassignedStudents
                      .map((student) => ListTile(
                            title: Text(student.name),
                            onTap: () {
                              _addStudentToDriver(student, driver.id);
                              Navigator.pop(ctx);
                            },
                          ))
                      .toList(),
                ),
        ),
      ),
    );
  }
}