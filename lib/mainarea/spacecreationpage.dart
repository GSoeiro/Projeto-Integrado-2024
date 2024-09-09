import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:softshares/backend/localdb.dart';
import 'package:softshares/other/translations.dart';
import '../backend/apiservice.dart';
import 'package:geolocator/geolocator.dart';

class Spacecreationpage extends StatefulWidget {
  final ApiService api;
  final BaseDeDados bd;

  Spacecreationpage({Key? key, required this.api, required this.bd})
      : super(key: key);

  @override
  _SpaceCreationPageState createState() => _SpaceCreationPageState();
}

class _SpaceCreationPageState extends State<Spacecreationpage> {
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _subcategoriaController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();

  File? _image;
  String? imagem;
  String? path;
  final picker = ImagePicker();

  int? _selectedCategoria;
  int? _selectedSubCategoria;
   int? _selectedCidade;
  Uint8List? imageBytes;

  Future<void> _pickImage() async {
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageBytes = await pickedFile.readAsBytes();
    } else {
      imagem = null;
      _image = null;
    }
    setState(() {});
  }

  Future<void> _criarEspaco() async {
    if (_selectedCategoria == null) {
      print('Por favor, selecione uma categoria.');
      return;
    }

    if (_selectedSubCategoria == null) {
      print('Por favor, selecione uma subcategoria.');
      return;
    }

    String cidade = _selectedCidade.toString();
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;
    String website = _websiteController.text;
    String categoria = _selectedCategoria.toString();
    String subcategoria = _selectedSubCategoria.toString();
    String preco = _precoController.text;
    

    await widget.api.criarEspaco(cidade, titulo, _descricaoController.text, website, categoria, subcategoria, imageBytes, preco);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color.fromRGBO(0, 179, 255, 1.0)),
        title: Text(
          Translations.translate(context, 'create_space'),
          style: TextStyle(
              color: Color.fromRGBO(0, 179, 255, 1.0), fontSize: 20.0),
        ),
        actions: [
          TextButton(
            onPressed: _criarEspaco,
            child: Text(
              Translations.translate(context, 'create'),
              style: TextStyle(
                  color: Color.fromRGBO(0, 179, 255, 1.0), fontSize: 20.0),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      Translations.translate(context, 'city'),
                      style: TextStyle(fontSize: 18),
                      maxLines: 1,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: DropDownCidades(
                      api: widget.api,
                      bd: widget.bd,
                      onChanged: (value) {
                        setState(() {
                          _selectedCidade = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        Translations.translate(context, 'category'),
                        style: TextStyle(fontSize: 18),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: DropDownCategorias(
                        api: widget.api,
                        bd: widget.bd,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoria = value;
                            _selectedSubCategoria = null; // Reset subcategoria
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        Translations.translate(context, 'subcategory'),
                        style: TextStyle(fontSize: 18),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: _selectedCategoria == null
                          ? Text(Translations.translate(
                              context, 'choose_category_first'))
                          : DropDownSubCategorias(
                              categoriaSelecionada: _selectedCategoria!,
                              bd: widget.bd,
                              onChanged: (value) {
                                setState(() {
                                  _selectedSubCategoria = value;
                                });
                              },
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        Translations.translate(context, 'title'),
                        style: TextStyle(fontSize: 18),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            Translations.translate(context, 'insert_title'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o título';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        Translations.translate(context, 'description'),
                        style: TextStyle(fontSize: 18),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _descricaoController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: Translations.translate(
                            context, 'insert_description'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira uma descrição';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        Translations.translate(context, 'website'),
                        style: TextStyle(fontSize: 18),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _websiteController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: Translations.translate(context, 'website'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o link do site';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        Translations.translate(context, 'coordinates'),
                        style: TextStyle(fontSize: 18),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/mapspage');
                        },
                        child: Text(Translations.translate(context, 'map'))),
                  ),
                ],
              ),
                    Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        Translations.translate(context, 'price'),
                        style: TextStyle(fontSize: 18),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _precoController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: Translations.translate(context, 'price'),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        Translations.translate(context, 'imagem'),
                        style: TextStyle(fontSize: 18),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: _image != null
                                ? Image.file(
                                    _image!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child:
                                        Icon(Icons.upload_outlined, size: 40),
                                  ),
                          ),
                          if (_image != null)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _image = null; 
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class DropDownCategorias extends StatefulWidget {
  ApiService api;
  final BaseDeDados bd;
  final Function(int) onChanged;

  DropDownCategorias(
      {Key? key, required this.onChanged, required this.api, required this.bd})
      : super(key: key);

  @override
  _DropDownCategoriasState createState() => _DropDownCategoriasState();
}

class _DropDownCategoriasState extends State<DropDownCategorias> {
  late Future<List<Map<String, dynamic>>> categoriasFuture;

  @override
  void initState() {
    super.initState();
    categoriasFuture = widget.bd.mostrarCategorias();
    print('categoriasFuture initialized');
  }

  int? _selectedCategoria;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: categoriasFuture,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('A carregar!');
        } else if (snapshot.hasError) {
          return Text('Erro ao carregar categorias: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('Nenhuma categoria encontrada');
        } else {
          List<dynamic>? categorias = snapshot.data;
          return DropdownButtonFormField<int>(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: _selectedCategoria,
            items: categorias!.map((categoria) {
              return DropdownMenuItem<int>(
                value: categoria['IDCATEGORIA'],
                child: Text(categoria['NOME']),
              );
            }).toList(),
            hint: Text('Categoria'),
            onChanged: (value) {
              setState(() {
                _selectedCategoria = value;
                widget.onChanged(value!);
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor, selecione a categoria que pretende';
              }
              return null;
            },
          );
        }
      },
    );
  }
}

class DropDownSubCategorias extends StatefulWidget {
  final int categoriaSelecionada; 
  final Function(int) onChanged;
  final BaseDeDados bd;

  DropDownSubCategorias({
    Key? key,
    required this.categoriaSelecionada,
    required this.onChanged,
    required this.bd,
  }) : super(key: key);

  @override
  _DropDownSubCategoriasState createState() => _DropDownSubCategoriasState();
}

class _DropDownSubCategoriasState extends State<DropDownSubCategorias> {
  int? _selectedSubCategoria;
  late Future<List<Map<String, dynamic>>> subcategoriasFuture;

  @override
  void initState() {
    super.initState();
    _loadSubcategorias(); 
  }

  @override
  void didUpdateWidget(covariant DropDownSubCategorias oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoriaSelecionada != oldWidget.categoriaSelecionada) {
      _selectedSubCategoria = null; // Reset da subcategoria
      _loadSubcategorias(); 
    }
  }

  void _loadSubcategorias() {
    setState(() {
      subcategoriasFuture =
          widget.bd.mostrarSubCategorias(widget.categoriaSelecionada);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: subcategoriasFuture,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("A carregar Sub-Categorias");
        } else if (snapshot.hasError) {
          return Text('Erro ao carregar sub-categorias: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('Nenhuma sub-categoria encontrada para esta categoria');
        } else {
          List<Map<String, dynamic>> subCategorias = snapshot.data!;
          List<DropdownMenuItem<int>> dropdownItems =
              subCategorias.map((subCategoria) {
            return DropdownMenuItem<int>(
              value: subCategoria['IDSUBCATEGORIA'],
              child: Text(subCategoria['NOME']),
            );
          }).toList();

          // Verifica se a subcategoria selecionada é válida na nova lista
          if (_selectedSubCategoria != null &&
              !dropdownItems
                  .any((item) => item.value == _selectedSubCategoria)) {
            _selectedSubCategoria =
                null; // Reseta a subcategoria se ela não existir na lista
          }

          return DropdownButtonFormField<int>(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: _selectedSubCategoria,
            items: dropdownItems,
            hint: Text('Sub-Categoria'),
            onChanged: (value) {
              setState(() {
                _selectedSubCategoria = value;
              });
              widget.onChanged(value!);
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor, selecione a sub-categoria';
              }
              return null;
            },
          );
        }
      },
    );
  }
}

class Localizacao {
  Future<Position> determinaposicao() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Os serviços de localização estão desativados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Permissão de localização negada permanentemente, não podemos solicitar permissões.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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
