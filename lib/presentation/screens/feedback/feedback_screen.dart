import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';
import '../../../data/services/api_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstWordController = TextEditingController();
  final TextEditingController _secondWordController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSubmitting = false;
  String _selectedType = 'kirim_soal';
  late AnimationController _animationController;
  Animation<double>? _fadeAnimation;

  final Map<String, Map<String, dynamic>> _feedbackTypes = {
    'kirim_soal': {
      'label': 'Kirim Soal',
      'icon': Icons.lightbulb_outline,
      'color': Colors.amber,
    },
    'lapor_bug': {
      'label': 'Lapor Bug',
      'icon': Icons.bug_report_outlined,
      'color': Colors.red,
    },
    'kirim_masukan': {
      'label': 'Kirim Masukan',
      'icon': Icons.chat_bubble_outline,
      'color': Colors.blue,
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _firstWordController.dispose();
    _secondWordController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _getHeaderText() {
    switch (_selectedType) {
      case 'kirim_soal':
        return 'Ayo kirimkan ide soal buatanmu!';
      case 'lapor_bug':
        return 'Laporkan bug yang kamu temukan!';
      case 'kirim_masukan':
        return 'Berikan masukan untuk kami!';
      default:
        return 'Ayo kirimkan ide soal buatanmu!';
    }
  }

  Future<void> _submitQuestion() async {
    if (_usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar('Username, Email, dan Deskripsi harus diisi');
      return;
    }

    if (_selectedType == 'kirim_soal' &&
        (_firstWordController.text.trim().isEmpty ||
            _secondWordController.text.trim().isEmpty)) {
      _showErrorSnackBar('Kata Pertama dan Kata Kedua harus diisi');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _apiService.submitQuestion(
        type: _selectedType,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        firstWord: _firstWordController.text.trim(),
        secondWord: _secondWordController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      setState(() {
        _isSubmitting = false;
      });

      if (response['success'] == true) {
        _showSuccessDialog();
        _clearForm();
      } else {
        _showErrorSnackBar(response['message'] ?? 'Gagal mengirim');
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  void _clearForm() {
    _usernameController.clear();
    _emailController.clear();
    _firstWordController.clear();
    _secondWordController.clear();
    _descriptionController.clear();
  }

  void _showSuccessDialog() {
    String message = '';
    IconData icon = Icons.check_circle;

    switch (_selectedType) {
      case 'kirim_soal':
        message =
            'Ide soal kamu berhasil dikirim!\nTerima kasih atas kontribusinya 😊';
        icon = Icons.lightbulb;
        break;
      case 'lapor_bug':
        message =
            'Laporan bug berhasil dikirim!\nTerima kasih telah membantu kami 😊';
        icon = Icons.bug_report;
        break;
      case 'kirim_masukan':
        message =
            'Masukan kamu berhasil dikirim!\nTerima kasih atas sarannya 😊';
        icon = Icons.chat_bubble;
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.green, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Berhasil!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroon,
                  fontFamily: 'Baloo-Regular',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.black,
                  fontFamily: 'Baloo-Regular',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.maroon,
                      fontFamily: 'Baloo-Regular',
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 254, 255),
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.maroon, AppColors.maroon.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Masukan',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Baloo-Regular',
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with Icon
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.maroon.withOpacity(0.1),
                      AppColors.gold.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.maroon.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.maroon,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _feedbackTypes[_selectedType]!['icon'],
                        color: AppColors.gold,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _getHeaderText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.maroon,
                          fontFamily: 'Baloo-Regular',
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Type Selector - Card Style
              const Text(
                'Tipe Masukan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroon,
                  fontFamily: 'Baloo-Regular',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.maroon.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: _feedbackTypes.entries.map((entry) {
                    final isSelected = _selectedType == entry.key;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedType = entry.key;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.maroon.withOpacity(0.05)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.maroon
                                    : AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                entry.value['icon'],
                                color: isSelected
                                    ? AppColors.gold
                                    : AppColors.maroon.withOpacity(0.5),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                entry.value['label'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.maroon
                                      : AppColors.black.withOpacity(0.7),
                                  fontFamily: 'Baloo-Regular',
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.gold,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              _buildModernInputField(
                label: 'Username',
                controller: _usernameController,
                hintText: 'Masukkan username kamu',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 18),

              _buildModernInputField(
                label: 'Email',
                controller: _emailController,
                hintText: 'user@yourdomain.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),

              // Conditional Fields untuk Kirim Soal
              if (_selectedType == 'kirim_soal') ...[
                _buildModernInputField(
                  label: 'Kata Pertama',
                  controller: _firstWordController,
                  hintText: 'Masukkan kata pertama',
                  icon: Icons.looks_one_outlined,
                ),
                const SizedBox(height: 18),
                _buildModernInputField(
                  label: 'Kata Kedua',
                  controller: _secondWordController,
                  hintText: 'Masukkan kata kedua',
                  icon: Icons.looks_two_outlined,
                ),
                const SizedBox(height: 18),
              ],

              const Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroon,
                  fontFamily: 'Baloo-Regular',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.maroon.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: _selectedType == 'kirim_soal'
                        ? 'Jelaskan ide soal kamu dengan detail...'
                        : _selectedType == 'lapor_bug'
                        ? 'Jelaskan bug yang kamu temukan dengan detail...'
                        : 'Tuliskan masukan kamu dengan detail...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontFamily: 'Baloo-Regular',
                    ),
                    filled: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(18),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontFamily: 'Baloo-Regular',
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button - Modern
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gold, AppColors.gold.withOpacity(0.9)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.maroon,
                            strokeWidth: 3,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.send_rounded,
                              color: AppColors.maroon,
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Kirim Sekarang',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.maroon,
                                fontFamily: 'Baloo-Regular',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildModernInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.maroon,
            fontFamily: 'Baloo-Regular',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.maroon.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontFamily: 'Baloo-Regular',
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.maroon.withOpacity(0.6),
                size: 22,
              ),
              filled: false,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.maroon.withOpacity(0.3),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontFamily: 'Baloo-Regular',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.maroon,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.gold.withOpacity(0.6),
      currentIndex: 2,
      selectedLabelStyle: AppText.bodyGold.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: AppText.bodyGold.copyWith(fontSize: 12),
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/main_menu.png',
            width: 20,
            height: 20,
            color: AppColors.gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
            'assets/icons/main_menu.png',
            width: 20,
            height: 20,
            color: AppColors.gold,
          ),
          label: "Main Menu",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/papan_peringkat.png',
            width: 24,
            height: 24,
            color: AppColors.gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
            'assets/icons/papan_peringkat.png',
            width: 24,
            height: 24,
            color: AppColors.gold,
          ),
          label: "Papan Peringkat",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/kirim_soal.png',
            width: 22,
            height: 22,
            color: AppColors.gold,
          ),
          label: "Masukan",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/akun.png',
            width: 26,
            height: 26,
            color: AppColors.gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
            'assets/icons/akun.png',
            width: 26,
            height: 26,
            color: AppColors.gold,
          ),
          label: "Akun",
        ),
      ],
      onTap: (index) async {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/leaderboard');
            break;
          case 2:
            break;
          case 3:
            await Navigator.pushReplacementNamed(context, '/account');
            break;
        }
      },
    );
  }
}
