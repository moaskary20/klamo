import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset('assets/splash.mp4');
    _videoController = controller;

    try {
      await controller.initialize();
      controller.setLooping(false);
      controller.addListener(_handleVideoProgress);

      if (!mounted) return;

      setState(() => _videoReady = true);
      await controller.play();

      final duration = controller.value.duration;
      if (duration.inMilliseconds <= 0) {
        _navigateNext();
        return;
      }

      Future<void>.delayed(duration + const Duration(milliseconds: 400), () {
        if (mounted && !_hasNavigated) {
          _navigateNext();
        }
      });
    } catch (_) {
      _navigateNext();
    }
  }

  void _handleVideoProgress() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized || _hasNavigated) {
      return;
    }

    final duration = controller.value.duration;
    final position = controller.value.position;

    if (duration.inMilliseconds <= 0) return;

    if (position >= duration - const Duration(milliseconds: 250)) {
      _navigateNext();
    }
  }

  void _navigateNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    _videoController?.removeListener(_handleVideoProgress);
    _videoController?.pause();

    final appState = context.read<AppState>();
    final String destination;

    if (appState.token == null) {
      destination = '/auth';
    } else if (appState.isSpecialist) {
      destination = '/specialist';
    } else if (appState.selectedChild != null) {
      destination = '/home';
    } else {
      destination = '/auth';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(destination);
    });
  }

  @override
  void dispose() {
    _videoController?.removeListener(_handleVideoProgress);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!_videoReady || _videoController == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final videoSize = _videoController!.value.size;
            final videoAspect = videoSize.width / videoSize.height;
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;

            double width = maxWidth;
            double height = width / videoAspect;

            if (height > maxHeight) {
              height = maxHeight;
              width = height * videoAspect;
            }

            return Center(
              child: SizedBox(
                width: width,
                height: height,
                child: VideoPlayer(_videoController!),
              ),
            );
          },
        ),
      ),
    );
  }
}
