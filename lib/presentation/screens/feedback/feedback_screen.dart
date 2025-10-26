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
  final TextEditingController _messageController = TextEditingController();

  String _selectedType = 'bug';
  bool _isSubmitting = false;

  final Map<String, String> _feedbackTypes = {
    'bug': '🐛 Lapor Bug',
    'suggestion': '💡 Saran',
    'question_idea': '❓ Ide Soal',
  };

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_messageController.text.trim().isEmpty) {
      _showErrorSnackBar('Pesan tidak boleh kosong');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _apiService.submitFeedback(
        type: _selectedType,
        content: _messageController.text.trim(),
      );

      setState(() {
        _isSubmitting = false;
      });

      if (response['success'] == true) {
        _showSuccessDialog();
        _messageController.clear();
        setState(() {
          _selectedType = 'bug';
        });
      } else {
        _showErrorSnackBar(response['message'] ?? 'Gagal mengirim feedback');
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Berhasil!', style: AppText.heading.copyWith(fontSize: 22)),
          ],
        ),
        content: Text(
          'Feedback kamu berhasil dikirim!\nTerima kasih atas masukannya 😊',
          style: AppText.bodyWhite.copyWith(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: AppText.bodyGold),
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
        title: Text('Feedback', style: AppText.heading),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Ayo kirimkan feedback untuk kami!',
                style: AppText.bodyWhite.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Tipe Feedback
            Text(
              'Tipe Feedback',
              style: AppText.bodyWhite.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon,
              ),
            ),
            const SizedBox(height: 12),

            // Radio buttons untuk tipe
            ..._feedbackTypes.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _selectedType == entry.key
                      ? AppColors.maroon.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedType == entry.key
                        ? AppColors.maroon
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: RadioListTile<String>(
                  value: entry.key,
                  groupValue: _selectedType,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                  title: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _selectedType == entry.key
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _selectedType == entry.key
                          ? AppColors.maroon
                          : Colors.black87,
                    ),
                  ),
                  activeColor: AppColors.maroon,
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Pesan/Deskripsi
            Text(
              'Pesan',
              style: AppText.bodyWhite.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon,
              ),
            ),
            const SizedBox(height: 12),

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
                controller: _messageController,
                maxLines: 8,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: _getHintText(),
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  counterStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
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
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.maroon,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Kirim',
                        style: AppText.bodyWhite.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.maroon,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.maroon,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.gold,
        selectedLabelStyle: AppText.bodyGold.copyWith(fontSize: 12),
        unselectedLabelStyle: AppText.bodyGold.copyWith(fontSize: 12),
        currentIndex: 2,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/main_menu.png',
              width: 20,
              height: 20,
            ),
            label: "Main Menu",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/papan_peringkat.png',
              width: 24,
              height: 24,
            ),
            label: "Papan Peringkat",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/kirim_soal.png',
              width: 22,
              height: 22,
            ),
            label: "Masukan",
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/akun.png', width: 26, height: 26),
            label: "Akun",
          ),
        ],
        onTap: (index) {
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
              Navigator.pushReplacementNamed(context, '/account');
              break;
          }
        },
      ),
    );
  }

  String _getHintText() {
    switch (_selectedType) {
      case 'bug':
        return 'Ceritakan bug yang kamu temukan dengan detail...\nContoh: "Gambar tidak muncul di level 5"';
      case 'suggestion':
        return 'Berikan saran untuk pengembangan aplikasi...\nContoh: "Tambahkan mode dark theme"';
      case 'question_idea':
        return 'Kirimkan ide soal baru...\nContoh: "Tebak logo perusahaan teknologi"';
      default:
        return 'Tuliskan feedback Anda di sini...';
    }
  }
}
