import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';

class GuessImageScreen extends StatefulWidget {
  final int levelNumber;

  const GuessImageScreen({super.key, required this.levelNumber});

  @override
  State<GuessImageScreen> createState() => _GuessImageScreenState();
}

class _GuessImageScreenState extends State<GuessImageScreen> {
  final TextEditingController _answerController = TextEditingController();
  int hints = 5;
  int lives = 5;
  bool isCorrect = false;
  String correctAnswer = "TIKUS"; // dummy answer
  List<int> revealedIndexes = []; // untuk track huruf yang sudah dibuka

  void _showHintDialog() {
    if (hints <= 0) return;

    setState(() {
      hints--;
      // Logic untuk reveal random huruf
      List<int> hiddenIndexes = [];
      for (int i = 0; i < correctAnswer.length; i++) {
        if (!revealedIndexes.contains(i)) {
          hiddenIndexes.add(i);
        }
      }
      if (hiddenIndexes.isNotEmpty) {
        hiddenIndexes.shuffle();
        revealedIndexes.add(hiddenIndexes.first);
      }
    });

    String hintText = '';
    for (int i = 0; i < correctAnswer.length; i++) {
      if (revealedIndexes.contains(i)) {
        hintText += correctAnswer[i];
      } else {
        hintText += ' _';
      }
    }

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
          hintText,
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

  void _checkAnswer() {
    if (_answerController.text.toUpperCase() == correctAnswer) {
      setState(() {
        isCorrect = true;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('🎉 Benar!', style: AppText.heading),
          content: Text(
            'Jawaban kamu benar!',
            style: AppText.bodyWhite.copyWith(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: AppText.bodyGold),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        lives--;
      });
      if (lives <= 0) {
        // TODO: Reset ke level 1
        showDialog(
          context: context,
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
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('OK', style: AppText.bodyGold),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Salah! Sisa nyawa: $lives'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Text('$lives', style: AppText.bodyWhite.copyWith(fontSize: 18)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Image.asset('assets/icons/bulb.png', width: 24, height: 24),
                const SizedBox(width: 4),
                Text('$hints', style: AppText.bodyGold.copyWith(fontSize: 18)),
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
                  onPressed: hints > 0 ? _showHintDialog : null,
                  icon: Image.asset(
                    'assets/icons/bulb.png',
                    width: 20,
                    height: 20,
                  ),
                  label: Text(
                    'Hint ($hints)',
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
          // Image placeholder
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold, width: 3),
            ),
            child: Center(
              child: Text(
                '🖼️\nGambar Tebakan',
                style: AppText.bodyGold.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
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
                if (!isCorrect) ...[
                  TextField(
                    controller: _answerController,
                    textAlign: TextAlign.center,
                    style: AppText.bodyWhite.copyWith(fontSize: 20),
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
                      onPressed: _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'CEK',
                        style: AppText.bodyWhite.copyWith(
                          fontSize: 20,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to next level
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'LANJUT',
                        style: AppText.bodyWhite.copyWith(
                          fontSize: 20,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ],
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
