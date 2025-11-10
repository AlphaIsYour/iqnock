import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  double _bgmVolume = 1;
  double _sfxVolume = 0.6;

  // Initialize audio
  Future<void> init() async {
    await loadVolumes();
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await playBGM();
  }

  // Load volumes from SharedPreferences
  Future<void> loadVolumes() async {
    final prefs = await SharedPreferences.getInstance();
    _bgmVolume = prefs.getDouble('bgmVolume') ?? 1;
    _sfxVolume = prefs.getDouble('sfxVolume') ?? 0.6;
    await _bgmPlayer.setVolume(_bgmVolume);
  }

  // Save volumes to SharedPreferences
  Future<void> saveVolumes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bgmVolume', _bgmVolume);
    await prefs.setDouble('sfxVolume', _sfxVolume);
  }

  // Play BGM
  Future<void> playBGM() async {
    try {
      await _bgmPlayer.play(AssetSource('bgm/bgm.mp3'));
      await _bgmPlayer.setVolume(_bgmVolume);
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  // Stop BGM
  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
  }

  // Pause BGM
  Future<void> pauseBGM() async {
    await _bgmPlayer.pause();
  }

  // Resume BGM
  Future<void> resumeBGM() async {
    await _bgmPlayer.resume();
  }

  // Set BGM Volume
  Future<void> setBGMVolume(double volume) async {
    _bgmVolume = volume;
    await _bgmPlayer.setVolume(volume);
    await saveVolumes();
  }

  // Set SFX Volume
  Future<void> setSFXVolume(double volume) async {
    _sfxVolume = volume;
    await saveVolumes();
  }

  // Get current volumes
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  // Play SFX
  Future<void> playSFX(String fileName) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sfx/$fileName'));
      await _sfxPlayer.setVolume(_sfxVolume);
    } catch (e) {
      print('Error playing SFX: $e');
    }
  }

  // Dispose players
  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
