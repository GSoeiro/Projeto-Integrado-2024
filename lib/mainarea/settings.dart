import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/apiservice.dart';
import '../other/locale.dart';
import '../other/translations.dart';

class SettingsPage extends StatefulWidget {
  final ApiService api;
  final VoidCallback onThemeToggle;

  SettingsPage({super.key, required this.api, required this.onThemeToggle});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  String nomeColaborador = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadNomeColaborador();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false; 
      String? savedLanguage = prefs.getString('languageCode');
      if (savedLanguage != null) {
        Provider.of<LocaleProvider>(context, listen: false)
            .setLocale(Locale(savedLanguage));
      }
    });
  }

  Future<void> _saveThemePreference(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _saveThemePreference(value);
    widget.onThemeToggle();
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cidade');
    await prefs.remove('nomeColaborador');
    await prefs.remove('isDarkMode');
    await prefs.remove('languageCode');
    widget.onThemeToggle();
    Navigator.pushReplacementNamed(context, '/loginpage');
    setState(() {
      _isDarkMode = false;
    });
  }

  void _changeLanguage(String languageCode) async {
    Provider.of<LocaleProvider>(context, listen: false)
        .setLocale(Locale(languageCode));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }

  Future<void> _loadNomeColaborador() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nomeColaborador = prefs.getString('nomeColaborador') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.translate(context, 'settings'),
          style: TextStyle(color: Color.fromRGBO(0, 179, 255, 1.0)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(0, 179, 255, 1.0)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/settingsimage.png',
                        width: 70, height: 70),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nomeColaborador,
                              style: TextStyle(fontSize: 23)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(
                    color: Color.fromRGBO(141, 152, 167, 1.0), thickness: 1.0),
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.brightness_6),
                  title: Text(Translations.translate(context, 'dark_mode')),
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: _toggleDarkMode,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  Translations.translate(context, 'choose_language'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ListTile(
                  leading: Icon(Icons.language),
                  title: Text(Translations.translate(context, 'portuguese')),
                  onTap: () => _changeLanguage('pt'),
                ),
                ListTile(
                  leading: Icon(Icons.language),
                  title: Text(Translations.translate(context, 'english')),
                  onTap: () => _changeLanguage('en'),
                ),
                ListTile(
                  leading: Icon(Icons.language),
                  title: Text(Translations.translate(context, 'spanish')),
                  onTap: () => _changeLanguage('es'),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _showLogoutConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        Translations.translate(context, 'logout'),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          content: Text(
            Translations.translate(context, 'logout_confirmation'),
            style: TextStyle(color: theme.primaryColor),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _logout,
                  child: Text(
                    Translations.translate(context, 'confirm'),
                    style: TextStyle(color: theme.primaryColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    Translations.translate(context, 'cancel'),
                    style: TextStyle(color: theme.hintColor),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

