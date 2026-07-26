import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/role_service.dart';
import 'add_student_screen.dart';
import 'recitation_screen.dart';
// ... استورد باقي الشاشات

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userEmail;
  bool _isAdmin = false;
  String _currentScreen = 'students'; // افتراضي

  @override
  void initState() {
    super.initState();
    _userEmail = AuthService().currentUserEmail;
    _checkRole();
  }

  Future<void> _checkRole() async {
    final uid = AuthService().currentUserId;
    if (uid != null) {
      final admin = await RoleService().checkAdmin(uid);
      setState(() => _isAdmin = admin || _userEmail == 'hammed@gmail.com');
    }
  }

  Widget _buildScreen(String route) {
    switch (route) {
      case 'students': return const AddStudentScreen();
      case 'halaqat': return const RecitationScreen();
      case 'events': return const EventsScreen();
      case 'khutba': return const KhutbaScreen();
      case 'add-halaqa': return const AddHalaqaScreen();
      case 'lectures': return const LecturesScreen();
      case 'manage-donations': return const DonationsScreen();
      case 'manage-students': return const ManageStudentsScreen();
      case 'manage-halaqat': return const ManageHalaqatScreen();
      case 'manage-records': return const ManageRecordsScreen();
      case 'manage-lectures': return const ManageLecturesScreen();
      default: return const AddStudentScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المسجد')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.teal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🏛️ إدارة المسجد', style: TextStyle(color: Colors.white, fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('📧 $_userEmail', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            _drawerItem('👥 إضافة طالب', 'students'),
            _drawerItem('📖 رصد التسميع', 'halaqat'),
            _drawerItem('📅 الفعاليات', 'events'),
            _drawerItem('🕌 خطبة الجمعة', 'khutba'),
            _drawerItem('🏫 إضافة حلقة', 'add-halaqa'),
            _drawerItem('💳 التبرعات', 'manage-donations'),
            _drawerItem('🎤 المحاضرات', 'lectures'),
            const Divider(),
            if (_isAdmin) ...[
              _drawerItem('📋 إدارة الطلاب', 'manage-students'),
              _drawerItem('📋 إدارة الحلقات', 'manage-halaqat'),
              _drawerItem('📋 سجلات التسميع', 'manage-records'),
              _drawerItem('📋 إدارة المحاضرات', 'manage-lectures'),
            ],
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('تسجيل الخروج'),
              onTap: () async {
                await AuthService().signOut();
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
          ],
        ),
      ),
      body: _buildScreen(_currentScreen),
    );
  }

  ListTile _drawerItem(String title, String route) {
    return ListTile(
      title: Text(title),
      onTap: () {
        setState(() => _currentScreen = route);
        Navigator.pop(context); // أغلق الدرج
      },
    );
  }
}

