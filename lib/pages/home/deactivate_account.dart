import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/data/user.dart' as user;
import 'package:global_net/pages/auth/login_page.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/share_preference/preferences_key.dart';
import 'package:nb_utils/nb_utils.dart';

class DeactiveAccount extends StatefulWidget {
  final String userId;

  const DeactiveAccount({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<DeactiveAccount> createState() => _DeactiveAccountState();
}

class _DeactiveAccountState extends State<DeactiveAccount> {
  bool _isDeactive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Deactivate the account',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                const Text(
                  'If you want to take a break, you can temporarily deactivate this account. If you want to permanently delete your account, please let us know.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                8.height,
                Card(
                    elevation: 8,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Deactivating your account is temporary. Your account and main profile will be deactivated and your name and photos will be removed from most things you\'ve shared.',
                            style: TextStyle(fontSize: 14),
                          ),
                          8.height,
                          if (_isDeactive) const CupertinoActivityIndicator(),
                          8.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ),
                              8.width,
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (!_isDeactive) {
                                      setState(() {
                                        _isDeactive = true;
                                        usersCollection
                                            .doc(widget.userId)
                                            .update({
                                          user.User.fieldNameActive: false,
                                          user.User.fieldNameTokenNotfaction: ''
                                        }).then((value) {
                                          _signOut();
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginPage(),
                                            ),
                                            (route) => false,
                                          );
                                        });
                                      });
                                    }
                                  },
                                  child: const Text('Deactive'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint('$e');
    }

    try {
      FirebaseAuth.instance.signOut();
      final pref = await SharedPreferences.getInstance();
      await pref.remove(SharedPreferencesKey.userId);
    } catch (e) {
      debugPrint('$e');
    }
  }
}
