import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

List<CameraDescription> cameras = [];

class AppColors {
  static const bg = Color(0xFFFFF7F9);
  static const pink = Color(0xFFF09BB4);
  static const softPink = Color(0xFFF6C8D7);
  static const lightPink = Color(0xFFFFE8EF);
  static const accent = Color(0xFFD46A8F);
  static const accentHome = Color(0xFFD96A91);
  static const tab = Color(0xFFE994B5);
  static const brown = Color(0xFF7A2E48);
  static const subtitle = Color(0xFF9E4864);
}

final Map<String, String> skinShadeProfile = {
  'name': '',
  'email': '',
  'username': '',
  'birth': '',
};
String? skinShadeLatestType;
String? skinShadeProfileImagePath;
final List<_ReminderItem> skinShadeReminderItems = <_ReminderItem>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Error mengambil kamera: $e');
  }
  runApp(const SkinShadeApp());
}

void _goTo(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

void _goToAndClear(BuildContext context, Widget page) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => page),
    (route) => false,
  );
}

void _showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

InputDecoration _authDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.accent),
    filled: true,
    fillColor: AppColors.softPink,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  );
}

Widget _pinkButton(String text, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}

class _BackTitleRow extends StatelessWidget {
  final String title;
  final double fontSize;
  final double gap;

  const _BackTitleRow(this.title, {this.fontSize = 22, this.gap = 8});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.accent, size: 26),
        ),
        SizedBox(width: gap),
        Text(
          title,
          style: TextStyle(
            color: AppColors.accent,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _GradientBanner extends StatelessWidget {
  final Widget child;
  const _GradientBanner({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.pink, AppColors.softPink],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

Widget _pinkPicker(BuildContext context, Widget? child) {
  return Theme(
    data: Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.pink,
        surface: AppColors.bg,
      ),
    ),
    child: child!,
  );
}

class SkinShadeApp extends StatelessWidget {
  const SkinShadeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skin&Shade',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.bg,
        timePickerTheme: TimePickerThemeData(
          backgroundColor: AppColors.bg,
          hourMinuteColor: WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.pink
                  : AppColors.softPink),
          hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? Colors.white
                  : AppColors.brown),
          dayPeriodColor: WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.pink
                  : Colors.white),
          dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? Colors.white
                  : AppColors.accent),
          dayPeriodBorderSide: const BorderSide(color: AppColors.pink),
          dialHandColor: AppColors.pink,
          dialBackgroundColor: AppColors.softPink,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) _toLogin();
    });
  }

  void _toLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _toLogin,
        child: SizedBox.expand(
          child: Image.asset(
            'assets/images/home/logo_skinshade.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool showPassword = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _signIn() {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      _showMessage(context, 'Isi email dan password terlebih dahulu.');
      return;
    }
    final emailName = email.text.split('@').first;
    skinShadeProfile['email'] = email.text.trim();
    if ((skinShadeProfile['name'] ?? '').isEmpty) {
      skinShadeProfile['name'] = emailName;
    }
    if ((skinShadeProfile['username'] ?? '').isEmpty) {
      skinShadeProfile['username'] = emailName;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'SKIN&SHADE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.normal,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masuk untuk melanjutkan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.brown),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _authDecoration('Email', Icons.email_outlined),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: password,
                  obscureText: !showPassword,
                  decoration:
                      _authDecoration('Password', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(showPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => showPassword = !showPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _pinkButton('Sign In', _signIn),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => _goTo(context, const SignUpScreen()),
                  child: const Text(
                    'Belum punya akun? Sign Up',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
                TextButton(
                  onPressed: () => _goTo(context, const ForgotPasswordScreen()),
                  child: const Text(
                    'Lupa password?',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    username.dispose();
    password.dispose();
    super.dispose();
  }

  void _register() {
    final kosong = name.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        username.text.trim().isEmpty ||
        password.text.isEmpty;
    if (kosong) {
      _showMessage(context, 'Lengkapi semua data terlebih dahulu.');
      return;
    }
    skinShadeProfile['name'] = name.text.trim();
    skinShadeProfile['email'] = email.text.trim();
    skinShadeProfile['username'] = username.text.trim();
    _goToAndClear(context, const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.accent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: name,
                decoration: _authDecoration('Nama lengkap', Icons.person_outline),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: _authDecoration('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: username,
                decoration: _authDecoration('Username', Icons.alternate_email),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: _authDecoration('Password', Icons.lock_outline),
              ),
              const SizedBox(height: 24),
              _pinkButton('Buat Akun', _register),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _menuTile({
    required BuildContext context,
    required String title,
    required String image,
    required Color color,
    required Widget page,
    double imageX = 0,
    double imageY = 0,
  }) {
    return GestureDetector(
      onTap: () => _goTo(context, page),
      child: buildMenuCard(
        title: title,
        image: image,
        color: color,
        imageX: imageX,
        imageY: imageY,
      ),
    );
  }

  Widget _banner(BuildContext context) {
    return GestureDetector(
      onTap: () => _goTo(context, const SkinAnalysisScreen()),
      child: Container(
        height: 162,
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.pink, AppColors.softPink],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: 18,
              top: 0,
              bottom: 0,
              width: 175,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kenali Kondisi Kulitmu\n'
                    'dan Pilih Skincare\n'
                    '& Makeup yang Tepat\n'
                    'Untukmu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () =>
                          _goTo(context, const SkinAnalysisScreen()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.accentHome,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        'Mulai check kulit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -8,
              top: 16,
              width: 230,
              height: 154,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 230,
                    height: 190,
                    child: Image.asset(
                      'assets/images/home/skinshade.png',
                      width: 230,
                      height: 190,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Menu',
                    onPressed: () => _goTo(context, const SideMenuScreen()),
                    icon: const Icon(Icons.menu,
                        color: AppColors.accentHome, size: 29),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const TextField(
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Cari...',
                    hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 16),
                    prefixIcon: Icon(Icons.search,
                        color: AppColors.accentHome, size: 26),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _banner(context),
              const SizedBox(height: 22),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.83,
                children: [
                  _menuTile(
                    context: context,
                    title: 'Skincare',
                    image: 'assets/images/home/Skincare.png',
                    color: AppColors.pink,
                    page: const SkincareScreen(),
                    imageX: 5,
                    imageY: 4,
                  ),
                  _menuTile(
                    context: context,
                    title: 'Makeup',
                    image: 'assets/images/home/Makeup.png',
                    color: AppColors.softPink,
                    page: const MakeupScreen(),
                    imageY: 4,
                  ),
                  _menuTile(
                    context: context,
                    title: 'AR Try-On',
                    image: 'assets/images/home/Atry-on.png',
                    color: AppColors.softPink,
                    page: const ArTryOnScreen(),
                  ),
                  _menuTile(
                    context: context,
                    title: 'Reminder',
                    image: 'assets/images/home/reminder.png',
                    color: AppColors.pink,
                    page: const ReminderScreen(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(context),
    );
  }
}

Widget buildMenuCard({
  required String title,
  required String image,
  required Color color,
  required double imageX,
  required double imageY,
}) {
  final isReminder = title == 'Reminder';

  return Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        const SizedBox(height: 12),
        Transform.translate(
          offset: const Offset(0, 4),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          height: isReminder ? 125 : 135,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isReminder ? 18 : 14,
              vertical: 4,
            ),
            child: Transform.translate(
              offset: Offset(imageX, imageY),
              child: Image.asset(image, fit: BoxFit.contain),
            ),
          ),
        ),
        const Spacer(),
        const SizedBox(height: 8),
      ],
    ),
  );
}

Widget buildBottomNavigation(BuildContext context) {
  Widget navIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.accent, size: 28),
    );
  }

  return Container(
    height: 70,
    decoration: const BoxDecoration(
      color: AppColors.bg,
      border: Border(
        top: BorderSide(color: Color(0xFFFCECEF), width: 1.5),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        navIcon(Icons.home_outlined,
            () => _goToAndClear(context, const HomeScreen())),
        navIcon(Icons.notifications_none_rounded,
            () => _goTo(context, const NotificationSettingScreen())),
        navIcon(Icons.person_outline_rounded,
            () => _goTo(context, const ProfileScreen())),
      ],
    ),
  );
}

class SkinAnalysisScreen extends StatefulWidget {
  const SkinAnalysisScreen({super.key});

  @override
  State<SkinAnalysisScreen> createState() => _SkinAnalysisScreenState();
}

class _SkinAnalysisScreenState extends State<SkinAnalysisScreen> {
  int selectedStep = 1;
  final Map<int, int> jawaban = {};

  final List<Map<String, dynamic>> pertanyaan = [
    {
      'pertanyaan': 'Bagaimana kondisi kulitmu setelah mencuci wajah?',
      'opsi': ['Terasa kering', 'Terasa berminyak', 'Berminyak di T-Zone', 'Mudah kemerahan'],
    },
    {
      'pertanyaan': 'Bagian wajah mana yang paling sering berminyak?',
      'opsi': ['Seluruh wajah', 'Hanya area tertentu', 'T-Zone', 'Tidak pernah'],
    },
    {
      'pertanyaan': 'Bagaimana kondisi kulitmu saat bangun tidur?',
      'opsi': ['Terasa kering', 'Terasa berminyak', 'Berminyak di T-Zone', 'Mudah kemerahan'],
    },
    {
      'pertanyaan': 'Seberapa sering kulitmu terasa kering atau mengelupas?',
      'opsi': ['Sangat sering', 'Sering', 'Kadang-kadang', 'Tidak pernah'],
    },
    {
      'pertanyaan': 'Secara keseluruhan, kondisi kulitmu sepanjang hari adalah...',
      'opsi': ['Berminyak di seluruh wajah', 'Hanya di T-Zone', 'Seimbang dan nyaman', 'Cenderung kering'],
    },
  ];

  String tentukanJenisKulit() {
    final skor = <String, int>{
      'Berminyak': 0,
      'Kering': 0,
      'Kombinasi': 0,
      'Normal': 0,
      'Sensitif': 0,
    };

    for (var i = 0; i < pertanyaan.length; i++) {
      final idx = jawaban[i];
      if (idx == null) continue;
      final pilihan = (pertanyaan[i]['opsi'] as List<String>)[idx];

      if (['Terasa kering', 'Sangat sering', 'Sering', 'Cenderung kering']
          .contains(pilihan)) {
        skor['Kering'] = skor['Kering']! + (pilihan == 'Sering' ? 1 : 2);
      }
      if (['Terasa berminyak', 'Seluruh wajah', 'Berminyak di seluruh wajah']
          .contains(pilihan)) {
        skor['Berminyak'] = skor['Berminyak']! + 2;
      }
      if (['Berminyak di T-Zone', 'T-Zone', 'Hanya di T-Zone', 'Hanya area tertentu']
          .contains(pilihan)) {
        skor['Kombinasi'] = skor['Kombinasi']! + 2;
      }
      if (pilihan == 'Mudah kemerahan') {
        skor['Sensitif'] = skor['Sensitif']! + 2;
      }
      if (['Seimbang dan nyaman', 'Tidak pernah', 'Kadang-kadang']
          .contains(pilihan)) {
        skor['Normal'] = skor['Normal']! + 1;
      }
    }

    var hasil = 'Normal';
    var tertinggi = -1;
    for (final entry in skor.entries) {
      if (entry.value > tertinggi) {
        tertinggi = entry.value;
        hasil = entry.key;
      }
    }
    return hasil;
  }

  void _lanjut() {
    if (!jawaban.containsKey(selectedStep - 1)) {
      _showMessage(context, 'Pilih jawaban terlebih dahulu.');
      return;
    }
    if (selectedStep < pertanyaan.length) {
      setState(() => selectedStep++);
    } else {
      _goTo(context, HasilAnalysisScreen(jenisKulit: tentukanJenisKulit()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = pertanyaan[selectedStep - 1];
    final opsi = List<String>.from(data['opsi'] as List);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.accent),
                    onPressed: () {
                      if (selectedStep > 1) {
                        setState(() => selectedStep--);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const Icon(Icons.notifications_none_rounded,
                      color: AppColors.accent, size: 28),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.pink, AppColors.softPink],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    const Positioned(
                      left: 14,
                      top: 25,
                      width: 165,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kenali Kondisi Kulitmu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Jawab beberapa pertanyaan berikut untuk mengetahui perkiraan jenis kulitmu.',
                            style: TextStyle(
                                color: Colors.white, fontSize: 10, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: -15,
                      bottom: 0,
                      width: 160,
                      height: 145,
                      child: Image.asset(
                        'assets/images/home/skin analysis.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final nomor = index + 1;
                  final aktif = selectedStep == nomor;
                  return Container(
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: aktif ? AppColors.pink : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$nomor',
                      style: TextStyle(
                        color: aktif ? Colors.white : AppColors.accent,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text(
                data['pertanyaan'] as String,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(opsi.length, (index) {
                final dipilih = jawaban[selectedStep - 1] == index;
                return GestureDetector(
                  onTap: () => setState(() => jawaban[selectedStep - 1] = index),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      color: dipilih ? AppColors.accent : AppColors.softPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      opsi[index],
                      style: TextStyle(
                        color: dipilih ? Colors.white : AppColors.brown,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _lanjut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedStep == pertanyaan.length ? 'Lihat Hasil' : 'Lanjut',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(context),
    );
  }
}

class HasilAnalysisScreen extends StatelessWidget {
  final String jenisKulit;
  const HasilAnalysisScreen({super.key, required this.jenisKulit});

  static const Map<String, Map<String, String>> dataKulit = {
    'Berminyak': {
      'deskripsi': 'Kulit cenderung menghasilkan minyak berlebih.',
      'bahan': 'Niacinamide',
      'tips': 'Pilih pelembap ringan dan hindari membersihkan wajah secara berlebihan.',
    },
    'Kering': {
      'deskripsi': 'Kulit cenderung terasa kering atau tertarik.',
      'bahan': 'Hyaluronic Acid dan Ceramide',
      'tips': 'Gunakan pelembap untuk membantu menjaga kelembapan kulit.',
    },
    'Kombinasi': {
      'deskripsi': 'Sebagian area wajah cenderung berminyak, sementara area lainnya lebih kering.',
      'bahan': 'Niacinamide dan Hyaluronic Acid',
      'tips': 'Sesuaikan perawatan dengan kondisi setiap area wajah.',
    },
    'Normal': {
      'deskripsi': 'Kulit cenderung terasa seimbang dan nyaman.',
      'bahan': 'Niacinamide dan Ceramide',
      'tips': 'Jaga kelembapan kulit dan gunakan sunscreen.',
    },
    'Sensitif': {
      'deskripsi': 'Kulit dapat mudah mengalami kemerahan atau iritasi.',
      'bahan': 'Ceramide dan Panthenol',
      'tips': 'Pilih produk berformula lembut dan lakukan uji tempel sebelum penggunaan.',
    },
  };

  @override
  Widget build(BuildContext context) {
    skinShadeLatestType = jenisKulit;
    final hasil = dataKulit[jenisKulit] ?? dataKulit['Normal']!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BackTitleRow('Hasil Analisis', fontSize: 19, gap: 0),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text(
                      'KULIT ${jenisKulit.toUpperCase()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasil['deskripsi']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bahan Aktif yang Bisa Dipelajari',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(hasil['bahan']!, style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tips Perawatan',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.pink,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  hasil['tips']!,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12, height: 1.7),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _goTo(context, const SkincareScreen()),
                  icon: const Icon(Icons.menu_book_outlined, color: Colors.white),
                  label: const Text(
                    'Baca Panduan Skincare',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Hasil ini merupakan perkiraan berdasarkan jawabanmu, bukan diagnosis medis.',
                style: TextStyle(color: Colors.black54, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(context),
    );
  }
}

class ArTryOnScreen extends StatefulWidget {
  const ArTryOnScreen({super.key});

  @override
  State<ArTryOnScreen> createState() => _ArTryOnScreenState();
}

class _ArTryOnScreenState extends State<ArTryOnScreen> {
  int selectedTab = 0;
  int selectedColor = 1;

  CameraController? _cameraController;
  bool _cameraReady = false;
  String? _cameraError;

  final List<Color> lipstickColors = const [
    Color(0xFFE7A1BE),
    Color(0xFFED98B3),
    Color(0xFFF1C0D0),
    Color(0xFFF4D6DE),
  ];

  final List<Color> blushColors = const [
    Color(0xFFF0A1BC),
    Color(0xFFF19BB6),
    Color(0xFFF4B6C9),
    Color(0xFFF6D0DB),
  ];

  final List<Color> foundationColors = const [
    Color(0xFFD6A17E),
    Color(0xFFE0B08D),
    Color(0xFFEDC3A7),
    Color(0xFFF3D7C5),
  ];

  List<Color> get currentColors {
    if (selectedTab == 1) return blushColors;
    if (selectedTab == 2) return foundationColors;
    return lipstickColors;
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) {
      if (mounted) {
        setState(() => _cameraError = 'Kamera tidak ditemukan di perangkat ini.');
      }
      return;
    }
    final cam = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    final controller =
        CameraController(cam, ResolutionPreset.medium, enableAudio: false);
    try {
      await controller.initialize();
    } on CameraException catch (e) {
      await controller.dispose();
      if (mounted) {
        setState(() => _cameraError = e.code == 'CameraAccessDenied'
            ? 'Izin kamera ditolak. Aktifkan izin kamera di pengaturan.'
            : 'Kamera tidak dapat dibuka.');
      }
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _cameraController = controller;
      _cameraReady = true;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Widget _buildCameraLayer() {
    final c = _cameraController;
    if (_cameraReady && c != null && c.value.isInitialized) {
      final size = c.value.previewSize!;
      return ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: size.height,
            height: size.width,
            child: CameraPreview(c),
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _cameraError != null
            ? Text(
                _cameraError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.accent, fontSize: 13),
              )
            : const CircularProgressIndicator(color: AppColors.pink),
      ),
    );
  }

  Widget _buildMakeupOverlay() {
    if (!_cameraReady) return const SizedBox.shrink();
    final color = currentColors[selectedColor];

    Widget blob(double w, double h, Alignment a, double opacity) {
      return Align(
        alignment: a,
        child: FractionallySizedBox(
          widthFactor: w,
          heightFactor: h,
          child: ClipOval(child: ColoredBox(color: color.withOpacity(opacity))),
        ),
      );
    }

    final List<Widget> layers;
    if (selectedTab == 1) {
      layers = [
        blob(0.2, 0.12, const Alignment(-0.45, 0.15), 0.45),
        blob(0.2, 0.12, const Alignment(0.45, 0.15), 0.45),
      ];
    } else if (selectedTab == 2) {
      layers = [blob(0.6, 0.78, Alignment.center, 0.3)];
    } else {
      layers = [blob(0.24, 0.07, const Alignment(0, 0.42), 0.6)];
    }
    return IgnorePointer(child: Stack(fit: StackFit.expand, children: layers));
  }

  Widget _buildTab(String title, int index) {
    final selected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
          selectedColor = 1;
        });
      },
      child: Container(
        height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.tab : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.tab,
            fontSize: 15,
            fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 54,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.accent, size: 28),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'AR Try-On',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 54),
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    border: Border.all(color: AppColors.pink, width: 2),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildCameraLayer(),
                      _buildMakeupOverlay(),
                      CustomPaint(
                        painter: _CameraFramePainter(),
                        child: const Center(child: _FaceOutline()),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 72),
              Row(
                children: [
                  Expanded(child: _buildTab('Lipstick', 0)),
                  Expanded(child: _buildTab('Blush', 1)),
                  Expanded(child: _buildTab('Foundation', 2)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(currentColors.length, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = index),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: currentColors[index],
                        border: Border.all(
                          color: selectedColor == index
                              ? AppColors.accent
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 26),
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: currentColors[selectedColor],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(context),
    );
  }
}

class _CameraFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.pink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.square;

    const double inset = 58;
    const double corner = 44;

    void drawCorner(double x, double y, double sx, double sy) {
      canvas.drawLine(Offset(x, y), Offset(x + sx * corner, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x, y + sy * corner), paint);
    }

    final right = size.width - inset;
    final bottom = size.height - inset;

    drawCorner(inset, inset, 1, 1);
    drawCorner(right, inset, -1, 1);
    drawCorner(inset, bottom, 1, -1);
    drawCorner(right, bottom, -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FaceOutline extends StatelessWidget {
  const _FaceOutline();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(150, 150),
      painter: _FaceOutlinePainter(),
    );
  }
}

class _FaceOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.pink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final centerX = size.width / 2;

    canvas.drawCircle(Offset(centerX, 36), 28, paint);

    final shoulderPath = Path()
      ..moveTo(32, 125)
      ..quadraticBezierTo(centerX, 78, 118, 125);
    canvas.drawPath(shoulderPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExpandableCardList extends StatefulWidget {
  final List<Map<String, String>> items;
  const _ExpandableCardList({required this.items});

  @override
  State<_ExpandableCardList> createState() => _ExpandableCardListState();
}

class _ExpandableCardListState extends State<_ExpandableCardList> {
  int expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(widget.items.length, (index) {
            final isExpanded = expandedIndex == index;
            final isSensitif = index == 4;

            final double cardWidth = isExpanded || isSensitif
                ? constraints.maxWidth
                : (constraints.maxWidth - 12) / 2;

            return GestureDetector(
              onTap: () {
                setState(() => expandedIndex = isExpanded ? -1 : index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: cardWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isExpanded ? AppColors.pink : AppColors.softPink,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isExpanded
                      ? [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.items[index]['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isExpanded) ...[
                      const SizedBox(height: 10),
                      Text(
                        widget.items[index]['desc']!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11, height: 1.4),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      const Text(
                        '...',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class SkincareScreen extends StatelessWidget {
  const SkincareScreen({super.key});

  static const List<Map<String, String>> skinTypes = [
    {
      'title': 'Kulit normal',
      'desc':
          'Berdasarkan kajian dermatologi dalam jurnal Widya Lukitasari et al. (2025) dan Suci Ramadani et al. (2026), kulit normal memiliki keseimbangan kadar sebum dan hidrasi yang ideal sehingga fungsi pelindung kulit bekerja secara stabil, di mana perawatannya berfokus pada pemeliharaan kestabilan serta perlindungan dini menggunakan pembersih lembut dan tabir surya minimal SPF 30.'
    },
    {
      'title': 'Kulit kering',
      'desc':
          'Berdasarkan jurnal Suci Ramadani et al. (2026), kulit kering mengalami defisiensi atau penurunan jumlah Natural Moisturizing Factor (NMF) sehingga kehilangan kemampuan mengikat air dan memicu dehidrasi, tekstur kasar, kusam, hingga kerutan dini, yang perawatannya membutuhkan pemulihan kelembapan intensif menggunakan pelembap kaya hidrasi seperti Ceramide dan Hyaluronic Acid.'
    },
    {
      'title': 'Kulit berminyak',
      'desc':
          'Berdasarkan riset Nurfadilah Pratiwi et al. (2023), kulit berminyak kerap membuat remaja tergiur produk pemutih instan non-BPOM akibat kurangnya pengetahuan merawat kulit berjerawat, sehingga perawatannya memerlukan kandungan pengontrol sebum seperti Salicylic Acid dan Niacinamide serta kewajiban menggunakan produk berizin resmi BPOM.'
    },
    {
      'title': 'Kulit kombinasi',
      'desc':
          'Mengacu pada teori tata rias Mila Noviana & Yasmi Teni Susiati (2015), kulit kombinasi memiliki dua kondisi berbeda dalam satu wajah di mana area T-Zone cenderung berminyak sementara area pipi normal atau kering, sehingga membutuhkan pendekatan perawatan seimbang per zona menggunakan pembersih yang tidak membuat pipi tertarik dan pelembap berbasis gel yang ringan.'
    },
    {
      'title': 'Kulit sensitif',
      'desc':
          'Berdasarkan kajian keamanan produk dalam jurnal Widya Lukitasari et al. (2025) dan Nurfadilah Pratiwi et al. (2023), kulit sensitif merupakan tipe yang sangat reaktif dan mudah mengalami kemerahan, perih, atau iritasi akibat bahan kimia keras, sehingga perawatannya harus berfokus pada bahan penenang seperti Centella Asiatica atau Panthenol dengan menghindari pewangi buatan serta melakukan uji coba patch test terlebih dahulu.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BackTitleRow('Skincare'),
              const SizedBox(height: 16),
              _GradientBanner(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kenali kondisi kulitmu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Jawab beberapa pertanyaan berikut\nuntuk mengetahui jenis kulit dan\nrekomendasi perawatan yang sesuai',
                      style: TextStyle(
                          color: Colors.white, fontSize: 11, height: 1.3),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _goTo(context, const SkinAnalysisScreen()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Mulai check kulit ->',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _ExpandableCardList(items: skinTypes),
            ],
          ),
        ),
      ),
    );
  }
}

class MakeupScreen extends StatelessWidget {
  const MakeupScreen({super.key});

  static const List<Map<String, String>> makeupTypes = [
    {
      'title': 'Kulit normal',
      'desc':
          'Mengacu pada teori tata rias harian (street make-up) oleh Mila Noviana & Yasmi Teni Susiati (2015), kulit normal memiliki kestabilan struktur yang memudahkan pengaplikasian kosmetik dekoratif, di mana perawatannya berfokus pada pemilihan produk dengan hasil akhir natural (natural finish) yang dapat menonjolkan keindahan asli wajah sekaligus meningkatkan rasa percaya diri remaja dalam interaksi sosial (Layyinatus Shafiyah et al., 2025).'
    },
    {
      'title': 'Kulit kering',
      'desc':
          'Berdasarkan kajian tata rias dan perawatan kulit, kulit kering rentan mengalami cracking atau membuat riasan terlihat bersisik akibat defisiensi Natural Moisturizing Factor (Suci Ramadani et al., 2026), sehingga pemilihan produk makeup harus berfokus pada formula yang menghidrasi dengan hasil akhir dewy atau glow guna menjaga kelembapan sekaligus mendukung penampilan yang lebih segar dan percaya diri.'
    },
    {
      'title': 'Kulit berminyak',
      'desc':
          'Mengacu pada riset perilaku kosmetik remaja (Mila Noviana & Yasmi Teni Susiati, 2015; Nurfadilah Pratiwi et al., 2023), kulit berminyak cenderung membuat riasan mudah luntur dan mengkilap, sehingga membutuhkan produk makeup berformula oil-control, matte finish, dan non-komedogenik yang sudah berizin resmi BPOM agar tetap tahan lama sekaligus aman bagi kesehatan kulit.'
    },
    {
      'title': 'Kulit kombinasi',
      'desc':
          'Berdasarkan konsep tata rias wajah yang memperhatikan koreksi bentuk dan zona wajah (Mila Noviana & Yasmi Teni Susiati, 2015), kulit kombinasi memerlukan teknik riasan penyeimbang, seperti penggunaan translucent powder atau oil-control primer secara spesifik di area T-Zone yang berminyak agar riasan tetap rapi tanpa membuat area pipi yang cenderung kering menjadi semakin tertarik.'
    },
    {
      'title': 'Kulit sensitif',
      'desc':
          'Berdasarkan kajian keamanan produk kosmetik pada remaja (Widya Lukitasari et al., 2025; Nurfadilah Pratiwi et al., 2023), kulit sensitif sangat reaktif terhadap bahan kimia keras, sehingga dalam pemilihan produk makeup dekoratif wajib menghindari pewangi buatan dan bahan iritatif, serta mengutamakan formula hypoallergenic yang ringan untuk mencegah peradangan sekaligus memberikan kenyamanan dalam berias.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _BackTitleRow('Makeup'),
              SizedBox(height: 16),
              _GradientBanner(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Makeup',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Temukan tips dan rekomendasi finish makeup\nyang sesuai dengan jenis kulit dan kebutuhanmu',
                      style: TextStyle(
                          color: Colors.white, fontSize: 11, height: 1.3),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _ExpandableCardList(items: makeupTypes),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.brown,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionBox(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softPink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: Colors.white, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BackTitleRow('Setting'),
              const SizedBox(height: 24),
              _sectionTitle('Akun & keamanan'),
              _sectionBox([
                _buildSettingTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Informasi pribadi',
                  onTap: () => _goTo(context, const ProfileScreen()),
                ),
                _buildSettingTile(
                  icon: Icons.vpn_key_outlined,
                  title: 'Ganti kata sandi',
                  onTap: () => _goTo(context, const ChangePasswordScreen()),
                ),
                _buildSettingTile(
                  icon: Icons.security_outlined,
                  title: 'Pengaturan privasi',
                  onTap: () => _goTo(context, const PrivacySettingScreen()),
                ),
              ]),
              const SizedBox(height: 20),
              _sectionTitle('Preferensi'),
              _sectionBox([
                _buildSettingTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifikasi & pengingat',
                  onTap: () => _goTo(context, const ReminderScreen()),
                ),
                _buildSettingTile(
                  icon: Icons.language_outlined,
                  title: 'Bahasa',
                  onTap: () =>
                      _showMessage(context, 'Pengaturan bahasa belum tersedia.'),
                ),
              ]),
              const SizedBox(height: 20),
              _sectionTitle('Syarat & ketentuan'),
              _sectionBox([
                _buildSettingTile(
                  icon: Icons.description_outlined,
                  title: 'Syarat & ketentuan',
                  onTap: () => _goTo(context, const TermsScreen()),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderItem {
  _ReminderItem(this.title, this.date, this.time, this.enabled);

  String title;
  DateTime date;
  TimeOfDay time;
  bool enabled;
}

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
  final titleController = TextEditingController(text: 'Rutinitas skincare');
  final List<_ReminderItem> items = skinShadeReminderItems;
  bool pagi = true;
  bool malam = true;

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: _pinkPicker,
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: _pinkPicker,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  void _tambahJadwal() {
    if (titleController.text.trim().isEmpty) {
      _showMessage(context, 'Isi nama jadwal terlebih dahulu.');
      return;
    }
    setState(() {
      items.add(_ReminderItem(
          titleController.text.trim(), selectedDate, selectedTime, true));
    });
    _showMessage(context, 'Jadwal ditambahkan ke daftar pengingat.');
  }

  Widget _outlineAction(String label, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.accent),
      label: Text(label, style: const TextStyle(color: AppColors.accent)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        side: const BorderSide(color: AppColors.accent),
        backgroundColor: AppColors.lightPink,
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BackTitleRow('Reminder', gap: 0),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih tanggal pengingat',
                      style: TextStyle(
                        color: AppColors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(
                                fontSize: 16, color: AppColors.brown),
                          ),
                        ),
                        _outlineAction('Kalender', Icons.calendar_month, pickDate),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Waktu: ${selectedTime.format(context)}',
                            style: const TextStyle(color: AppColors.brown),
                          ),
                        ),
                        _outlineAction('Pilih waktu', Icons.access_time, pickTime),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: _authDecoration(
                    'Nama jadwal, mis. pakai sunscreen', Icons.edit_calendar),
              ),
              const SizedBox(height: 12),
              _pinkButton('Tambah Jadwal', _tambahJadwal),
              const SizedBox(height: 20),
              _sectionTitle('Rutinitas cepat'),
              SwitchListTile(
                title: const Text('Rutinitas pagi'),
                value: pagi,
                activeTrackColor: AppColors.pink,
                onChanged: (v) => setState(() => pagi = v),
              ),
              SwitchListTile(
                title: const Text('Rutinitas malam'),
                value: malam,
                activeTrackColor: AppColors.pink,
                onChanged: (v) => setState(() => malam = v),
              ),
              const SizedBox(height: 8),
              _sectionTitle('Jadwal tersimpan'),
              const SizedBox(height: 8),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Belum ada jadwal tambahan.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ...items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Card(
                  color: AppColors.softPink,
                  elevation: 0,
                  child: ListTile(
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${item.date.day}/${item.date.month}/${item.date.year} • ${item.time.format(context)}',
                      style: const TextStyle(color: AppColors.brown),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: item.enabled,
                          activeTrackColor: AppColors.pink,
                          onChanged: (v) => setState(() => item.enabled = v),
                        ),
                        IconButton(
                          onPressed: () => setState(() => items.removeAt(i)),
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              _pinkButton('Simpan', () {
                _showMessage(
                    context, 'Pengaturan pengingat disimpan untuk sesi ini.');
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(context),
    );
  }
}

class SideMenuScreen extends StatelessWidget {
  const SideMenuScreen({super.key});

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.accent, size: 26),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => _goTo(context, const ProfileScreen()),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: AppColors.softPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline_rounded,
                        size: 65, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildMenuItem(
                icon: Icons.spa_outlined,
                title: 'Skincare',
                onTap: () => _goTo(context, const SkincareScreen()),
              ),
              _buildMenuItem(
                icon: Icons.brush_outlined,
                title: 'Makeup',
                onTap: () => _goTo(context, const MakeupScreen()),
              ),
              _buildMenuItem(
                icon: Icons.camera_front_outlined,
                title: 'AR Try-On',
                onTap: () => _goTo(context, const ArTryOnScreen()),
              ),
              _buildMenuItem(
                icon: Icons.alarm_outlined,
                title: 'Reminder',
                onTap: () => _goTo(context, const ReminderScreen()),
              ),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Setting',
                onTap: () => _goTo(context, const SettingScreen()),
              ),
              const Spacer(),
              _buildMenuItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const LogoutDialog(),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController name;
  late final TextEditingController email;
  late final TextEditingController username;
  late final TextEditingController birth;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: skinShadeProfile['name'] ?? '');
    email = TextEditingController(text: skinShadeProfile['email'] ?? '');
    username = TextEditingController(text: skinShadeProfile['username'] ?? '');
    birth = TextEditingController(text: skinShadeProfile['birth'] ?? '');
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    username.dispose();
    birth.dispose();
    super.dispose();
  }

  Future<void> chooseBirth() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: _pinkPicker,
    );
    if (date != null) {
      setState(() => birth.text = '${date.day}/${date.month}/${date.year}');
    }
  }

  Future<void> choosePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        setState(() => skinShadeProfileImagePath = photo.path);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(context,
            'Foto belum dapat dipilih. Periksa paket image_picker lalu jalankan flutter pub get.');
      }
    }
  }

  void saveProfile() {
    skinShadeProfile['name'] = name.text.trim();
    skinShadeProfile['email'] = email.text.trim();
    skinShadeProfile['username'] = username.text.trim();
    skinShadeProfile['birth'] = birth.text.trim();
    setState(() {});
    _showMessage(context, 'Profil berhasil disimpan untuk sesi ini.');
  }

  Widget field(
    String label,
    TextEditingController c, {
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboard,
        style: const TextStyle(color: AppColors.brown),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Color(0xFF9B536B)),
          filled: true,
          fillColor: AppColors.lightPink,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 125,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.softPink,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 8,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppColors.accent),
                    ),
                  ),
                  Positioned(
                    top: 47,
                    child: GestureDetector(
                      onTap: choosePhoto,
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: AppColors.pink,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: skinShadeProfileImagePath != null
                            ? Image.file(File(skinShadeProfileImagePath!),
                                fit: BoxFit.cover)
                            : const Icon(Icons.add_a_photo_outlined,
                                size: 42, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 38),
              Text(
                name.text.isEmpty ? 'Nama Pengguna' : name.text,
                style: const TextStyle(
                  color: AppColors.brown,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                username.text.isEmpty ? '@username' : '@${username.text}',
                style: const TextStyle(color: AppColors.accent, fontSize: 13),
              ),
              TextButton.icon(
                onPressed: choosePhoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Tambah foto profil'),
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profil Saya',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 14),
                    field('Nama lengkap', name),
                    field('Email', email, keyboard: TextInputType.emailAddress),
                    field('Username', username),
                    field('Tanggal lahir', birth,
                        readOnly: true, onTap: chooseBirth),
                    _pinkButton('Simpan Profil', saveProfile),
                    const SizedBox(height: 22),
                    const Divider(color: AppColors.softPink, thickness: 1.5),
                    const SizedBox(height: 12),
                    const Text(
                      'Hasil Analisis Kulit',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.softPink,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jenis kulit kamu',
                            style: TextStyle(
                              color: AppColors.brown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            skinShadeLatestType ??
                                'Belum ada hasil analisis. Isi kuesioner terlebih dahulu.',
                            style: const TextStyle(color: AppColors.brown),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  _goTo(context, const SkinAnalysisScreen()),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.brown,
                                side: const BorderSide(color: Colors.white),
                              ),
                              child: const Text('Mulai kuesioner kulit'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(context),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  Widget _dialogButton(String text, Color bg, Color fg, VoidCallback onPressed) {
    return Expanded(
      child: SizedBox(
        height: 42,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.softPink,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konfirmasi logout?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Apakah anda yakin ingin keluar dari akun Skin&Shade?',
              style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _dialogButton(
                  'Batal',
                  Colors.white,
                  AppColors.accent,
                  () => Navigator.pop(context),
                ),
                const SizedBox(width: 14),
                _dialogButton(
                  'Ya',
                  AppColors.pink,
                  Colors.white,
                  () {
                    Navigator.pop(context);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const TextField(
        obscureText: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BackTitleRow('Ganti kata sandi', fontSize: 20),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Kata sandi saat ini'),
                    const SizedBox(height: 8),
                    _passwordField(),
                    const SizedBox(height: 16),
                    _label('Kata sandi baru'),
                    const SizedBox(height: 8),
                    _passwordField(),
                    const SizedBox(height: 4),
                    const Text(
                      'Minimal 8 karakter',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                    _label('Konfirmasi sandi baru'),
                    const SizedBox(height: 8),
                    _passwordField(),
                    const SizedBox(height: 30),
                    Center(
                      child: SizedBox(
                        width: 160,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pink,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21)),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacySettingScreen extends StatefulWidget {
  const PrivacySettingScreen({super.key});

  @override
  State<PrivacySettingScreen> createState() => _PrivacySettingScreenState();
}

class _PrivacySettingScreenState extends State<PrivacySettingScreen> {
  bool _izinkanKamera = true;
  bool _izinkanGaleri = true;

  Widget _buildPrivacyCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.softPink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: AppColors.pink,
            inactiveThumbColor: Colors.grey.shade300,
            inactiveTrackColor: Colors.white54,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BackTitleRow('Pengaturan privasi', fontSize: 20),
              const SizedBox(height: 24),
              _buildPrivacyCard(
                title: 'Izinkan kamera',
                subtitle: 'Izinkan kamera untuk menggunakan AR Try-on',
                value: _izinkanKamera,
                onChanged: (val) => setState(() => _izinkanKamera = val),
              ),
              const SizedBox(height: 16),
              _buildPrivacyCard(
                title: 'Izinkan galeri',
                subtitle: 'Izinkan akses galeri untuk mengunggah foto',
                value: _izinkanGaleri,
                onChanged: (val) => setState(() => _izinkanGaleri = val),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationSettingScreen extends StatelessWidget {
  const NotificationSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reminders =
        skinShadeReminderItems.where((item) => item.enabled).toList()
          ..sort((a, b) {
            final byDate = a.date.compareTo(b.date);
            if (byDate != 0) return byDate;
            final menitA = a.time.hour * 60 + a.time.minute;
            final menitB = b.time.hour * 60 + b.time.minute;
            return menitA.compareTo(menitB);
          });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: _BackTitleRow('Notifikasi', gap: 4),
            ),
            Expanded(
              child: reminders.isEmpty
                  ? _emptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: reminders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          _reminderTile(context, reminders[index]),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(context),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: const BoxDecoration(
                color: AppColors.softPink,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_rounded,
                  size: 42, color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada pengingat',
              style: TextStyle(
                color: AppColors.brown,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan jadwal skincare di halaman Reminder. Jadwal aktif akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 18),
            _pinkButton('Buka Reminder',
                () => _goTo(context, const ReminderScreen())),
          ],
        ),
      ),
    );
  }

  Widget _reminderTile(BuildContext context, _ReminderItem item) {
    final dateText =
        '${item.date.day.toString().padLeft(2, '0')}/${item.date.month.toString().padLeft(2, '0')}/${item.date.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softPink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.lightPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active_outlined,
                color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.brown,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$dateText • ${item.time.format(context)}',
                  style: const TextStyle(color: AppColors.brown, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BackTitleRow('Syarat & ketentuan', fontSize: 20),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softPink, width: 2),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Syarat & Ketentuan (Terms & Conditions)',
                      style: TextStyle(
                        color: AppColors.brown,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Terakhir Diperbarui: Oktober 2026\n\nSelamat datang di aplikasi Skin&Shade! Harap membaca Syarat dan Ketentuan berikut dengan cermat sebelum menggunakan layanan kami. Dengan mengakses atau menggunakan aplikasi Skin&Shade, Anda dianggap telah membaca, memahami, dan menyetujui seluruh isi dalam ketentuan ini.\n\n1. Pendahuluan & Ketentuan Umum\n• Cakupan Layanan: Aplikasi Skin&Shade disediakan sebagai platform digital pendukung perawatan kulit (skincare), analisis kondisi kulit (skin analysis), pengingat rutinitas (reminder), serta uji coba produk secara visual (AR try-on).\n• Batas Usia: Layanan ini ditujukan untuk pengguna berusia minimal 13 tahun, atau dapat digunakan oleh anak-anak di bawah usia tersebut dengan pengawasan serta bimbingan dari orang tua atau wali.\n\n2. Penolakan Tanggung Jawab Medis (Medical Disclaimer)\n• Bukan Layanan Medis: Seluruh hasil analisis kulit, saran produk, artikel, tips perawatan, serta fitur rekomendasi yang ada di dalam aplikasi Skin&Shade bersifat informasional dan edukatif semata, bukan pengganti nasihat medis profesional.\n• Bukan Diagnosis Dokter: Hasil analisis dari aplikasi ini tidak dimaksudkan sebagai diagnosis medis resmi atau pengganti konsultasi langsung dengan dokter spesialis kulit (dermatologist).\n\n3. Akun Pengguna & Keamanan\n• Anda bertanggung jawab penuh untuk menjaga kerahasiaan informasi akun, kata sandi (password), serta aktivitas apa pun yang terjadi di dalam akun Skin&Shade Anda.\n• Segera ubah kata sandi melalui menu pengaturan jika Anda mendapati adanya akses yang tidak sah pada akun Anda.\n\n4. Privasi & Penggunaan Kamera/Galeri\n• Aplikasi ini memerlukan izin akses kamera dan galeri perangkat untuk mendukung fitur interaktif seperti AR Try-on dan unggah foto profil/analisis kulit.\n• Kami berkomitmen menjaga kerahasiaan data pribadi Anda sesuai dengan kebijakan privasi yang berlaku di aplikasi ini.\n\n5. Perubahan Ketentuan\nSkin&Shade berhak untuk mengubah, memperbarui, atau merevisi Syarat & Ketentuan ini sewaktu-waktu tanpa pemberitahuan sebelumnya. Penggunaan berkelanjutan Anda terhadap aplikasi ini menandakan persetujuan Anda terhadap perubahan tersebut.',
                      style: TextStyle(
                          color: AppColors.brown, fontSize: 11, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpFlowPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cardLabel;
  final String hint;
  final String buttonText;
  final VoidCallback onSubmit;

  const _OtpFlowPage({
    required this.title,
    required this.subtitle,
    required this.cardLabel,
    required this.hint,
    required this.buttonText,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.accent, size: 26),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                    color: AppColors.subtitle, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: const TextStyle(
                              color: Color(0xFFAAAAAA), fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  width: 180,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: onSubmit,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.pink, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _OtpFlowPage(
      title: 'Forget password',
      subtitle: 'Masukkan email yang terdaftar\nuntuk menerima kode OTP',
      cardLabel: 'Email',
      hint: 'Email/Username',
      buttonText: 'Kirim kode OTP',
      onSubmit: () => _goTo(context, const OtpScreen()),
    );
  }
}

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _OtpFlowPage(
      title: 'Lihat email anda',
      subtitle:
          'Kami mengirimkan kode OTP ke email\nanda, masukkan kode tersebut untuk\nkonfirmasi',
      cardLabel: 'Kode OTP',
      hint: 'Masukkan kode',
      buttonText: 'Lanjutkan',
      onSubmit: () => _goToAndClear(context, const HomeScreen()),
    );
  }
}