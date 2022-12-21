import 'dart:math';

import 'package:flutter/material.dart';

import 'custom_clipper.dart';

class BezierContainernew extends StatelessWidget {
  const BezierContainernew({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Transform.rotate(
      angle: pi / 1.3,
      child: ClipPath(
        clipper: ClipPainter(),
        child: Container(
          height: MediaQuery.of(context).size.height * .5,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.red.shade500, Colors.red.shade900])),
        ),
      ),
    ));
  }
}
