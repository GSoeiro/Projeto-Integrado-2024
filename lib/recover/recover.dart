import 'package:flutter/material.dart';
import 'package:softshares/other/translations.dart';
import '../services/apiservice.dart';
import 'dart:math';
import 'dart:convert';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecoverPage extends StatefulWidget {
  final ApiService api;

  RecoverPage({super.key, required this.api});

  @override
  _RecoverPageState createState() => _RecoverPageState();
}

class _RecoverPageState extends State<RecoverPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();
  bool valido = false;
  String codigo = 'a';
  String emailUser = 'a';
  bool codigoValidado = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  String gerarNumeroTemporario() {
    final length = 6;
    const characters = '0123456789';
    Random random = Random();

    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  Future<void> enviarNumeroTemporario(
      String email, String passwordTemporaria) async {
    String username = 'pintsoftshares24@gmail.com';
    String password = 'atmf bhjb cels kcgp';

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'SoftShares')
      ..recipients.add(email)
      ..subject = 'O seu código de recuperação!'
      ..text =
          'Bem vindo à SoftShares! O código para recuperar a sua palavra-passe é: $codigo.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Email enviado: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Email não enviado. ${e.toString()}');
    }
  }

  Future<void> _recuperar(String codigoUtilizador) async {
    String URL = 'https://pint-backend-8vxk.onrender.com/';
    print(emailUser);
    print(codigo);
    print(codigoUtilizador);

    if (codigo == codigoUtilizador) {
      print("Cheguei");
      var response = await http.get(
        Uri.parse(URL + 'mudarpassword/get/$emailUser'),
        headers: {
          'Authorization': 'Bearer $widget.api.token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print("Estou aqui!");
        var responseData = json.decode(response.body);
        if (responseData["success"] == true) {
          print(responseData);

          if (responseData['data']["CODIGO"] == codigo &&
              responseData['data']["CODIGO"] == codigoUtilizador) {
            codigoValidado = true;

            var response = await http.put(
                Uri.parse(URL + 'mudarpassword/delete/$emailUser'),
                headers: {
                  'Authorization': 'Bearer $widget.api.token',
                  'Content-Type': 'application/json',
                });
            Navigator.pushReplacementNamed(context, '/passworddefine');
          }
        }
      }
    }
  }

  Future<bool> _recuperarPorEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    print(email);

    emailUser = email;
    String colaboradorURL =
        'https://pint-backend-8vxk.onrender.com/colaborador/';
    String URL = 'https://pint-backend-8vxk.onrender.com/';

    var response = await http.get(
      Uri.parse(colaboradorURL + 'getByEmail/$email'),
      headers: {
        'Authorization': 'Bearer $widget.api.token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        try {} catch (err) {}
        var response = await http
            .put(Uri.parse(URL + 'mudarpassword/delete/$email'), headers: {
          'Authorization': 'Bearer $widget.api.token',
          'Content-Type': 'application/json',
        });

        codigo = gerarNumeroTemporario();
        print(codigo);
        await prefs.setString('emailUpdatePassword', email);

        Map<String, dynamic> datapost = {'EMAIL': email, 'CODIGO': codigo};
        var response2 = await http.post(Uri.parse(URL + 'mudarpassword/create'),
            headers: {
              'Authorization': 'Bearer $widget.api.token',
              'Content-Type': 'application/json',
            },
            body: json.encode(datapost));
        print(response2);
        if (response2.statusCode == 200) {
          var responseData2 = json.decode(response.body);
          enviarNumeroTemporario(email, codigo);
          print(email);
          print(codigo);
          valido = true;
          print(responseData2);
          return true;
        }
      }
    }
    return false;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
    final Color buttonColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: constraints.maxHeight * 0.2,
                      alignment: Alignment.center,
                      child: Text(
                        'SoftShares',
                        style: TextStyle(
                          color: buttonColor,
                          fontSize: 45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      margin: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        Translations.translate(context, 'recover_of_password'),
                        style: TextStyle(fontSize: 14, color: buttonColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      margin: const EdgeInsets.only(top: 60.0),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: Translations.translate(context, 'email'),
                          filled: true,
                          fillColor: theme.brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              Icon(Icons.email_outlined, color: textColor),
                          suffixIcon: emailController.text.isEmpty
                              ? null
                              : valido
                                  ? Icon(Icons.check, color: Colors.green)
                                  : Icon(Icons.clear, color: Colors.red),
                          hintStyle: TextStyle(color: hintColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        valido = await _recuperarPorEmail(emailController.text);
                        if (valido) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(Translations.translate(
                                    context, 'insert_code')),
                                content: TextField(
                                  controller: codigoController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText:
                                        Translations.translate(context, 'code'),
                                    fillColor:
                                        theme.brightness == Brightness.dark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      _recuperar(codigoController.text);
                                    },
                                    child: Text(
                                      'OK',
                                      style: TextStyle(color: buttonColor),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Erro'),
                                content: const Text(
                                    'O e-mail introduzido está incorreto.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'OK',
                                      style: TextStyle(color: buttonColor),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Text(Translations.translate(context, 'confirm'),
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 250),
                    Column(
                      children: [
                        Text(
                          Translations.translate(
                              context, 'remembered_password'),
                          style: TextStyle(fontSize: 14, color: textColor),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/loginpage');
                          },
                          child: Text(
                            Translations.translate(context, 'login'),
                            style: TextStyle(fontSize: 14, color: buttonColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
