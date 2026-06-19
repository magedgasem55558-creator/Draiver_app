class Driver {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? vehicleType;
  final String? plateNumber;

  Driver({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.vehicleType,
    this.plateNumber,
  });

  factory Driver.fromMap(Map<String, dynamic> map) => Driver(
        id: map['id'],
        name: map['name'],
        phone: map['phone'],
        email: map['email'],
        vehicleType: map['vehicle_type'],
        plateNumber: map['plate_number'],
      );
}