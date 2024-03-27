import 'dart:async';

import 'package:flutter/material.dart';
import 'package:global_net/app.dart';

class SplashScreen extends StatefulWidget {
  static const route = '/';

  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animation.addListener(() => setState(() {}));
    _animationController.forward();
    if (mounted) {
      setState(() {});
      _startTime();
    }
  }

  void _startTime() async => Timer(
        const Duration(seconds: 2),
        () => Navigator.of(context).pushReplacementNamed(App.route),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Image.asset(
            // Assets.images.splash1.path,
            'assets/images/splash2.png',
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
