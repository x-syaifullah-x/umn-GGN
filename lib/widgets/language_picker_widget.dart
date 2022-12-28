import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:simpleworld/l10n/l10n.dart';
import 'package:simpleworld/provider/locale_provider.dart';

class LanguageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final flag = L10n.getFlag(locale.languageCode);

    return Center(
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 72,
        child: Center(
          child: Text(
            flag,
            style: TextStyle(fontSize: 80),
          ),
        ),
      ),
    );
  }
}

class LanguagePickerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext buildcontext) {
    final provider = Provider.of<LocaleProvider>(buildcontext);
    final locale = provider.locale ?? Locale('en');

    return GestureDetector(
        onTap: () {
          _showDialog(buildcontext);
        },
        child: Container(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.cyan,
            ),
            child: Center(
              child: Text(
                L10n.getFlagnName(locale.languageCode),
                style: TextStyle(fontSize: 15),
              ),
            )
            // DropdownButtonHideUnderline(
            //   child: Center(
            //     child: DropdownButton(
            //       value: locale,
            //       icon: Container(width: 12),
            //       items: L10n.all.map(
            //         (locale) {
            //           final flag = L10n.getFlagnName(locale.languageCode);

            //           return DropdownMenuItem(
            //             alignment: Alignment.center,
            //             child: Text(
            //               flag,
            //               style: TextStyle(fontSize: 15),
            //             ),
            //             value: locale,
            //             onTap: () {
            //               final provider =
            //                   Provider.of<LocaleProvider>(context, listen: false);

            //               provider.setLocale(locale);
            //             },
            //           );
            //         },
            //       ).toList(),
            //       onChanged: (_) {},
            //     ),
            //   ),
            // ),
            ));
  }

  // Show Dialog function
  void _showDialog(buildContext) {
    // flutter defined function
    showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return Provider<LocaleProvider>(
          create: (_) => LocaleProvider(),
          child: AlertDialog(
            title: const Text('Pick Your Language'),
            content: Container(
              height: 160.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(L10n.getFlagnName('ar')),
                      ),
                    ],
                  ).onTap(() {
                    Navigator.pop(context);
                    final provider = Provider.of<LocaleProvider>(buildContext,
                        listen: false);

                    provider.setLocale(Locale('ar'));
                  }),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(L10n.getFlagnName('hi')),
                      ),
                    ],
                  ).onTap(() {
                    Navigator.pop(context);
                    final provider = Provider.of<LocaleProvider>(buildContext,
                        listen: false);

                    provider.setLocale(Locale('hi'));
                  }),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(L10n.getFlagnName('es')),
                      ),
                    ],
                  ).onTap(() {
                    Navigator.pop(context);
                    final provider = Provider.of<LocaleProvider>(buildContext,
                        listen: false);

                    provider.setLocale(Locale('es'));
                  }),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(L10n.getFlagnName('en')),
                      ),
                    ],
                  ).onTap(() {
                    Navigator.pop(context);
                    final provider = Provider.of<LocaleProvider>(buildContext,
                        listen: false);
                    provider.setLocale(Locale('en'));
                  }),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(L10n.getFlagnName('zh')),
                      ),
                    ],
                  ).onTap(() {
                    Navigator.pop(context);
                    final provider = Provider.of<LocaleProvider>(buildContext,
                        listen: false);
                    provider.setLocale(Locale('zh'));
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
