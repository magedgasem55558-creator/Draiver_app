import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'drivers_list_screen.dart';
import 'assign_students_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم المدير')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _buildCard(context, 'السائقين', Icons.person, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DriversListScreen()));
            }),
            _buildCard(context, 'ربط الطلاب', Icons.assignment_ind, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignStudentsScreen()));
            }),
            _buildCard(context, 'تسجيل الخروج', Icons.logout, () {
              AuthService().signOut();
            }),
          ],
        ),
      ),
    );
  }

  Card _buildCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}