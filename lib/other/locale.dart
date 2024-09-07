import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = Locale('pt');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localeString = prefs.getString('locale') ?? 'pt';
    _locale = Locale(localeString);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (locale != _locale) {
      _locale = locale;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', locale.languageCode);
      notifyListeners();
    }
  }
}
