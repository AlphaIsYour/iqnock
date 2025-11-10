import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';
import '../settings/audio_manager.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/question_model.dart';

class GuessImageScreen extends StatefulWidget {
  final int levelNumber;

  const GuessImageScreen({super.key, required this.levelNumber});

  @override
  State<GuessImageScreen> createState() => _GuessImageScreenState();
}

class _GuessImageScreenState extends State<GuessImageScreen> {
  final ApiService _apiService = ApiService();
  final AudioManager _audioManager = AudioManager();
  final TextEditingController _answerController = TextEditingController();

  QuestionModel? _question;
  int _hints = 0;
  int _hearts = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _currentHint;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getQuestion(widget.levelNumber);

      if (response['success'] == true) {
        final data = response['data'];
        final userStats = data['user_stats'];

        setState(() {
          _question = QuestionModel.fromJson(data);
          _hints = userStats['hints'] ?? 0;
          _hearts = userStats['hearts'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load question';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _useHint() async {
    if (_hints <= 0 || _question == null) {
      // Hint habis - tampilkan maskot hehe.png
      _audioManager.playSFX('klik.mp3');
      _showMascotNotification(
        mascotImage: 'assets/maskot/hehe.png',
        title: 'Hint Habis!',
        message: 'Kamu tidak memiliki hint lagi',
        titleColor: AppColors.red,
      );
      return;
    }

    _audioManager.playSFX('klik.mp3');

    try {
      final response = await _apiService.useHint(_question!.questionId);

      if (response['success'] == true) {
        final hintResponse = HintResponse.fromJson(response);

        setState(() {
          _hints = hintResponse.remainingHints;
          _currentHint = hintResponse.hint;
        });

        _showHintNotification(hintResponse.hint);
      } else {
        _showMascotNotification(
          mascotImage: 'assets/maskot/confused.png',
          title: 'Gagal',
          message: response['message'] ?? 'Failed to get hint',
          titleColor: AppColors.red,
        );
      }
    } catch (e) {
      _showMascotNotification(
        mascotImage: 'assets/maskot/confused.png',
        title: 'Error',
        message: 'Error: $e',
        titleColor: AppColors.red,
      );
    }
  }

  void _showHintNotification(String hint) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Maskot confused.png di dalam card
                Image.asset(
                  'assets/maskot/confused.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/bulb.png', width: 28, height: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Hint',
                      style: AppText.heading.copyWith(
                        fontSize: 24,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  hint,
                  style: AppText.bodyWhite.copyWith(
                    fontSize: 28,
                    letterSpacing: 6,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _audioManager.playSFX('klik.mp3');
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: AppText.bodyGold.copyWith(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMascotNotification({
    required String mascotImage,
    required String title,
    required String message,
    Color titleColor = AppColors.gold,
    VoidCallback? onPressed,
    String buttonText = 'OK',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Maskot di dalam card
                Image.asset(mascotImage, width: 100, height: 100),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: AppText.heading.copyWith(
                    fontSize: 24,
                    color: titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: AppText.bodyWhite.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        onPressed ??
                        () {
                          _audioManager.playSFX('klik.mp3');
                          Navigator.pop(context);
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: AppText.bodyGold.copyWith(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkAnswer() async {
    if (_answerController.text.trim().isEmpty || _question == null) {
      _showMascotNotification(
        mascotImage: 'assets/maskot/confused.png',
        title: 'Peringatan',
        message: 'Jawaban tidak boleh kosong',
        titleColor: AppColors.red,
      );
      return;
    }

    _audioManager.playSFX('klik.mp3');

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _apiService.submitAnswer(
        questionId: _question!.questionId,
        answer: _answerController.text.trim(),
      );

      final answerResponse = AnswerResponse.fromJson(response);

      setState(() {
        _isSubmitting = false;
      });

      if (answerResponse.isCorrect) {
        // Play suara benar LANGSUNG tanpa delay
        _audioManager.playSFX('benar.mp3');
        _showSuccessNotification(answerResponse);
      } else {
        _handleWrongAnswer(answerResponse);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showMascotNotification(
        mascotImage: 'assets/maskot/confused.png',
        title: 'Error',
        message: 'Error: $e',
        titleColor: AppColors.red,
      );
    }
  }

  void _showSuccessNotification(AnswerResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Maskot happy.png di dalam card
                Image.asset('assets/maskot/happy.png', width: 100, height: 100),
                const SizedBox(height: 12),
                Text(
                  'Jawaban kamu benar!',
                  style: AppText.bodyWhite.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.maroon,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${response.pointsEarned} poin',
                    style: AppText.bodyGold.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (response.coins != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Total Koin: ${response.coins}',
                    style: AppText.bodyWhite.copyWith(fontSize: 16),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _audioManager.playSFX('klik.mp3');
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'LANJUT',
                      style: AppText.bodyGold.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleWrongAnswer(AnswerResponse response) {
    // Play suara salah
    _audioManager.playSFX('salah.mp3');

    setState(() {
      _hearts = response.hearts ?? 0;
    });

    if (response.gameOver == true) {
      // Play game over sound
      _audioManager.playSFX('nyawa-habis.mp3');
      _showGameOverNotification();
    } else {
      // Jawaban salah tapi masih punya nyawa - maskot confused.png
      _showMascotNotification(
        mascotImage: 'assets/maskot/confused.png',
        title: 'Salah!',
        message: 'Jawaban kurang tepat\nSisa nyawa: $_hearts ❤️',
        titleColor: AppColors.red,
      );
    }
  }

  void _showGameOverNotification() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.red, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Maskot cary.png di dalam card
                Image.asset('assets/maskot/cry.png', width: 100, height: 100),
                const SizedBox(height: 16),
                Text(
                  '💔 Game Over',
                  style: AppText.heading.copyWith(
                    fontSize: 28,
                    color: AppColors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nyawa habis!\nLevel akan direset ke 1.',
                  style: AppText.bodyWhite.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _audioManager.playSFX('klik.mp3');
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: AppText.bodyWhite.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_question?.imageUrl == null) {
      return Center(
        child: Text(
          '🖼️\nGambar Tebakan',
          style: AppText.bodyGold.copyWith(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_question!.imageUrl.startsWith('data:image')) {
      try {
        final base64String = _question!.imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);

        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 48, color: AppColors.gold),
                  SizedBox(height: 8),
                  Text('Gambar gagal dimuat', style: AppText.bodyGold),
                ],
              ),
            );
          },
        );
      } catch (e) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.gold),
              SizedBox(height: 8),
              Text('Error decode: $e', style: AppText.bodyGold),
            ],
          ),
        );
      }
    }

    return Image.network(
      _question!.imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
            color: AppColors.gold,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: AppColors.gold),
              SizedBox(height: 8),
              Text('Gambar gagal dimuat', style: AppText.bodyGold),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.lightGrey,
        body: Center(child: CircularProgressIndicator(color: AppColors.maroon)),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.lightGrey,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.red),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppText.bodyWhite.copyWith(color: AppColors.maroon),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _audioManager.playSFX('klik.mp3');
                  Navigator.pop(context);
                },
                child: Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () {
            _audioManager.playSFX('klik.mp3');
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Image.asset('assets/logo/iqnock.png', height: 30),
            const SizedBox(width: 8),
            Text(
              "Soal ${widget.levelNumber}",
              style: AppText.heading.copyWith(fontSize: 20),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Image.asset('assets/icons/heart.png', width: 24, height: 24),
                const SizedBox(width: 4),
                Text(
                  '$_hearts',
                  style: AppText.bodyWhite.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Image.asset('assets/icons/bulb.png', width: 24, height: 24),
                const SizedBox(width: 4),
                Text('$_hints', style: AppText.bodyGold.copyWith(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _useHint,
                  icon: Image.asset(
                    'assets/icons/bulb.png',
                    width: 20,
                    height: 20,
                  ),
                  label: Text(
                    'Hint ($_hints)',
                    style: AppText.bodyWhite.copyWith(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _audioManager.playSFX('klik.mp3');
                    // TODO: Share functionality
                  },
                  icon: const Icon(Icons.share, color: AppColors.white),
                  label: Text(
                    'Share',
                    style: AppText.bodyWhite.copyWith(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold, width: 3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: _buildImageWidget(),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _answerController,
                  textAlign: TextAlign.center,
                  style: AppText.bodyWhite.copyWith(fontSize: 20),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Tulis jawabanmu...',
                    hintStyle: AppText.bodyWhite.copyWith(
                      fontSize: 18,
                      color: AppColors.lightGrey,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      disabledBackgroundColor: AppColors.red.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'CEK',
                            style: AppText.bodyWhite.copyWith(
                              fontSize: 20,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
