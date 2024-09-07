import 'package:flutter/material.dart';
import 'dart:async';

class BeginPage extends StatefulWidget {
  BeginPage({Key? key, required void Function() onThemeToggle})
      : super(key: key);

  @override
  BeginPageState createState() => BeginPageState();
}

class BeginPageState extends State<BeginPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/loginpage');
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
