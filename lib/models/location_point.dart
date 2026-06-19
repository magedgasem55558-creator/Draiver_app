class LocationPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LocationPoint.fromMap(Map<String, dynamic> map) => LocationPoint(
        latitude: map['latitude'],
        longitude: map['longitude'],
        timestamp: DateTime.parse(map['timestamp']),
      );
}