import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';
import '../../../data/services/api_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstWordController = TextEditingController();
  final TextEditingController _secondWordController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSubmitting = false;
  String _selectedType = 'kirim_soal';

  final Map<String, String> _feedbackTypes = {
    'kirim_soal': 'Kirim Soal',
    'lapor_bug': 'Lapor Bug',
    'kirim_masukan': 'Kirim Masukan',
  };

  @override
  void dispose() {
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
    switch (_selectedType) {
      case 'kirim_soal':
        message =
            'Ide soal kamu berhasil dikirim!\nTerima kasih atas kontribusinya 😊';
        break;
      case 'lapor_bug':
        message =
            'Laporan bug berhasil dikirim!\nTerima kasih telah membantu kami 😊';
        break;
      case 'kirim_masukan':
        message =
            'Masukan kamu berhasil dikirim!\nTerima kasih atas sarannya 😊';
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Berhasil!', style: TextStyle(color: AppColors.maroon)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: AppColors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: const Text(
          'Masukan',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Baloo-Regular',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getHeaderText(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontFamily: 'Baloo-Regular',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Dropdown Tipe Masukan
            const Text(
              'Tipe Masukan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon,
                fontFamily: 'Baloo-Regular',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  fontFamily: 'Baloo-Regular',
                ),
                dropdownColor: Colors.white,
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.maroon,
                ),
                items: _feedbackTypes.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            _buildInputField(
              label: 'Username',
              controller: _usernameController,
              hintText: 'user001',
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'Email',
              controller: _emailController,
              hintText: 'user@yourdomain.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Conditional Fields untuk Kirim Soal
            if (_selectedType == 'kirim_soal') ...[
              _buildInputField(
                label: 'Kata Pertama',
                controller: _firstWordController,
                hintText: 'Lorem',
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: 'Kata Kedua',
                controller: _secondWordController,
                hintText: 'Ipsum',
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon,
                fontFamily: 'Baloo-Regular',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: _selectedType == 'kirim_soal'
                      ? 'Jelaskan ide soal kamu...'
                      : _selectedType == 'lapor_bug'
                      ? 'Jelaskan bug yang kamu temukan...'
                      : 'Tuliskan masukan kamu...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontFamily: 'Baloo-Regular',
                  ),
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: 'Baloo-Regular',
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  disabledBackgroundColor: AppColors.gold.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.gold.withOpacity(0.4),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.maroon,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Kirim',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.maroon,
                          fontFamily: 'Baloo-Regular',
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
            await Navigator.pushNamed(context, '/leaderboard');
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.maroon,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
              fontFamily: 'Baloo-Regular',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
              filled: false,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
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
}
