import 'package:flutter/material.dart';
import 'package:global_net/pages/chat/hire_chat_list.dart';
import 'package:google_fonts/google_fonts.dart';

class WeAreHiring extends StatefulWidget {
  final String currentUserId;

  const WeAreHiring({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  WeAreHiringState createState() => WeAreHiringState();
}

class WeAreHiringState extends State<WeAreHiring> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      duration: const Duration(milliseconds: 300),
      data: Theme.of(context),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          toolbarHeight: 50,
          shape: Border(
            bottom: BorderSide(
              color: Theme.of(context).shadowColor,
              width: 1.0,
            ),
          ),
          title: Text(
            'Hire',
            style: GoogleFonts.portLligatSans(
              textStyle: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          automaticallyImplyLeading: true,
        ),
        body: HireChatList(
          userId: widget.currentUserId,
        ),
      ),
    );
  }
}
