import 'package:flutter/material.dart';
import 'package:global_net/pages/chat/simpleworld_messenger.dart';
import 'package:google_fonts/google_fonts.dart';

class Chate extends StatefulWidget {
  final String userId;
  const Chate({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<Chate> createState() => _ChateState();
}

class _ChateState extends State<Chate> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          shape: Border(
            bottom: BorderSide(
              color: Theme.of(context).shadowColor,
              width: 1.0,
            ),
          ),
          title: Text(
            'Chat',
            style: GoogleFonts.portLligatSans(
              textStyle: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        body: Messenger(userId: widget.userId),
      ),
    );
  }
}
