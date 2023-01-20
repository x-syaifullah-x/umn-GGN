import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/user_to_follow.dart';
import 'package:global_net/widgets/bezier_container.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class AddCreditToAccount extends StatefulWidget {
  final String? userId;

  const AddCreditToAccount({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  AddCreditToAccountState createState() => AddCreditToAccountState();
}

class AddCreditToAccountState extends State<AddCreditToAccount> {
  final formkey = GlobalKey<FormState>();
  String? username;
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getcurrentusername();
    addcredit();
  }

  getcurrentusername() async {
    usersRef.doc(widget.userId).get().then(
          (value) => setState(() {
            username = value["username"];
          }),
        );
  }

  addcredit() async {
    usersRef.doc(widget.userId).update({
      "credit_points": 500,
    });
  }

  submit() {
    Timer(const Duration(seconds: 0), () {
      Navigator.pop(context);
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => Home(
            userId: widget.userId,
          ),
        ),
      );
    });
  }

  Widget _title() {
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
        'Continue',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    ).onTap(() {
      submit();
    });
  }

  // Widget _emailPasswordWidget() {
  //   return Column(
  //     children: <Widget>[
  //       Form(
  //         autovalidateMode: AutovalidateMode.always,
  //         key: _formkey,
  //         child: TextFormField(
  //           controller: nameController,
  //           validator: (val) {
  //             if (val!.trim().length < 3 || val.isEmpty) {
  //               return "Username too short";
  //             } else if (val.trim().length > 12) {
  //               return "Username too long";
  //             } else {
  //               return null;
  //             }
  //           },
  //           onSaved: (val) => username = val,
  //           decoration: InputDecoration(
  //               border: InputBorder.none,
  //               fillColor: Theme.of(context).inputDecorationTheme.fillColor,
  //               filled: true,
  //               labelText: "Username",
  //               labelStyle: const TextStyle(fontSize: 15.0),
  //               hintText: "Must be at least 3 characters"),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext parentContext) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SizedBox(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .25),
                  _title(),
                  Text(
                    'You have received 100 credit points \n  as a welcome gift',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    child: Image.asset('assets/images/getcredit.png',
                        width: context.width(),
                        height: context.height() * 0.5,
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),
                  _submitButton(),
                ],
              ),
            ),
          ),
          isLoading == true ? Center(child: circularProgress()) : Container(),
        ],
      ),
    ));
  }
}
