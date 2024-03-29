import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/pages/auth/add_credit_to_account.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/user_to_follow.dart';
import 'package:global_net/widgets/bezier_container.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class CreateAccount extends StatefulWidget {
  final String? userId;

  const CreateAccount({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  CreateAccountState createState() => CreateAccountState();
}

class CreateAccountState extends State<CreateAccount> {
  final _formkey = GlobalKey<FormState>();
  String? username;
  int credits = 0;
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCredit(widget.userId);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener(
        onNotification: (notification) {
          return true;
        },
        child: SafeArea(
          child: _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
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
                  _submitButton(widget.userId!),
                ],
              ),
            ),
          ),
          isLoading == true ? Center(child: circularProgress()) : Container(),
        ],
      ),
    );
  }

  getCredit(String? userId) async {
    usersCollection
        .doc(userId)
        .get()
        .then(
          (value) => setState(() {
            credits = value["credit_points"];
          }),
        )
        .catchError(onError);
  }

  submit(String userId) {
    final form = _formkey.currentState!;

    if (form.validate()) {
      usersCollection.doc(userId).update({
        "username": nameController.text,
      });
      form.save();
      SnackBar snackbar = SnackBar(content: Text("Welcome $username!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);

      if (credits == 0) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => AddCreditToAccount(
              userId: userId,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => UsersToFollowList(
              userId: userId,
            ),
          ),
        );
      }

      // Timer(const Duration(seconds: 2), () {
      //   //   Navigator.pop(context, username);
      //   if (credits == 0) {
      //     Navigator.of(context).pushReplacement(
      //       CupertinoPageRoute(
      //         builder: (context) => AddCreditToAccount(
      //           userId: userId,
      //         ),
      //       ),
      //     );
      //   } else {
      //     Navigator.push(
      //       context,
      //       CupertinoPageRoute(
      //         builder: (context) => UsersToFollowList(
      //           userId: userId,
      //         ),
      //       ),
      //     );
      //   }
      // });
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

  Widget _submitButton(String userId) {
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
        'Next',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    ).onTap(() {
      submit(userId);
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
}
