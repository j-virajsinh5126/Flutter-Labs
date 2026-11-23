
import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/auth_services.dart';
import '../services/student_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StudentService _studentService = StudentService();
  final AuthService _authService = AuthService();

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  Future<void> _showStudentDialog({Student? student}) async {
    final formKey = GlobalKey<FormState>();

    final nameController =
        TextEditingController(text: student?.name ?? '');
    final emailController =
        TextEditingController(text: student?.email ?? '');
    final courseController =
        TextEditingController(text: student?.course ?? '');
    final rollController =
        TextEditingController(text: student?.rollNumber ?? '');
    final phoneController =
        TextEditingController(text: student?.phone ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            student == null ? 'Add Student' : 'Edit Student',
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildField(nameController, 'Student Name'),
                    _buildField(
                      emailController,
                      'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildField(courseController, 'Course'),
                    _buildField(rollController, 'Roll Number'),
                    _buildField(
                      phoneController,
                      'Phone Number',
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: Text(student == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final newStudent = Student(
        id: student?.id ?? '',
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        course: courseController.text.trim(),
        rollNumber: rollController.text.trim(),
        phone: phoneController.text.trim(),
      );

      try {
        if (student == null) {
          await _studentService.addStudent(newStudent);
        } else {
          await _studentService.updateStudent(newStudent);
        }

        if (mounted) {
          _showMessage(
            student == null
                ? 'Student added successfully'
                : 'Student updated successfully',
          );
        }
      } catch (e) {
        if (mounted) {
          _showMessage('Operation failed: $e');
        }
      }
    }

    nameController.dispose();
    emailController.dispose();
    courseController.dispose();
    rollController.dispose();
    phoneController.dispose();
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _deleteStudent(Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Student?'),
          content: Text(
            'Are you sure you want to delete ${student.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _studentService.deleteStudent(student.id);

      if (mounted) {
        _showMessage('Student deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Unable to delete student: $e');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      if (mounted) {
        _showMessage('Logout failed: $e');
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStudentDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),

      body: Column(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _authService.getUserProfile(),
            builder: (context, snapshot) {
              final profile = snapshot.data;

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      profile?['name'] ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Role: ${profile?['role'] ?? 'Loading...'}',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: _studentService.getStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading students: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final students = snapshot.data ?? [];

                final filteredStudents = students.where((student) {
                  return student.name.toLowerCase().contains(_searchQuery) ||
                      student.email.toLowerCase().contains(_searchQuery) ||
                      student.course.toLowerCase().contains(_searchQuery) ||
                      student.rollNumber.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredStudents.isEmpty) {
                  return Center(
                    child: Text(
                      students.isEmpty
                          ? 'No students added yet.'
                          : 'No matching students found.',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade100,
                          child: Text(
                            student.name.isNotEmpty
                                ? student.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Roll No: ${student.rollNumber}\n'
                            'Course: ${student.course}\n'
                            'Email: ${student.email}\n'
                            'Phone: ${student.phone}',
                          ),
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showStudentDialog(student: student);
                            } else if (value == 'delete') {
                              _deleteStudent(student);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
