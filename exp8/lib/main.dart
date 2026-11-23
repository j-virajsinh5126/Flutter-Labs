
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('en_IN');
  await initializeDateFormatting('gu_IN');
  await initializeDateFormatting('hi_IN');

  runApp(const StudentUtilityApp());
}

// =====================================================
// TRANSLATIONS
// =====================================================

class AppTranslations {
  static const Map<String, Map<String, String>> translations = {
    'en': {
      'appTitle': 'Student Utility',
      'welcome': 'Welcome Student!',
      'subtitle': 'Your personal student information dashboard',
      'profile': 'Student Profile',
      'name': 'Name',
      'studentName': 'Virajsinh Jadeja',
      'course': 'Course',
      'courseName': 'B.Tech - ICT',
      'college': 'College',
      'collegeName': 'Marwadi University',
      'semester': 'Semester',
      'semesterValue': '5th Semester',
      'dashboard': 'Student Dashboard',
      'language': 'Select Language',
      'english': 'English',
      'gujarati': 'Gujarati',
      'hindi': 'Hindi',
      'date': 'Current Date',
      'number': 'Number Formatting',
      'currency': 'Currency',
      'settings': 'Settings',
      'changeLanguage': 'Change Application Language',
      'saved': 'Language preference saved successfully!',
      'message': 'Language changed successfully!',
      'info': 'Student Information',
      'attendance': 'Attendance',
      'attendanceValue': '85%',
      'cgpa': 'CGPA',
      'cgpaValue': '7.0',
      'subjects': 'Subjects',
      'subjectsValue': '6 Subjects',
      'select': 'Choose your preferred language',
      'today': 'Today',
      'description': 'This application demonstrates multilingual support.',
    },

    'gu': {
      'appTitle': 'વિદ્યાર્થી ઉપયોગિતા',
      'welcome': 'વિદ્યાર્થી, તમારું સ્વાગત છે!',
      'subtitle': 'તમારું વ્યક્તિગત વિદ્યાર્થી માહિતી ડેશબોર્ડ',
      'profile': 'વિદ્યાર્થી પ્રોફાઇલ',
      'name': 'નામ',
      'studentName': 'વિરાજસિંહ જાડેજા',
      'course': 'અભ્યાસક્રમ',
      'courseName': 'બી.ટેક - ICT',
      'college': 'કોલેજ',
      'collegeName': 'મારવાડી યુનિવર્સિટી',
      'semester': 'સેમેસ્ટર',
      'semesterValue': 'પાંચમું સેમેસ્ટર',
      'dashboard': 'વિદ્યાર્થી ડેશબોર્ડ',
      'language': 'ભાષા પસંદ કરો',
      'english': 'અંગ્રેજી',
      'gujarati': 'ગુજરાતી',
      'hindi': 'હિન્દી',
      'date': 'આજની તારીખ',
      'number': 'નંબર ફોર્મેટિંગ',
      'currency': 'કરન્સી',
      'settings': 'સેટિંગ્સ',
      'changeLanguage': 'એપ્લિકેશનની ભાષા બદલો',
      'saved': 'ભાષાની પસંદગી સફળતાપૂર્વક સાચવાઈ!',
      'message': 'ભાષા સફળતાપૂર્વક બદલાઈ!',
      'info': 'વિદ્યાર્થીની માહિતી',
      'attendance': 'હાજરી',
      'attendanceValue': '૮૫%',
      'cgpa': 'સીજીપીએ',
      'cgpaValue': '૭.૦',
      'subjects': 'વિષયો',
      'subjectsValue': '૬ વિષયો',
      'select': 'તમારી પસંદગીની ભાષા પસંદ કરો',
      'today': 'આજે',
      'description': 'આ એપ્લિકેશન બહુભાષી સુવિધા દર્શાવે છે.',
    },

    'hi': {
      'appTitle': 'छात्र उपयोगिता',
      'welcome': 'स्वागत है विद्यार्थी!',
      'subtitle': 'आपका व्यक्तिगत छात्र सूचना डैशबोर्ड',
      'profile': 'छात्र प्रोफाइल',
      'name': 'नाम',
      'studentName': 'विराजसिंह जडेजा',
      'course': 'पाठ्यक्रम',
      'courseName': 'बी.टेक - ICT',
      'college': 'कॉलेज',
      'collegeName': 'मारवाड़ी यूनिवर्सिटी',
      'semester': 'सेमेस्टर',
      'semesterValue': 'पांचवां सेमेस्टर',
      'dashboard': 'छात्र डैशबोर्ड',
      'language': 'भाषा चुनें',
      'english': 'अंग्रेज़ी',
      'gujarati': 'गुजराती',
      'hindi': 'हिन्दी',
      'date': 'आज की तारीख',
      'number': 'संख्या प्रारूप',
      'currency': 'मुद्रा',
      'settings': 'सेटिंग्स',
      'changeLanguage': 'ऐप की भाषा बदलें',
      'saved': 'भाषा की पसंद सफलतापूर्वक सहेजी गई!',
      'message': 'भाषा सफलतापूर्वक बदल गई!',
      'info': 'छात्र की जानकारी',
      'attendance': 'उपस्थिति',
      'attendanceValue': '८५%',
      'cgpa': 'सीजीपीए',
      'cgpaValue': '७.०',
      'subjects': 'विषय',
      'subjectsValue': '६ विषय',
      'select': 'अपनी पसंदीदा भाषा चुनें',
      'today': 'आज',
      'description': 'यह ऐप बहुभाषी सुविधा प्रदर्शित करता है।',
    },
  };

  static String get(String language, String key) {
    return translations[language]?[key] ??
        translations['en']![key] ??
        key;
  }
}

// =====================================================
// MAIN APPLICATION
// =====================================================

class StudentUtilityApp extends StatefulWidget {
  const StudentUtilityApp({super.key});

  @override
  State<StudentUtilityApp> createState() =>
      _StudentUtilityAppState();
}

class _StudentUtilityAppState extends State<StudentUtilityApp> {

  Locale selectedLocale = const Locale('en', 'IN');

  bool isLoading = true;

  String get languageCode => selectedLocale.languageCode;

  // LOAD SAVED LANGUAGE
  @override
  void initState() {
    super.initState();
    loadLanguage();
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString('selected_language');

    Locale locale = const Locale('en', 'IN');

    if (savedLanguage == 'gu') {
      locale = const Locale('gu', 'IN');
    } else if (savedLanguage == 'hi') {
      locale = const Locale('hi', 'IN');
    }

    if (!mounted) return;

    setState(() {
      selectedLocale = locale;
      isLoading = false;
    });
  }

  // CHANGE AND SAVE LANGUAGE
  Future<void> changeLanguage(String language) async {
    Locale newLocale;

    switch (language) {
      case 'gu':
        newLocale = const Locale('gu', 'IN');
        break;

      case 'hi':
        newLocale = const Locale('hi', 'IN');
        break;

      default:
        newLocale = const Locale('en', 'IN');
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('selected_language', language);

    if (!mounted) return;

    setState(() {
      selectedLocale = newLocale;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppTranslations.get(language, 'message'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Student Utility',

      locale: selectedLocale,

      supportedLocales: const [
        Locale('en', 'IN'),
        Locale('gu', 'IN'),
        Locale('hi', 'IN'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
      ),

      home: StudentHomePage(
        language: languageCode,
        onLanguageChanged: changeLanguage,
      ),
    );
  }
}

// =====================================================
// HOME PAGE
// =====================================================

class StudentHomePage extends StatelessWidget {
  final String language;
  final Function(String) onLanguageChanged;

  const StudentHomePage({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  String t(String key) {
    return AppTranslations.get(language, key);
  }

  @override
  Widget build(BuildContext context) {

    final localeName = '${language}_IN';

    final currentDate = DateFormat.yMMMMd(
      localeName,
    ).format(DateTime.now());

    final formattedNumber = NumberFormat.decimalPattern(
      localeName,
    ).format(1234567.89);

    final formattedCurrency = NumberFormat.currency(
      locale: localeName,
      symbol: '₹',
      decimalDigits: 2,
    ).format(123456.78);

    return Scaffold(

      // APP BAR
      appBar: AppBar(
        title: Text(
          t('appTitle'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        centerTitle: true,

        backgroundColor: Colors.indigo,

        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: t('language'),
            onPressed: () {
              showLanguageDialog(context);
            },
          ),
        ],
      ),

      // DRAWER
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.indigo,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.school,
                      color: Colors.indigo,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    t('appTitle'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    t('subtitle'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: Text(t('dashboard')),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: Text(t('profile')),
              onTap: () {
                Navigator.pop(context);

                showStudentProfile(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.language),
              title: Text(t('language')),
              onTap: () {
                Navigator.pop(context);
                showLanguageDialog(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(t('settings')),
              onTap: () {
                Navigator.pop(context);
                showLanguageDialog(context);
              },
            ),
          ],
        ),
      ),

      // BODY
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // WELCOME CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.indigo,
                      Colors.deepPurple,
                    ],
                  ),

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      t('welcome'),
                      style: const TextStyle(
                        fontSize: 23,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      t('subtitle'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Icon(
                      Icons.school,
                      size: 55,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // STUDENT INFORMATION
              Text(
                t('info'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              InfoCard(
                icon: Icons.person,
                title: t('name'),
                value: t('studentName'),
              ),

              InfoCard(
                icon: Icons.school,
                title: t('course'),
                value: t('courseName'),
              ),

              InfoCard(
                icon: Icons.account_balance,
                title: t('college'),
                value: t('collegeName'),
              ),

              InfoCard(
                icon: Icons.calendar_month,
                title: t('semester'),
                value: t('semesterValue'),
              ),

              const SizedBox(height: 20),

              // ACADEMIC DETAILS
              Text(
                t('dashboard'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.check_circle,
                      title: t('attendance'),
                      value: t('attendanceValue'),
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: StatCard(
                      icon: Icons.grade,
                      title: t('cgpa'),
                      value: t('cgpaValue'),
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              StatCard(
                icon: Icons.menu_book,
                title: t('subjects'),
                value: t('subjectsValue'),
                color: Colors.deepPurple,
              ),

              const SizedBox(height: 25),

              // LANGUAGE SELECTOR
              Text(
                t('language'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              languageSelector(),

              const SizedBox(height: 25),

              // LOCALIZED DATE AND NUMBER
              Text(
                t('date'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              InfoCard(
                icon: Icons.today,
                title: t('today'),
                value: currentDate,
              ),

              InfoCard(
                icon: Icons.numbers,
                title: t('number'),
                value: formattedNumber,
              ),

              InfoCard(
                icon: Icons.currency_rupee,
                title: t('currency'),
                value: formattedCurrency,
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  t('description'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // LANGUAGE SELECTION WIDGET
  Widget languageSelector() {
    return Column(
      children: [

        languageOption(
          name: 'English',
          nativeName: 'English',
          code: 'en',
          flag: '🇬🇧',
        ),

        languageOption(
          name: 'Gujarati',
          nativeName: 'ગુજરાતી',
          code: 'gu',
          flag: '🇮🇳',
        ),

        languageOption(
          name: 'Hindi',
          nativeName: 'हिन्दी',
          code: 'hi',
          flag: '🇮🇳',
        ),
      ],
    );
  }

  Widget languageOption({
    required String name,
    required String nativeName,
    required String code,
    required String flag,
  }) {
    final isSelected = language == code;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),

      child: RadioListTile<String>(
        value: code,
        groupValue: language,

        activeColor: Colors.indigo,

        title: Text(
          '$flag  $nativeName',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(name),

        onChanged: (value) {
          if (value != null) {
            onLanguageChanged(value);
          }
        },

        selected: isSelected,
      ),
    );
  }

  // LANGUAGE DIALOG
  void showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t('language')),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(t('select')),

              const SizedBox(height: 15),

              languageDialogOption(
                dialogContext,
                'English',
                'en',
              ),

              languageDialogOption(
                dialogContext,
                'ગુજરાતી',
                'gu',
              ),

              languageDialogOption(
                dialogContext,
                'हिन्दी',
                'hi',
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget languageDialogOption(
    BuildContext dialogContext,
    String name,
    String code,
  ) {
    return ListTile(
      title: Text(name),

      trailing: language == code
          ? const Icon(
              Icons.check_circle,
              color: Colors.green,
            )
          : null,

      onTap: () {
        Navigator.pop(dialogContext);
        onLanguageChanged(code);
      },
    );
  }

  // STUDENT PROFILE DIALOG
  void showStudentProfile(BuildContext context) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: Text(t('profile')),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.indigo,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 15),

              Text(t('studentName')),

              Text(t('courseName')),

              Text(t('collegeName')),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// =====================================================
// REUSABLE INFORMATION CARD
// =====================================================

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade50,
          child: Icon(
            icon,
            color: Colors.indigo,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),

        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// REUSABLE STATISTICS CARD
// =====================================================

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Icon(
              icon,
              color: color,
              size: 28,
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
