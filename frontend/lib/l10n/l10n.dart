import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations._();

  static AppLocalizations of(BuildContext context) {
    return const AppLocalizations._();
  }

  static const List<LocalizationsDelegate<AppLocalizations>>
      localizationsDelegates = [];
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
  ];
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
