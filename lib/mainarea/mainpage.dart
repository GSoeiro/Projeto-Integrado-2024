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

//---------------------- Carregar dados da API ----------------------//

void loadBackend(ApiService apiService) async {
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

/*Future<bool> getRememberMe() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('rememberMe') ?? false;
}*/

//-----------------------Classe Drawer-------------------------------//

class CustomDrawer extends StatefulWidget {
  final BaseDeDados bd;
  final ValueChanged<List<int>> onSubcategoriasSelected;
  final ValueChanged<List<int>> onCitiesSelected;

  CustomDrawer({
    required this.bd,
    required this.onSubcategoriasSelected,
    required this.onCitiesSelected,
  });

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late Future<List<Map<String, dynamic>>> _categorias;
  late Future<List<Map<String, dynamic>>> _cidades;
  late Map<int, Future<List<Map<String, dynamic>>>> _subcategorias;
  List<int> _selectedSubcategorias = [];
  List<int> _selectedCategorias = [];
  List<int> _selectedCities = [];

  @override
  void initState() {
    super.initState();
    _categorias = widget.bd.mostrarCategorias();
    _cidades = widget.bd.mostrarCidades();
    _subcategorias = {};
  }

  void _updateSubcategorias(int categoriaId) async {
    setState(() {
      _subcategorias[categoriaId] = widget.bd.mostrarSubCategorias(categoriaId);
    });
  }

  void _onCategoriaChanged(bool selected, int categoriaId) async {
    if (selected) {
      _selectedCategorias.add(categoriaId);
      List<Map<String, dynamic>> subcategorias = await widget.bd.mostrarSubCategorias(categoriaId);
      for (var subcategoria in subcategorias) {
        int subcategoriaId = subcategoria['IDSUBCATEGORIA'];
        if (!_selectedSubcategorias.contains(subcategoriaId)) {
          _selectedSubcategorias.add(subcategoriaId);
        }
      }
    } else {
      _selectedCategorias.remove(categoriaId);
      List<Map<String, dynamic>> subcategorias = await widget.bd.mostrarSubCategorias(categoriaId);
      for (var subcategoria in subcategorias) {
        int subcategoriaId = subcategoria['IDSUBCATEGORIA'];
        _selectedSubcategorias.remove(subcategoriaId);
      }
    }
    _applyFilters();
  }

  void _onSubcategoriaChanged(bool selected, int subcategoriaId) {
    setState(() {
      if (selected) {
        _selectedSubcategorias.add(subcategoriaId);
      } else {
        _selectedSubcategorias.remove(subcategoriaId);
      }
    });
    _applyFilters();
  }

  void _onCityChanged(bool selected, int cidadeId) {
    setState(() {
      if (selected) {
        if (!_selectedCities.contains(cidadeId)) {
          _selectedCities.add(cidadeId);
        }
      } else {
        _selectedCities.remove(cidadeId);
      }
    });
    _applyFilters();
  }

  void _applyFilters() {
    widget.onSubcategoriasSelected(_selectedSubcategorias);
    widget.onCitiesSelected(_selectedCities);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 150,
            child: DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Text('Filtros', style: TextStyle(fontSize: 25)),
            ),
          ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _categorias,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erro ao carregar categorias');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('Sem categorias disponíveis');
              } else {
                return Expanded(
                  child: ListView(
                    children: snapshot.data!.map((categoria) {
                      int categoriaId = categoria['IDCATEGORIA'];
                      return ExpansionTile(
                        title: Row(
                          children: [
                            Checkbox(
                              value: _selectedCategorias.contains(categoriaId),
                              onChanged: (bool? value) {
                                _onCategoriaChanged(value!, categoriaId);
                              },
                            ),
                            Text(categoria['NOME']),
                          ],
                        ),
                        onExpansionChanged: (expanded) {
                          if (expanded) {
                            _updateSubcategorias(categoriaId);
                          }
                        },
                        children: <Widget>[
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _subcategorias[categoriaId],
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Erro ao carregar subcategorias');
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Text('Sem subcategorias disponíveis');
                              } else {
                                return Column(
                                  children: snapshot.data!.map((subcategoria) {
                                    int subcategoriaId = subcategoria['IDSUBCATEGORIA'];
                                    return ListTile(
                                      leading: Checkbox(
                                        value: _selectedSubcategorias.contains(subcategoriaId),
                                        onChanged: (bool? value) {
                                          _onSubcategoriaChanged(value!, subcategoriaId);
                                        },
                                      ),
                                      title: Text(subcategoria['NOME']),
                                    );
                                  }).toList(),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }
            },
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _cidades,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erro ao carregar cidades');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('Sem cidades disponíveis');
              } else {
                return Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.map((cidade) {
                      int cidadeId = cidade['IDCIDADE'];
                      return ListTile(
                        title: Text(cidade['NOME']),
                        leading: Checkbox(
                          value: _selectedCities.contains(cidadeId),
                          onChanged: (bool? value) {
                            _onCityChanged(value!, cidadeId);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
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
  List<int> _selectedSubcategorias = [];
  List<int> _selectedCities = [];

Future<List<Map<String, dynamic>>> loadPosts() async {
  List<Map<String, dynamic>> posts;

  if (_selectedCities.isEmpty && _selectedSubcategorias.isEmpty) {

    posts = await widget.bd.mostrarPosts();
  } else if (_selectedCities.isEmpty) {

    posts = await widget.bd.mostrarPostsBySubcategorias(_selectedSubcategorias);
  } else{
    posts = await widget.bd.mostrarPostsByCidade(_selectedCities);
  }

  print("Posts carregados: $posts");
  return posts;
}

  @override
  void initState() {
    super.initState();
    _initializeData();
    //_onRefresh();
  }

  Future<void> _initializeData() async {
    //bool rememberMe = await getRememberMe();
    loadBackend(widget.api);
    setState(() {
      _postsFuture = loadPosts();
    });
  }

  Future<void> _onRefresh() async {
    loadBackend(widget.api);
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
                        Icon(Icons.event_available_outlined, color: Colors.white),
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
                        Icon(Icons.space_dashboard_rounded, color: Colors.white),
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
                        Icon(Icons.calendar_month_rounded, color: Colors.white),
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

  //---------------------------------Construção da interface principal---------------------------------//

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
      drawer: CustomDrawer(
        bd: widget.bd,
      onCitiesSelected: (List<int> citiesSelected) {
        setState(() {
          _selectedCities = citiesSelected;
          _postsFuture = loadPosts();
        });
      },
      onSubcategoriasSelected: (List<int> subcategoriasSelecionadas) {
        setState(() {
          _selectedSubcategorias = subcategoriasSelecionadas; 
          _postsFuture = loadPosts(); 
        });
      },
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showOptionsButton,
        backgroundColor: theme.primaryColor,
        child: Icon(Icons.add),
      ),
    );
  }
}
