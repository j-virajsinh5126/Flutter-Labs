
import 'package:flutter/material.dart';

void main() {
  runApp(const DeveloperProfileApp());
}

class DeveloperProfileApp extends StatelessWidget {
  const DeveloperProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Developer Profile',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
        fontFamily: 'Roboto',
      ),
      home: const DeveloperProfileScreen(),
    );
  }
}

class DeveloperProfileScreen extends StatelessWidget {
  const DeveloperProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Developer Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 650,
                  ),

                  child: Column(
                    children: [

                      // Profile Card
                      Card(
                        elevation: 5,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),

                          child: Column(
                            children: [

                              // Profile Image
                              const CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.indigo,
                                backgroundImage: NetworkImage(
                                  'https://i.pravatar.cc/300?img=12',
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Name
                              const Text(
                                'Virajsinh Jadeja',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Qualification
                              const Text(
                                'B.Tech - Information and Communication Technology',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Developer Role
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Flutter & Software Developer',
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // About Section
                      buildSectionCard(
                        title: 'About Me',
                        icon: Icons.person,
                        child: const Text(
                          'I am a passionate software developer '
                          'interested in mobile application development, '
                          'web development and emerging technologies. '
                          'I enjoy learning new technologies and building '
                          'creative projects.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Skills Section
                      buildSectionCard(
                        title: 'Technical Skills',
                        icon: Icons.code,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: const [
                            SkillWidget(skill: 'Flutter'),
                            SkillWidget(skill: 'Dart'),
                            SkillWidget(skill: 'HTML'),
                            SkillWidget(skill: 'CSS'),
                            SkillWidget(skill: 'JavaScript'),
                            SkillWidget(skill: 'PHP'),
                            SkillWidget(skill: 'Python'),
                            SkillWidget(skill: 'MySQL'),
                            SkillWidget(skill: 'Firebase'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Education Section
                      buildSectionCard(
                        title: 'Education',
                        icon: Icons.school,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bachelor of Technology (B.Tech)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Information and Communication Technology',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Marwadi University',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Contact Section
                      buildSectionCard(
                        title: 'Contact Information',
                        icon: Icons.contact_mail,
                        child: const Column(
                          children: [
                            ContactWidget(
                              icon: Icons.email,
                              title: 'Email',
                              value: 'developer@gmail.com',
                            ),
                            Divider(),
                            ContactWidget(
                              icon: Icons.phone,
                              title: 'Phone',
                              value: '+91 9876543210',
                            ),
                            Divider(),
                            ContactWidget(
                              icon: Icons.location_on,
                              title: 'Location',
                              value: 'Rajkot, Gujarat, India',
                            ),
                            Divider(),
                            ContactWidget(
                              icon: Icons.language,
                              title: 'Website',
                              value: 'www.example.com',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Footer
                      const Text(
                        '© 2026 Virajsinh Jadeja',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Reusable Section Card
  Widget buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.indigo,
                  size: 24,
                ),

                const SizedBox(width: 10),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            child,
          ],
        ),
      ),
    );
  }
}

// Reusable Skill Widget
class SkillWidget extends StatelessWidget {
  final String skill;

  const SkillWidget({
    super.key,
    required this.skill,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 9,
      ),

      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.indigo.shade100,
        ),
      ),

      child: Text(
        skill,
        style: const TextStyle(
          color: Colors.indigo,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Reusable Contact Widget
class ContactWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ContactWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        children: [

          Icon(
            icon,
            color: Colors.indigo,
            size: 23,
          ),

          const SizedBox(width: 15),

          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          Flexible(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
