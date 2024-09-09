import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:softshares/login/welcomescreen.dart';
import 'package:softshares/recover/passworddefine.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softshares/login/begin.dart';
import '../mainarea/mapspage.dart';
import 'login/login.dart';
import 'mainarea/mainpage.dart';
import 'recover/recover.dart';
import 'register/register.dart';
import 'mainarea/settings.dart';
import 'services/apiservice.dart';
import 'services/localdb.dart';
import 'other/themes.dart';
import 'other/locale.dart';
import '../mainarea/publicacoes.dart';

void load(ApiService apiService) async {
  try {
    await apiService.downloadPostsCidade(apiService.cidade);
  } catch (e) {
    print("Erro no main.dart");
    print('Erro ao transferir os posts: $e');
  }

  try {
    await apiService.downloadCategorias();
  } catch (e) {
    print("Erro no main.dart");
    print('Erro ao transferir as categorias: $e');
  }

  try {
    await apiService.downloadSubCategorias();
  } catch (e) {
    print("Erro no main.dart");
    print('Erro ao transferir os posts: $e');
  }

  try {
    await apiService.downloadCidades();
  } catch (e) {
    print("Erro no main.dart");
    print('Erro ao transferir os posts: $e');
  }

  try {
    await apiService.dowloadEspaco();
  } catch (e) {
    print("Erro no main.dart");
    print('Erro ao transferir os espaços: $e');
  }

  try {
    await apiService.downloadEventos();
  } catch (e) {
    print("Erro no main.dart");
    print('Erro ao transferir os eventos: $e');
  }
}

void main() async {

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'events_channel',
        channelName: 'Notificação de Eventos',
        channelDescription: 'Notificações de eventos',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
      NotificationChannel(
        channelKey: 'spaces_channel',
        channelName: 'Notificação de Espaços',
        channelDescription: 'Notificações de Espaços',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
      )
    ],
  );
  AwesomeNotifications().requestPermissionToSendNotifications();
  WidgetsFlutterBinding.ensureInitialized();
  ApiService apiService = ApiService();
  BaseDeDados bd = BaseDeDados();
  await bd.initDB();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;

  try {
    await apiService.downloadCidades();
  } catch (e) {
    print("Erro no main.dart");
    print('Erro ao transferir as cidades: $e');
  }

  runApp(MyApp(apiService: apiService, bd: bd, isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final ApiService apiService;
  final BaseDeDados bd;
  final bool isDarkMode;

  MyApp({required this.apiService, required this.bd, required this.isDarkMode});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    load(widget.apiService);
     AwesomeNotifications().requestPermissionToSendNotifications().then((granted) {
      if (granted) {
        print('Permissão para notificações concedida');
      } else {
        print('Permissão para notificações negada');
      }
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _saveThemePreference(_isDarkMode);
  }

  Future<void> _saveThemePreference(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            theme: _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme,
            supportedLocales: [
              Locale('pt', ''),
              Locale('en', ''),
              Locale('es', ''),
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: localeProvider.locale,
            home: BeginPage(onThemeToggle: _toggleTheme, api: widget.apiService,),
            routes: {
              '/recoverpassword': (context) =>
                  RecoverPage(api: widget.apiService),
              '/loginpage': (context) => LoginPage(api: widget.apiService),
              '/mainpage': (context) =>
                  MainPage(api: widget.apiService, bd: widget.bd),
              '/registerpage': (context) =>
                  RegisterPage(api: widget.apiService, bd: widget.bd),
              '/settingspage': (context) => SettingsPage(
                  api: widget.apiService, onThemeToggle: _toggleTheme),
              '/mapspage': (context) => GoogleMapsPage(),
              '/passworddefine': (context) =>
                  PasswordDefine(api: widget.apiService),
              '/publicacoespage': (context) =>
                  PostDetailsPage(api: widget.apiService, event: {}),
              '/welcomescreen': (context) =>
                  WelcomeScreen(api: widget.apiService),
            },
          );
        },
      ),
    );
  }
}
