import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:global_net/l10n/l10n.dart';
import 'package:global_net/provider/locale_provider.dart';

class LanguageWidgetHome extends StatelessWidget {
  const LanguageWidgetHome({Key? key}) : super(key: key);

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
            style: const TextStyle(fontSize: 80),
          ),
        ),
      ),
    );
  }
}

class LanguagePickerWidgetHome extends StatelessWidget {
  const LanguagePickerWidgetHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final locale = provider.locale ?? const Locale('en');

    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: DropdownButtonHideUnderline(
        child: Center(
          child: DropdownButton(
            value: locale,
            icon: Container(width: 12),
            items: L10n.alls.map(
              (locale) {
                final flag = L10n.getFlag(locale.languageCode);

                return DropdownMenuItem(
                  alignment: Alignment.center,
                  value: locale,
                  onTap: () {
                    final provider =
                        Provider.of<LocaleProvider>(context, listen: false);

                    provider.setLocale(locale);
                  },
                  child: Text(
                    kIsWeb ? "语言: $flag" : flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              },
            ).toList(),
            onChanged: (_) {},
          ),
        ),
      ),
    );
  }
}
