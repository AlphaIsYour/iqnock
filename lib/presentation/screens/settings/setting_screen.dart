import 'package:flutter/material.dart';
import './audio_manager.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final AudioManager _audioManager = AudioManager();
  double suaraVolume = 0.6;
  double bgmVolume = 0.6;

  @override
  void initState() {
    super.initState();
    _loadVolumes();
  }

  void _loadVolumes() {
    setState(() {
      suaraVolume = _audioManager.sfxVolume;
      bgmVolume = _audioManager.bgmVolume;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3D3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B1B1B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () {
            _audioManager.playSFX('klik.mp3'); // TAMBAHKAN SFX
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: const [
            Icon(Icons.settings, color: Colors.yellow, size: 32),
            SizedBox(width: 12),
            Text(
              'Pengaturan',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Slider Suara (SFX)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFB71C1C),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  const Icon(Icons.volume_up, color: Colors.yellow, size: 36),
                  const SizedBox(width: 16),
                  const Text(
                    'Suara',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.yellow,
                        inactiveTrackColor: Colors.white,
                        thumbColor: Colors.yellow,
                        overlayColor: Colors.yellow.withOpacity(0.3),
                        trackHeight: 8,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 12,
                        ),
                      ),
                      child: Slider(
                        value: suaraVolume,
                        onChanged: (value) {
                          setState(() {
                            suaraVolume = value;
                          });
                          _audioManager.setSFXVolume(value);
                        },
                        onChangeEnd: (value) {
                          // Play SFX saat selesai drag slider
                          _audioManager.playSFX('klik.mp3');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Slider BGM
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFB71C1C),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.yellow, size: 36),
                  const SizedBox(width: 16),
                  const Text(
                    'BGM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.yellow,
                        inactiveTrackColor: Colors.white,
                        thumbColor: Colors.yellow,
                        overlayColor: Colors.yellow.withOpacity(0.3),
                        trackHeight: 8,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 12,
                        ),
                      ),
                      child: Slider(
                        value: bgmVolume,
                        onChanged: (value) {
                          setState(() {
                            bgmVolume = value;
                          });
                          _audioManager.setBGMVolume(value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Kembali
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  _audioManager.playSFX('klik.mp3'); // TAMBAHKAN SFX
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB8860B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'Kembali',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Simpan Pengaturan
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  _audioManager.playSFX('klik.mp3'); // TAMBAHKAN SFX
                  // Volumes already saved in real-time
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengaturan disimpan!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'Simpan Pengaturan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Color(0xFF6B1B1B)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Main Menu', () {
                  _audioManager.playSFX('klik.mp3'); // TAMBAHKAN SFX
                  Navigator.pushReplacementNamed(context, '/home');
                }),
                _buildNavItem(Icons.star, 'Papan Peringkat', () {
                  _audioManager.playSFX('klik.mp3'); // TAMBAHKAN SFX
                  Navigator.pushReplacementNamed(context, '/leaderboard');
                }),
                _buildNavItem(Icons.send, 'Kirim Soal', () {
                  _audioManager.playSFX('klik.mp3'); // TAMBAHKAN SFX
                  Navigator.pushReplacementNamed(context, '/feedback');
                }),
                _buildNavItem(Icons.person, 'Akun', () {
                  _audioManager.playSFX('klik.mp3'); // TAMBAHKAN SFX
                  Navigator.pushReplacementNamed(context, '/account');
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.yellow, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
