import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/bezier_container.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

const int creditForNewUser = 500;

class AddCreditToAccount extends StatelessWidget {
  final String userId;

  const AddCreditToAccount({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: usersCollection.doc(userId).update({
        "credit_points": creditForNewUser,
      }).then((value) => usersCollection.doc(userId).get()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return circularProgress();
        }

        final height = MediaQuery.of(context).size.height;
        String username = snapshot.data?['username'];
        return Scaffold(
          body: SizedBox(
            height: height,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -height * .15,
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
                        SizedBox(height: height * .25),
                        _title(context, username),
                        Text(
                          'You have received $creditForNewUser credit points \n  as a welcome gift',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          child: Image.asset(
                            'assets/images/getcredit.png',
                            width: context.width(),
                            height: context.height() * 0.5,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _submitButton(context: context, userId: userId),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _title(BuildContext context, String? username) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Welcome $username!',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.red[800],
        ),
      ),
    );
  }

  Widget _submitButton({
    required BuildContext context,
    required String userId,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.red.shade500, Colors.red.shade900],
        ),
      ),
      child: const Text(
        'Continue',
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    ).onTap(() {
      _submit(context: context, userId: userId);
    });
  }

  void _submit({
    required BuildContext context,
    required String userId,
  }) {
    Timer(const Duration(seconds: 0), () {
      Navigator.pop(context);
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => Home(
            userId: userId,
          ),
        ),
      );
    });
  }
}
