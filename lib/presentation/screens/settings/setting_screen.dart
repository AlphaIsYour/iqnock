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
            _audioManager.playSFX('klik.mp3');
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
                  _audioManager.playSFX('klik.mp3');
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
                  _audioManager.playSFX('klik.mp3');
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const Color maroon = Color(0xFF6B1B1B);
    const Color gold = Color(0xFFFFD700);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: maroon,
      selectedItemColor: gold,
      unselectedItemColor: Color.fromRGBO(
        255,
        215,
        0,
        0.6,
      ), // gold with opacity
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: gold,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12, color: gold),
      currentIndex: 0, // Set ke 0 sebagai default
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/main_menu.png',
            width: 20,
            height: 20,
            color: gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
            'assets/icons/main_menu.png',
            width: 20,
            height: 20,
            color: gold,
          ),
          label: "Main Menu",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/papan_peringkat.png',
            width: 24,
            height: 24,
            color: gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
            'assets/icons/papan_peringkat.png',
            width: 24,
            height: 24,
            color: gold,
          ),
          label: "Papan Peringkat",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/kirim_soal.png',
            width: 22,
            height: 22,
            color: gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
            'assets/icons/kirim_soal.png',
            width: 22,
            height: 22,
            color: gold,
          ),
          label: "Masukan",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/akun.png',
            width: 26,
            height: 26,
            color: gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
            'assets/icons/akun.png',
            width: 26,
            height: 26,
            color: gold,
          ),
          label: "Akun",
        ),
      ],
      onTap: (index) async {
        _audioManager.playSFX('klik.mp3');

        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/leaderboard');
            break;
          case 2:
            await Navigator.pushNamed(context, '/feedback');
            break;
          case 3:
            await Navigator.pushReplacementNamed(context, '/account');
            break;
        }
      },
    );
  }
}
