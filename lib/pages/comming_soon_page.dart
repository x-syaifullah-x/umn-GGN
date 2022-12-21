// ignore_for_file: unnecessary_this

import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/widgets/bezier_container.dart';

class CommimgSoon extends StatefulWidget {
  final String? currentUserId;

  const CommimgSoon({Key? key, this.currentUserId}) : super(key: key);

  @override
  _CommimgSoonState createState() => _CommimgSoonState();
}

class _CommimgSoonState extends State<CommimgSoon> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Comming Soon',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.red[800],
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.red.shade500, Colors.red.shade900])),
      child: const Text(
        'Back',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    ).onTap(() {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .35),
                    _title(),
                    const SizedBox(
                      height: 50,
                    ),
                    _submitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
