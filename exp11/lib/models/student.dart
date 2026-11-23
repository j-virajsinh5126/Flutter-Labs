
class Student {
  final String id;
  final String name;
  final String email;
  final String course;
  final String rollNumber;
  final String phone;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.course,
    required this.rollNumber,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'course': course,
      'rollNumber': rollNumber,
      'phone': phone,
    };
  }

  factory Student.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Student(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      course: map['course'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
