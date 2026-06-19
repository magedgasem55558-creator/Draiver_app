import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/driver.dart';
import 'add_driver_screen.dart';

class DriversListScreen extends StatefulWidget {
  const DriversListScreen({super.key});

  @override
  State<DriversListScreen> createState() => _DriversListScreenState();
}

class _DriversListScreenState extends State<DriversListScreen> {
  final ApiService _api = ApiService();
  List<Driver> _allDrivers = [];
  List<Driver> _filteredDrivers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _api.get('drivers');
      debugPrint('عدد السائقين المسترجع: ${data.length}');
      _allDrivers = data.map((e) => Driver.fromMap(e)).toList();
      _applyFilter();
    } catch (e) {
      debugPrint('استثناء جلب السائقين: $e');
      _errorMessage = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredDrivers = List.from(_allDrivers);
    } else {
      _filteredDrivers = _allDrivers.where((d) {
        return d.name.toLowerCase().contains(query) ||
               (d.phone?.contains(query) ?? false) ||
               (d.email?.toLowerCase().contains(query) ?? false) ||
               (d.plateNumber?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    setState(() {});
  }

  Future<void> _deleteDriver(Driver driver) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف السائق ${driver.name}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _api.delete('drivers', driver.id);
      _loadDrivers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف السائق')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحذف: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة السائقين'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث عن سائق...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) {
                _searchQuery = val;
                _applyFilter();
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDriverScreen()),
          );
          if (added == true) _loadDrivers();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('حدث خطأ', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadDrivers, child: const Text('إعادة المحاولة')),
                    ],
                  ),
                )
              : _filteredDrivers.isEmpty
                  ? const Center(child: Text('لا يوجد سائقين'))
                  : RefreshIndicator(
                      onRefresh: _loadDrivers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredDrivers.length,
                        itemBuilder: (_, i) {
                          final d = _filteredDrivers[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          d.name,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteDriver(d),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (d.phone != null && d.phone!.isNotEmpty)
                                    _buildInfoRow(Icons.phone, d.phone!),
                                  if (d.email != null && d.email!.isNotEmpty)
                                    _buildInfoRow(Icons.email, d.email!),
                                  if (d.vehicleType != null && d.vehicleType!.isNotEmpty)
                                    _buildInfoRow(Icons.directions_bus, d.vehicleType!),
                                  if (d.plateNumber != null && d.plateNumber!.isNotEmpty)
                                    _buildInfoRow(Icons.confirmation_number, d.plateNumber!),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}