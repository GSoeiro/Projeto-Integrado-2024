import 'package:flutter/material.dart';
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
    String greeting;
    if (hour < 12) {
      greeting = 'Bom Dia';
    } else if (hour < 18) {
      greeting = 'Boa Tarde';
    } else {
      greeting = 'Boa Noite';
    }
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$greeting',
              style: TextStyle(fontSize: 40, color: theme.primaryColor),
            ),
            Text(nomeColaborador,
                style: TextStyle(fontSize: 35, color: theme.primaryColor))
          ],
        ),
      ),
    );
  }
}
