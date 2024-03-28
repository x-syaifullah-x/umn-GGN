import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_net/data/user.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/menu/terms_and_conditions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ChangeCurrency extends StatefulWidget {
  final User user;
  const ChangeCurrency({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ChangeCurrency> createState() => _ChangeCurrencyState();
}

class _ChangeCurrencyState extends State<ChangeCurrency> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    const textStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(
            'Change Currency',
            style: GoogleFonts.portLligatSans(
              textStyle: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'There will be a \$10.00 charge from your GGN credit account to use this feature.',
                        style: textStyle,
                      ),
                      4.height,
                      user.currency == 'USD'
                          ? const Text(
                              'This feature will allow you to convert your US dollars into China\'s RMB.',
                              style: textStyle,
                            )
                          : const Text(
                              'This feature will allow you to convert your China\'s RMB into US dollars.',
                              style: textStyle,
                            ),
                      4.height,
                      const Text(
                        'Pay your Chinese suppliers/employees directly with no hidden international fees.',
                        style: textStyle,
                      ),
                      4.height,
                      const Text(
                        'For more information see our terms and conditions.',
                        style: textStyle,
                      ),
                      16.height,
                      const Text(
                        'C.E.O',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      4.height,
                      const Text(
                        'Lacey Yang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      8.height,
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .8,
                          height: MediaQuery.of(context).size.height * .55,
                          child: Image.asset(
                            'assets/images/RMBgirlsr.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .75,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    8.width,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          firestore.collection('tmp').doc(user.id).set({
                            'type': 'update_currency',
                            'currency': user.currency == 'USD' ? 'CYN' : 'USD',
                            'user_id': user.id,
                          }).then((value) {
                            Navigator.of(context).pop();
                            toast(
                              'Requests for currency changes are being processed, please wait a moment, thank you.',
                              length: Toast.LENGTH_LONG,
                            );
                          });
                        },
                        child: const Text('Change'),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    const url =
                        'https://globalgnet.net/home/terms-and-conditions';
                    if (kIsWeb) {
                      launchUrl(Uri.parse(url));
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsAndConditions(
                            url: url,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Terms & Conditions'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
