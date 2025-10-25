import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';
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
    if (_hints <= 0 || _question == null) return;

    try {
      final response = await _apiService.useHint(_question!.questionId);

      if (response['success'] == true) {
        final hintResponse = HintResponse.fromJson(response);

        setState(() {
          _hints = hintResponse.remainingHints;
          _currentHint = hintResponse.hint;
        });

        _showHintDialog(hintResponse.hint);
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to get hint');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showHintDialog(String hint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Image.asset('assets/icons/bulb.png', width: 32, height: 32),
            const SizedBox(width: 8),
            Text('Hint', style: AppText.heading.copyWith(fontSize: 22)),
          ],
        ),
        content: Text(
          hint,
          style: AppText.bodyWhite.copyWith(fontSize: 24, letterSpacing: 4),
          textAlign: TextAlign.center,
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

  Future<void> _checkAnswer() async {
    if (_answerController.text.trim().isEmpty || _question == null) {
      _showErrorSnackBar('Jawaban tidak boleh kosong');
      return;
    }

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
        _showSuccessDialog(answerResponse);
      } else {
        _handleWrongAnswer(answerResponse);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showSuccessDialog(AnswerResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('🎉 Benar!', style: AppText.heading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Jawaban kamu benar!',
              style: AppText.bodyWhite.copyWith(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              '+${response.pointsEarned} poin',
              style: AppText.bodyGold.copyWith(fontSize: 20),
            ),
            if (response.coins != null)
              Text(
                'Total Koin: ${response.coins}',
                style: AppText.bodyWhite.copyWith(fontSize: 16),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Back to game screen & refresh
            },
            child: Text('LANJUT', style: AppText.bodyGold),
          ),
        ],
      ),
    );
  }

  void _handleWrongAnswer(AnswerResponse response) {
    setState(() {
      _hearts = response.hearts ?? 0;
    });

    if (response.gameOver == true) {
      _showGameOverDialog();
    } else {
      _showErrorSnackBar('Salah! Sisa nyawa: $_hearts');
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('💔 Game Over', style: AppText.heading),
        content: Text(
          'Nyawa habis! Level akan direset ke 1.',
          style: AppText.bodyWhite.copyWith(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Back to game screen
            },
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

    // Check if it's base64 data
    if (_question!.imageUrl.startsWith('data:image')) {
      try {
        // Extract base64 string after comma
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

    // Fallback to network image
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
                onPressed: () => Navigator.pop(context),
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
          onPressed: () => Navigator.pop(context),
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
          // Hint & Share buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _hints > 0 ? _useHint : null,
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
                    disabledBackgroundColor: AppColors.maroon.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
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
          // Image dari API
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
          // Input & Button area
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
