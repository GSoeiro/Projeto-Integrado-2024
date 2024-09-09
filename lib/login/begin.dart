import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softshares/backend/apiservice.dart';


class BeginPage extends StatefulWidget {
  final ApiService api;

  BeginPage({Key? key, required void Function() onThemeToggle, required this.api})
      : super(key: key);

  @override
  BeginPageState createState() => BeginPageState();
}

class BeginPageState extends State<BeginPage> {
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkRememberMe();
  }

  Future<void> _checkRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? savedRememberMe = prefs.getBool('rememberMe');
    
    setState(() {
      rememberMe = savedRememberMe ?? false;
    });
    Timer(const Duration(seconds: 2), () {
      if (rememberMe) {
        Navigator.pushReplacementNamed(context, '/welcomescreen');
      } else {
        Navigator.pushReplacementNamed(context, '/loginpage');
      }
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
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'SoftShares',
              style: TextStyle(fontSize: 50, color: theme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
