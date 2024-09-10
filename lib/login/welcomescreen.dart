import 'package:flutter/material.dart';
import 'package:softshares/other/translations.dart';
import 'package:softshares/services/apiservice.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  final ApiService api;

  WelcomeScreen({super.key, required this.api});
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String nomeColaborador = '';

  @override
  void initState() {
    super.initState();
    _loadNomeColaborador();
  }

  Future<void> _loadNomeColaborador() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nomeColaborador = prefs.getString('nomeColaborador') ?? '';
    });

    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/mainpage');
    });
  }


@override
Widget build(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final Color backgroundColor = theme.brightness == Brightness.dark
      ? Colors.grey[900]!
      : Colors.grey[100]!;
  final Color textColor =
      theme.brightness == Brightness.dark ? Colors.white : Colors.black;
  final Color hintColor =
      theme.brightness == Brightness.dark ? Colors.white54 : Colors.black54;
  final hour = DateTime.now().hour;
  Text greeting;
  if (hour > 7 && hour < 12) {
    greeting = Text(Translations.translate(context, 'morning'), style: TextStyle(fontSize: 40, color: theme.primaryColor));
  } else if (hour >= 12 && hour < 20) {
    greeting = Text(Translations.translate(context, 'afternoon'), style: TextStyle(fontSize: 40, color: theme.primaryColor));
  } else {
    greeting = Text(Translations.translate(context, 'night'),  style: TextStyle(fontSize: 40, color: theme.primaryColor));
  }
  return Scaffold(
    backgroundColor: backgroundColor,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          greeting, // Use a variável diretamente aqui
          Text(nomeColaborador,
              style: TextStyle(fontSize: 35, color: theme.primaryColor))
        ],
      ),
    ),
  );
}
}
