import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:simpleworld/widgets/bezier_container.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'forgetpass2.dart';

class ForgetPass extends StatefulWidget {
  const ForgetPass({Key? key}) : super(key: key);

  @override
  _ForgetPassState createState() => _ForgetPassState();
}

class _ForgetPassState extends State<ForgetPass> {
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailNode = FocusNode();

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 20),
                  Text(
                    'Enter Your registerd email below to receive \n password reset instruction',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Poppins-Medium',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  _emailPasswordWidget(),
                  const SizedBox(height: 20),
                  _submitButton(),
                ],
              ),
            ),
          ),
          Positioned(top: 40, left: 0, child: _backButton()),
          isLoading == true ? Center(child: circularProgress()) : Container(),
        ],
      ),
    ));
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Forgot your password?',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.red[800],
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Email id", emailController),
        // _entryField("Password", passwordController, isPassword: true),
      ],
    );
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  filled: true))
        ],
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
      if (emailController.text.trim() != "") {
        _signInWithEmailAndPassword();
      } else {
        simpleworldtoast(
            "Error",
            "Please, Enter your Email Address for reset your password",
            context);
      }
    });
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left,
                  color: Theme.of(context).iconTheme.color),
            ),
            const Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      setState(() {
        emailNode.unfocus();
        isLoading = true;
      });
      await _auth
          .sendPasswordResetEmail(
        email: emailController.text.trim(),
      )
          .then((value) {
        setState(() {
          isLoading = false;
        });
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const ForgetPass2(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        simpleworldtoast("Error", e.toString(), context);
      });
    }
  }
}
