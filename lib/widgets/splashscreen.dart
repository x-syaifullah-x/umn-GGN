import 'dart:async';

import 'package:flutter/material.dart';
import 'package:global_net/app.dart';
import 'package:global_net/gen/assets.gen.dart';

class SplashScreen extends StatefulWidget {
  static const route = "/";

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
        const Duration(seconds: 1),
        () => Navigator.of(context).pushReplacementNamed(App.route),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Image.asset(
            Assets.images.splash1.path,
            fit: BoxFit.contain,
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
