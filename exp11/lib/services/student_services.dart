
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentService {
  final CollectionReference<Map<String, dynamic>> _students =
      FirebaseFirestore.instance.collection('students');

  Stream<List<Student>> getStudents() {
    return _students
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Student.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addStudent(Student student) async {
    await _students.add({
      ...student.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStudent(Student student) async {
    await _students.doc(student.id).update(student.toMap());
  }

  Future<void> deleteStudent(String id) async {
    await _students.doc(id).delete();
  }
}
