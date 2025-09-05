import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  void wait() async{
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/wrapper');
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    wait();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // same color as native splash
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or splash image (same as native one for smooth effect)
            SizedBox(height: MediaQuery.heightOf(context)*0.06),
            Expanded(
              child: Center(
                child: Image.asset("assets/splashScreen.jpg", width: 290),
              ),
            ),
            // YouTube-style red loading bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _controller.value,
                    backgroundColor: Colors.grey[300],
                    color: Color(0xFF3F51B5),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(4),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}