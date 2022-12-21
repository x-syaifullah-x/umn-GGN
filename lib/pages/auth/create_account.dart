import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simpleworld/pages/auth/add_credit_to_account.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/pages/user_to_follow.dart';
import 'package:simpleworld/widgets/bezier_container.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class CreateAccount extends StatefulWidget {
  final String? userId;

  const CreateAccount({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formkey = GlobalKey<FormState>();
  String? username;
  int credits = 0;
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getcredit();
  }

  getcredit() async {
    usersRef.doc(globalID).get().then(
          (value) => setState(() {
            credits = value["credit_points"];
          }),
        );
  }

  submit() {
    final form = _formkey.currentState!;

    if (form.validate()) {
      usersRef.doc(globalID).update({
        "username": nameController.text,
      });
      form.save();
      SnackBar snackbar = SnackBar(content: Text("Welcome $username!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Timer(const Duration(seconds: 5), () {
        Navigator.pop(context, username);
        if (credits == 0) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (context) => AddCreditToAccount(
                userId: globalID,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => UsersToFollowList(
                userId: globalID,
              ),
            ),
          );
        }
      });
    }
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Create a username',
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
        'Next',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    ).onTap(() {
      submit();
    });
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formkey,
          child: TextFormField(
            controller: nameController,
            validator: (val) {
              if (val!.trim().length < 3 || val.isEmpty) {
                return "Username too short";
              } else if (val.trim().length > 12) {
                return "Username too long";
              } else {
                return null;
              }
            },
            onSaved: (val) => username = val,
            decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                filled: true,
                labelText: "Username",
                labelStyle: const TextStyle(fontSize: 15.0),
                hintText: "Must be at least 3 characters"),
          ),
        ),
      ],
    );
  }

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
                  const SizedBox(height: 50),
                  _emailPasswordWidget(),
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
