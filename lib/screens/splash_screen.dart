import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _blobAnimation;
  late Animation<double> _fadeTextAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Animation for the blob expansion
    _blobAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Animation for the welcome text fade in
    _fadeTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start the animation
    _animationController.forward();

    // Check onboarding status after animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          _checkAppStatus();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAppStatus() async {
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // Animated blob background
              _buildAnimatedBackground(),

              // House with magnifying glass
              Center(
                child: Image.asset(
                  'assets/logo_griyako.png',
                  width: 300,
                  height: 300,
                ),
              ),

              // Welcome text
              Positioned(
                bottom: 200,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _fadeTextAnimation.value,
                  child: const Center(
                    child: Text(
                      'WELLCOME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    // Interpolate between initial blob and full screen
    return ClipPath(
      clipper: BlobClipper(_blobAnimation.value),
      child: Container(
        color: AppColors.primary,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

class BlobClipper extends CustomClipper<Path> {
  final double animationValue;

  BlobClipper(this.animationValue);

  @override
  Path getClip(Size size) {
    // Start with a blob path
    Path initialPath = Path();

    if (animationValue < 1.0) {
      // Initial blob shape
      initialPath.moveTo(0, size.height * 0.4);
      initialPath.quadraticBezierTo(size.width * 0.1, size.height * 0.2,
          size.width * 0.3, size.height * 0.2);
      initialPath.quadraticBezierTo(size.width * 0.5, size.height * 0.1,
          size.width * 0.7, size.height * 0.2);
      initialPath.quadraticBezierTo(
          size.width * 0.9, size.height * 0.3, size.width, size.height * 0.4);
      initialPath.lineTo(size.width, 0);
      initialPath.lineTo(0, 0);
      initialPath.close();
    }

    // Final full screen rectangle
    Path finalPath = Path();
    finalPath.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Interpolate between the two paths based on animation value
    if (animationValue >= 1.0) {
      return finalPath;
    } else {
      // Create a path that grows from the blob to full screen
      double top = lerpDouble(size.height * 0.4, 0, animationValue);
      double bottom =
          lerpDouble(size.height * 0.4, size.height, animationValue);

      Path interpolatedPath = Path();
      interpolatedPath.moveTo(0, top);
      interpolatedPath.quadraticBezierTo(
          size.width * 0.1,
          lerpDouble(size.height * 0.2, 0, animationValue),
          size.width * 0.3,
          lerpDouble(size.height * 0.2, 0, animationValue));
      interpolatedPath.quadraticBezierTo(
          size.width * 0.5,
          lerpDouble(size.height * 0.1, 0, animationValue),
          size.width * 0.7,
          lerpDouble(size.height * 0.2, 0, animationValue));
      interpolatedPath.quadraticBezierTo(size.width * 0.9,
          lerpDouble(size.height * 0.3, 0, animationValue), size.width, top);
      interpolatedPath.lineTo(size.width, bottom);
      interpolatedPath.lineTo(0, bottom);
      interpolatedPath.close();

      return interpolatedPath;
    }
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }

  double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
