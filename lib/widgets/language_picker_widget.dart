import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:global_net/l10n/l10n.dart';
import 'package:global_net/provider/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageWidget extends StatelessWidget {
  const LanguageWidget({Key? key}) : super(key: key);

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
    showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return Provider<LocaleProvider>(
          create: (_) => LocaleProvider(),
          child: AlertDialog(
            title: Text(AppLocalizations.of(context)?.pick_your_language ??
                "Pick Your Language"),
            content: SizedBox(
              height: 180.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: L10n.alls
                    .map((e) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Text(
                            L10n.getFlagnName(e.languageCode),
                            // textAlign: TextAlign.left,
                          ),
                        ).onTap(() {
                          Navigator.pop(context);
                          final provider = Provider.of<LocaleProvider>(
                            buildContext,
                            listen: false,
                          );
                          provider.setLocale(e);
                        }))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
