import 'package:flutter/material.dart';
import 'package:softshares/other/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/apiservice.dart';

class PasswordDefine extends StatefulWidget {
  final ApiService api;

  PasswordDefine({super.key, required this.api});

  @override
  _PasswordDefineState createState() => _PasswordDefineState();
}

class _PasswordDefineState extends State<PasswordDefine> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool passwordValid = false;
  bool confirmPasswordValid = false;

  @override
  void initState() {
    super.initState();

    passwordController.addListener(_validatePasswords);
    confirmPasswordController.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    setState(() {
      String password = passwordController.text;
      String confirmPassword = confirmPasswordController.text;

      passwordValid = password.isNotEmpty && password.length >= 6;
      confirmPasswordValid =
          confirmPassword.isNotEmpty && password == confirmPassword;
    });
  }

  Future<void> _resetPassword() async {
    if (passwordValid && confirmPasswordValid) {
      try {} catch (err) {}
    }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 100.0,
                margin: EdgeInsets.only(top: 40.0),
                alignment: Alignment.center,
                child: Text(
                  'SoftShares',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 45,
                  ),
                ),
              ),
              SizedBox(height: 35),
              Text(
                Translations.translate(context, 'recover_of_password'),
                style: TextStyle(color: theme.primaryColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 75),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: Translations.translate(context, 'new_password'),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: textColor),
                  suffixIcon: passwordController.text.isEmpty
                      ? null
                      : Icon(
                          passwordValid ? Icons.check : Icons.clear,
                          color: passwordValid ? Colors.green : Colors.red,
                        ),
                  hintStyle: TextStyle(color: hintColor),
                ),
                obscureText: true,
              ),
              SizedBox(height: 18),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  hintText:
                      Translations.translate(context, 'confirm_new_password'),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: textColor),
                  suffixIcon: confirmPasswordController.text.isEmpty
                      ? null
                      : Icon(
                          confirmPasswordValid ? Icons.check : Icons.clear,
                          color:
                              confirmPasswordValid ? Colors.green : Colors.red,
                        ),
                  hintStyle: TextStyle(color: hintColor),
                ),
                obscureText: true,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  String? email = await prefs.getString('emailUpdatePassword');

                  if (passwordController.text ==
                      confirmPasswordController.text) {
                    widget.api.resetPassword(passwordController.text, email!);
                    Navigator.pushReplacementNamed(context, '/loginpage');
                  }
                },
                child: Text(
                  'Confirmar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 80),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('remembered_password',
                      style: TextStyle(color: textColor)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/loginpage');
                    },
                    child: Text(
                      Translations.translate(context, 'login'),
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
