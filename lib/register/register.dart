import 'package:flutter/material.dart';
import 'package:softshares/backend/localdb.dart';
import 'package:softshares/other/translations.dart';
import '../backend/apiservice.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class RegisterPage extends StatefulWidget {
  final ApiService api;
  final BaseDeDados bd;

  RegisterPage({Key? key, required this.api, required this.bd})
      : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController novaPasswordController = TextEditingController();
  final TextEditingController confirmarPasswordController =
      TextEditingController();

  bool emailValido = false;
  bool nomeValido = false;
  bool senhaValida = false;
  int? _selectedCidade;

  @override
  void initState() {
    super.initState();
  }

  void _validateInputs() {
    setState(() {
      nomeValido = nameController.text.isNotEmpty;
      emailValido = _validateEmail(emailController.text);
    });
  }

  bool _validateEmail(String email) {
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }

  String gerarPasswordTemporaria() {
    final length = 5;
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();

    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  Future<void> enviarPasswordTemporaria(
      String email, String passwordTemporaria) async {
    String username = 'pintsoftshares24@gmail.com';
    String password = 'atmf bhjb cels kcgp';

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'SoftShares')
      ..recipients.add(email)
      ..subject = 'A sua palavra-passe temporária!'
      ..text =
          'Bem vindo à SoftShares! A sua palavra-passe temporária é: $passwordTemporaria.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Email enviado: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Email não enviado. ${e.toString()}');
    }
  }

  Future<void> _registar() async {
    _validateInputs();

    if (nomeValido && emailValido && _selectedCidade != null) {
      String passwordTemporaria = gerarPasswordTemporaria();
      try {
        await enviarPasswordTemporaria(
            emailController.text, passwordTemporaria);
 
        await _apiService.createUserOnBackend(
          emailController.text,
          passwordTemporaria,
          nameController.text,
          _selectedCidade!,
        );
        Navigator.pushReplacementNamed(context, '/loginpage');
      } catch (e) {
        _showErrorDialog('Erro',
            'Não foi possível completar o registo. Por favor, tente novamente.');
      }
    } else {
      _showErrorDialog(
          'Erro', 'Por favor, preencha todos os campos corretamente.');
    }
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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 100.0,
                margin: const EdgeInsets.only(top: 40.0),
                alignment: Alignment.center,
                child: Text(
                  'SoftShares',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 45,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15.0),
                child: Text(
                  Translations.translate(context, 'register'),
                  style: TextStyle(fontSize: 20, color: theme.primaryColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                margin: const EdgeInsets.only(top: 40.0),
                child: TextField(
                  controller: nameController,
                  onChanged: (_) => _validateInputs(),
                  decoration: InputDecoration(
                    hintText: Translations.translate(context, 'name'),
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: textColor,
                    ),
                    hintStyle: TextStyle(
                      color: hintColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                child: TextField(
                  controller: emailController,
                  onChanged: (_) => _validateInputs(),
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
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: textColor,
                    ),
                    hintStyle: TextStyle(
                      color: hintColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              DropDownCidades(
                api: widget.api,
                bd: widget.bd,
                onChanged: (value) {
                  setState(() {
                    _selectedCidade = value; // Reset subcategoria
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _registar(),
                child: Text(Translations.translate(context, 'continue'),
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const SizedBox(height: 150),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Center the content vertically if needed
                  children: [
                    Text(
                      Translations.translate(
                          context, 'already_have_an_account'),
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                    SizedBox(
                        width:
                            30), 
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/loginpage');
                      },
                      child: Text(
                        Translations.translate(context, 'login'),
                        style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(0, 179, 255, 1.0)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class DropDownCidades extends StatefulWidget {
  ApiService api;
  final BaseDeDados bd;
  final Function(int) onChanged;

  DropDownCidades(
      {Key? key, required this.onChanged, required this.api, required this.bd})
      : super(key: key);

  @override
  _DropDownCidadesState createState() => _DropDownCidadesState();
}

class _DropDownCidadesState extends State<DropDownCidades> {
  int? _selectedCidade;

  late Future<List<Map<String, dynamic>>> cidadesFuture;

  @override
  void initState() {
    super.initState();
    cidadesFuture = widget.bd.mostrarCidades();
    print('postsFuture initialized');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: cidadesFuture,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('A carregar!');
        } else if (snapshot.hasError) {
          return Text('Erro ao carregar cidades: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('Nenhuma cidade encontrada');
        } else {
          List<dynamic>? cidades = snapshot.data;
          return DropdownButtonFormField<int>(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: _selectedCidade,
            items: cidades!.map((cidade) {
              return DropdownMenuItem<int>(
                value: cidade['IDCIDADE'],
                child: Text(cidade['NOME']),
              );
            }).toList(),
            hint: Text('Cidade'),
            onChanged: (value) {
              setState(() {
                _selectedCidade = value;
                widget.onChanged(value!);
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor, selecione a cidade que pretende';
              }
              return null;
            },
          );
        }
      },
    );
  }
}
