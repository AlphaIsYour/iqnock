import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedback',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: const FeedbackPage(),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _namaController = TextEditingController(
    text: 'user001',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'user@yourdomain.com',
  );
  final TextEditingController _kata1Controller = TextEditingController();
  final TextEditingController _kata2Controller = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController(
    text: 'Berikan Deskripsi Soalmu.',
  );

  int _selectedIndex = 3;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _kata1Controller.dispose();
    _kata2Controller.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _submitFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback berhasil dikirim! (Tampilan Statis)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC5C5D8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7D2424),
        elevation: 0,
        toolbarHeight: 70,
        title: const Text(
          'Feedback',
          style: TextStyle(
            color: Color(0xFFF4D03F),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF5C1A1A),
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Greeting
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Text(
                'Ayo kirimkan feedback untuk kami!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Form Nama
            _buildFormRow('Nama', _namaController, 'Masukkan nama'),
            const SizedBox(height: 14),

            // Form Email
            _buildFormRow('Email', _emailController, 'Masukkan email'),
            const SizedBox(height: 14),

            // Form Kata Pertama
            _buildFormRow(
              'Kata Pertama',
              _kata1Controller,
              'Bug/Saran/Lainnya',
            ),
            const SizedBox(height: 14),

            // Form Kata Kedua
            _buildFormRow('Kata Kedua', _kata2Controller, 'Rating 1-5'),
            const SizedBox(height: 14),

            // Form Deskripsi (menyatu dengan auto-expand)
            _buildDescriptionField(),
            const SizedBox(height: 24),

            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4D03F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFFF4D03F).withOpacity(0.4),
                ),
                child: const Text(
                  'Kirim',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6B1F1F), Color(0xFF5C1A1A)],
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFFF4D03F),
          unselectedItemColor: const Color(0xFFF4D03F),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 26),
              label: 'Main Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star, size: 26),
              label: 'Papan Peringkat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.send, size: 26),
              label: 'Kirim Soal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 26),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormRow(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Container(
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
      child: Row(
        children: [
          // Label dengan background merah maroon dan text putih
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF7D2424),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Input field dengan background putih dan text hitam
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                filled: false, // Tambahkan ini
                border: InputBorder.none,
                focusedBorder: InputBorder.none, // Tambahkan ini
                enabledBorder: InputBorder.none, // Tambahkan ini
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF7D2424),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: const Center(
                child: Text(
                  'Deskripsi\nSoal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _deskripsiController,
                maxLines: null,
                minLines: 6,
                decoration: InputDecoration(
                  hintText: 'Tuliskan feedback Anda di sini...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  filled: false,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
                style: const TextStyle(fontSize: 13, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
