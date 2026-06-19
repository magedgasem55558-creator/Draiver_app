import 'package:flutter/material.dart';
import '../../globals.dart';            // currentDriverId
import '../../services/location_service.dart';

class DriverTripScreen extends StatefulWidget {
  const DriverTripScreen({super.key});

  @override
  State<DriverTripScreen> createState() => _DriverTripScreenState();
}

class _DriverTripScreenState extends State<DriverTripScreen> {
  final LocationService _locationService = LocationService();
  bool isTripActive = false;
  String? _errorMessage;

  void _startTrip() async {
    if (currentDriverId == null) {
      setState(() => _errorMessage = 'معرف السائق غير موجود');
      return;
    }
    // التحقق من الصلاحيات قبل البدء
    final hasPermission = await _locationService.checkPermissions();
    if (!hasPermission) {
      setState(() => _errorMessage = 'يجب منح صلاحية الموقع لبدء التتبع');
      return;
    }
    setState(() {
      isTripActive = true;
      _errorMessage = null;
    });
    _locationService.startTracking(currentDriverId!);
  }

  void _endTrip() {
    setState(() => isTripActive = false);
    _locationService.stopTracking();
  }

  @override
  void dispose() {
    _locationService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isTripActive ? 'الرحلة جارية...' : 'جاهز'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTripActive ? Icons.directions_bus : Icons.local_parking,
              size: 80,
              color: isTripActive ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            Text(
              isTripActive ? 'الرحلة نشطة' : 'اضغط لبدء الرحلة',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isTripActive ? _endTrip : _startTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: isTripActive ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: Text(isTripActive ? 'إنهاء الرحلة' : 'بدء الرحلة'),
            ),
          ],
        ),
      ),
    );
  }
}
