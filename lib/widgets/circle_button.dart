import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final Function onPressed;

  const CircleButton({
    Key? key,
    required this.icon,
    required this.iconSize,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 40,
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: iconSize,
        onPressed: onPressed as void Function()?,
      ),
    );
  }
}
