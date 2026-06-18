import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/widgets/star_rating.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({
    super.key,
    this.result,
    this.stars = 1,
  });

  final AttemptResultModel? result;
  final int stars;

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _player = AudioPlayer();

  int get _displayStars => widget.result?.starsEarned ?? widget.stars;

  bool get _isPending => widget.result?.isAnalysisPending ?? false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _playCheer();
  }

  Future<void> _playCheer() async {
    // Placeholder: visual feedback only; add asset audio later if needed.
  }

  @override
  void dispose() {
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  String get _message {
    if (_isPending) {
      return 'تم إرسال تسجيلك! 🎙️';
    }

    if (_displayStars >= 5) return 'ممتاز! برافو عليك! 🎉';
    if (_displayStars >= 4) return 'برافو عليك! 🎉';
    if (_displayStars >= 3) return 'شاطر! 👏';
    if (_displayStars >= 2) return 'جيد! استمر 💪';
    return 'حاول ثاني! 💪';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.grass, AppTheme.teal, AppTheme.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isPending ? Icons.hourglass_top : Icons.emoji_events,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                _message,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              if (_isPending) ...[
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'جاري تحليل نطقك بواسطة الذكاء الاصطناعي. ستظهر النجوم في صفحة التقدم قريباً.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 24),
                StarRating(stars: _displayStars),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.purpleDeep,
                ),
                onPressed: () => context.go('/home'),
                child: const Text('متابعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
