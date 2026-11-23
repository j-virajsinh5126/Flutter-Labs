
import 'package:flutter/material.dart';

void main() {
  runApp(const StudentRegistrationApp());
}

class StudentRegistrationApp extends StatelessWidget {
  const StudentRegistrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Registration',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        useMaterial3: true,
      ),
      home: const RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  // Text Editing Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // Radio Button
  String? gender = 'Male';

  // Checkbox
  List<String> courses = [
    'Flutter',
    'Python',
    'Java',
    'Web Development',
    'Machine Learning',
  ];

  List<String> selectedCourses = [];

  // Slider
  double age = 20;

  // Switch
  bool notifications = true;
  bool internship = false;

  // Password Visibility
  bool hidePassword = true;

  // Submitted Data
  bool submitted = false;

  void submitForm() {
    if (formKey.currentState!.validate()) {

      setState(() {
        submitted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Successful!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Registration',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Heading
                const Center(
                  child: Text(
                    'Create Your Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'Fill in your details to register',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 25),

                // Name Field
                buildTextField(
                  controller: nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Email Field
                buildTextField(
                  controller: emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }

                    if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+$',
                    ).hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Phone Field
                buildTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null ||
                        !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }

                    if (value.length < 6) {
                      return 'Password must contain at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 25),

                // Gender Radio Buttons
                const Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                RadioGroup<String>(
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                  child: const Column(
                    children: [
                      RadioListTile<String>(
                        title: Text('Male'),
                        value: 'Male',
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String>(
                        title: Text('Female'),
                        value: 'Female',
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String>(
                        title: Text('Other'),
                        value: 'Other',
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // Course Checkboxes
                const Text(
                  'Select Courses / Skills',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                ...courses.map((course) {
                  return CheckboxListTile(
                    title: Text(course),
                    value: selectedCourses.contains(course),
                    activeColor: Colors.indigo,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedCourses.add(course);
                        } else {
                          selectedCourses.remove(course);
                        }
                      });
                    },
                  );
                }),

                const SizedBox(height: 15),

                // Age Slider
                const Text(
                  'Select Your Age',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Row(
                  children: [
                    const Icon(Icons.cake, color: Colors.indigo),
                    Expanded(
                      child: Slider(
                        value: age,
                        min: 16,
                        max: 40,
                        divisions: 24,
                        label: age.round().toString(),
                        activeColor: Colors.indigo,
                        onChanged: (value) {
                          setState(() {
                            age = value;
                          });
                        },
                      ),
                    ),
                    Text(
                      '${age.round()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Switch Controls
                const Text(
                  'Additional Preferences',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text(
                    'Receive registration updates',
                  ),
                  value: notifications,
                  activeColor: Colors.indigo,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      notifications = value;
                    });
                  },
                ),

                SwitchListTile(
                  title: const Text('Interested in Internship'),
                  subtitle: const Text(
                    'Receive internship opportunities',
                  ),
                  value: internship,
                  activeColor: Colors.indigo,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      internship = value;
                    });
                  },
                ),

                const SizedBox(height: 25),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: submitForm,
                    icon: const Icon(Icons.app_registration),
                    label: const Text(
                      'Register Now',
                      style: TextStyle(fontSize: 17),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Display Submitted Information
                if (submitted) ...[
                  const Divider(thickness: 2),

                  const Text(
                    'Registration Details',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Card(
                    elevation: 3,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          resultRow(
                            'Name',
                            nameController.text,
                          ),

                          resultRow(
                            'Email',
                            emailController.text,
                          ),

                          resultRow(
                            'Phone',
                            phoneController.text,
                          ),

                          resultRow(
                            'Password',
                            '********',
                          ),

                          resultRow(
                            'Gender',
                            gender ?? 'Not selected',
                          ),

                          resultRow(
                            'Age',
                            age.round().toString(),
                          ),

                          resultRow(
                            'Courses',
                            selectedCourses.isEmpty
                                ? 'None selected'
                                : selectedCourses.join(', '),
                          ),

                          resultRow(
                            'Notifications',
                            notifications ? 'Enabled' : 'Disabled',
                          ),

                          resultRow(
                            'Internship',
                            internship ? 'Yes' : 'No',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        formKey.currentState!.reset();

                        nameController.clear();
                        emailController.clear();
                        phoneController.clear();
                        passwordController.clear();

                        setState(() {
                          gender = 'Male';
                          selectedCourses.clear();
                          age = 20;
                          notifications = true;
                          internship = false;
                          hidePassword = true;
                          submitted = false;
                        });
                      },
                      child: const Text('Register Another Student'),
                    ),
                  ),
                ],

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Text Field
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }

  // Display Result Row
  Widget resultRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
