class Student {
  final String id;
  final String name;
  final String? driverId;

  Student({required this.id, required this.name, this.driverId});

  factory Student.fromMap(Map<String, dynamic> map) => Student(
        id: map['id'],
        name: map['name'],
        driverId: map['driver_id'],
      );
}