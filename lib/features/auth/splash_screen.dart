import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'auth_provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  bool _isControllerInitialized = false;
  bool _isVideoFinished = false;
  bool _isAuthChecked = false;
  bool _loggedIn = false;
  bool _isNavigated = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _checkAuth();
    
    // Safety fallback: if video player fails to load or notify end,
    // force navigation after 8 seconds (if auth has already finished checking).
    _fallbackTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && !_isNavigated) {
        debugPrint("Splash screen: Fallback timeout reached. Forcing transition.");
        _isVideoFinished = true;
        if (_isAuthChecked) {
          _navigateToNext();
        }
      }
    });
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset('assets/images/splash_screen.mp4');
    
    try {
      await _videoController.initialize();
      if (!mounted) return;

      _videoController.setVolume(0.0); // Mute sound for splash screen
      _videoController.setLooping(false);
      
      _videoController.addListener(() {
        if (!mounted) return;
        final position = _videoController.value.position;
        final duration = _videoController.value.duration;
        
        // When video reaches completion
        if (position >= duration && position > Duration.zero) {
          _onVideoFinished();
        }
      });

      setState(() {
        _isControllerInitialized = true;
      });

      // Start playing the video
      await _videoController.play();
    } catch (e) {
      debugPrint("Error initializing video splash: $e");
      // If video player fails, mark video as finished to bypass it
      _onVideoFinished();
    }
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();
    final hasToken = await ApiService().getToken() != null;
    
    if (hasToken) {
      try {
        _loggedIn = await authProvider.fetchProfile();
      } catch (e) {
        debugPrint("Error checking auth profile: $e");
        _loggedIn = false;
      }
    } else {
      _loggedIn = false;
    }

    if (!mounted) return;

    setState(() {
      _isAuthChecked = true;
    });

    // If video is already finished or failed, navigate immediately
    if (_isVideoFinished) {
      _navigateToNext();
    }
  }

  void _onVideoFinished() {
    if (_isVideoFinished) return;
    
    setState(() {
      _isVideoFinished = true;
    });

    // If auth check is also done, navigate to the next screen
    if (_isAuthChecked) {
      _navigateToNext();
    }
  }

  Future<void> _navigateToNext() async {
    if (_isNavigated) return;
    _isNavigated = true;

    _fallbackTimer?.cancel();

    // Pause video player
    if (_isControllerInitialized) {
      try {
        await _videoController.pause();
      } catch (_) {}
    }

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    if (_loggedIn) {
      if (authProvider.isAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.userDashboard);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Match the solid black background of the video
      body: Center(
        child: _isControllerInitialized
            ? AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              )
            : const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
      ),
    );
  }
}
