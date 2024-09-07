import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softshares/backend/localdb.dart';
import 'package:softshares/mainarea/calendar.dart';
import 'package:softshares/other/translations.dart';
import '/mainarea/eventcreationpage.dart';
import '/mainarea/spacecreationpage.dart';
import '../backend/apiservice.dart';

void load(ApiService apiService) async {
  try {
    await apiService.downloadPosts(apiService.cidade);
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


Future<bool> getRememberMe() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('rememberMe') ?? false; 
}

//-------------------------------------Classe MainPage---------------------------------------//

class MainPage extends StatefulWidget {
  final ApiService api;
  final BaseDeDados bd;

  MainPage({super.key, required this.api, required this.bd});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  Future<List<Map<String, dynamic>>>? _postsFuture;

Future<List<Map<String, dynamic>>> loadPosts() async {
  List<Map<String, dynamic>> posts = await widget.bd.mostrarPosts(widget.api.cidade);
  print("Posts carregados: $posts"); // Adicione este log para depuração
  return posts;
}


@override
void initState() {
  super.initState();
  _initializeData();
}

Future<void> _initializeData() async {
  bool rememberMe = await getRememberMe();
  print("Valor de rememberMe: $rememberMe");
  load(widget.api);
  setState(() {
    _postsFuture = loadPosts(); 
  });
}

Future<void> _onRefresh() async {
  load(widget.api);
  setState(() {
    _postsFuture = loadPosts(); 
  });
}


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

//-------------------------------------Função do ícone '+'---------------------------------------//

  void _showOptionsButton() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final ThemeData theme = Theme.of(context);

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Eventcreationpage(api: widget.api, bd: widget.bd),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = Offset(0.0, 1.0);
                          var end = Offset.zero;
                          var curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8.0),
                        Text(
                          Translations.translate(context, 'create_event'),
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Spacecreationpage(
                          api: widget.api,
                          bd: widget.bd,
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = Offset(0.0, 1.0);
                          var end = Offset.zero;
                          var curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8.0),
                        Text(
                          Translations.translate(context, 'create_space'),
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            CalendarPage(
                          api: widget.api,
                          bd: widget.bd,
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = Offset(0.0, 1.0);
                          var end = Offset.zero;
                          var curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8.0),
                        Text(
                          Translations.translate(context, 'calendar'),
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //-------------------------------------Início do corpo da página---------------------------------------//

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: theme.primaryColor,
                    ),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: Translations.translate(context, 'looking_for'),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.all(12.0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settingspage');
              },
              icon: Icon(
                Icons.settings_outlined,
                color: theme.primaryColor,
                size: 27,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
      onRefresh: _onRefresh,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.connectionState == ConnectionState.done) {
            print(snapshot);
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  Center(child: Text('Não existem publicações disponíveis')),
                  SizedBox(height: 200),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var post = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/publicacoespage',
                        arguments: post);
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(10),
                      color: theme.cardColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['TITULO'] ?? 'Não existe título',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${post['NOMECATEGORIA'] ?? 'Não existe categoria'} - ${post['NOMESUBCATEGORIA'] ?? 'Não existe subcategoria'}',
                          style: TextStyle(
                              fontSize: 14, color: theme.disabledColor),
                        ),
                        SizedBox(height: 10),
                        post['IMAGEM'] != 'semimagem'
                            ? Image.file(File(post['IMAGEM']))
                            : SizedBox(height: 10),
                        SizedBox(height: 10),
                        Text(
                          post['TEXTO'] ?? 'Não existe descrição',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Nenhum dado disponível.'));
          }
        },
      ),
    ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.primaryColor,
              ),
              child: Center(
                child: Text(
                  Translations.translate(context, 'filters'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showOptionsButton,
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/*class MyImageWidget extends StatelessWidget {
  final Map<String, dynamic> post;

  MyImageWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    return Image.file(File(post['IMAGEM']));
  }*/

/*class Posts extends StatefulWidget {
  final ApiService api;
  final BaseDeDados bd;


  Posts({required this.api, required this.bd});

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  late Future<List<Map<String, dynamic>>> _postsFuture;

  @override
  void initState() {
    super.initState();
    setState(() {
      _postsFuture = loadPosts();
    });
  }

  Future<List<Map<String, dynamic>>> loadPosts() async {
    return await widget.bd.mostrarPosts(widget.api.cidade);
  }

  Future<void> _onRefresh() async {
    await loadPosts();
    setState(() {
    _postsFuture = loadPosts(); 
  });
  initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  Center(child: Text('Não existem publicações disponíveis')),
                  SizedBox(height: 200),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var post = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/publicacoespage',
                        arguments: post);
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(10),
                      color: theme.cardColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['TITULO'] ?? 'Não existe título',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${post['NOMECATEGORIA'] ?? 'Não existe categoria'} - ${post['NOMESUBCATEGORIA'] ?? 'Não existe subcategoria'}',
                          style: TextStyle(
                              fontSize: 14, color: theme.disabledColor),
                        ),
                        SizedBox(height: 10),
                        post['IMAGEM'] != 'semimagem'
                            ? MyImageWidget(post: post)
                            : SizedBox(height: 10),
                        SizedBox(height: 10),
                        Text(
                          post['TEXTO'] ?? 'Não existe descrição',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Nenhum dado disponível.'));
          }
        },
      ),
    );
  }
}*/
