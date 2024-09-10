import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softshares/services/localdb.dart';
import 'package:softshares/other/translations.dart';
import '../services/apiservice.dart';

class Eventcreationpage extends StatefulWidget {
  final ApiService api;
  final BaseDeDados bd;

  Eventcreationpage({Key? key, required this.api, required this.bd})
      : super(key: key);

  @override
  _EventcreationpageState createState() => _EventcreationpageState();
}

class _EventcreationpageState extends State<Eventcreationpage> {
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _subcategoriaController = TextEditingController();
  List<FormItem> formItems = List.generate(2, (index) => FormItem()); 
  String cidadeColaborador = '';
  String? imagem;
  File? _image;
  Uint8List? imageBytes;
  final picker = ImagePicker();

  int? _selectedCategoria;
  int? _selectedSubCategoria;
  int? _selectedCidade;
  DateTime? _selectedDate;

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




  Future<void> _loadCidadeColaborador() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cidadeColaborador = prefs.getString('cidade') ?? '';
    });
  }


  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    DateTime initialDate = _selectedDate ?? now;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

 Future<void> _criarEvento() async {
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
  String categoria = _selectedCategoria.toString();
  String subcategoria = _selectedSubCategoria.toString();
  String dataevento = DateFormat('dd-MM-yyyy').format(_selectedDate!);
  List<String> opcoes = formItems.map((item) => item.content).toList();

  DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(dataevento);
  
  try {
    await widget.api.criarEvento(cidade, titulo, descricao, categoria, subcategoria, imageBytes, opcoes, parsedDate);
    

    Fluttertoast.showToast(
      msg: "Evento criado com sucesso!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0
    );

    // Navega de volta para a página principal
    Navigator.pushReplacementNamed(context, '/mainpage');
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Erro ao criar o evento.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
    );
    print('Erro ao criar evento: $e');
  }
}


  Widget buildDynamicRow(int index) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              Translations.translate(context, 'option${index + 1}'),
              style: TextStyle(fontSize: 18),
              maxLines: 2,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: Translations.translate(context, 'option'),
                  ),
                  onChanged: (value) {
                    setState(() {
                      formItems[index].content =
                          value; // Corrige o acesso ao item na lista
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo não pode estar vazio';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12),
              if (formItems.length > 2)
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      if (formItems.length > 2) formItems.removeAt(index);
                    });
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              const IconThemeData(color: Color.fromRGBO(0, 179, 255, 1.0)),
          title: Text(Translations.translate(context, 'create_event'),
              style: TextStyle(
                  color: Color.fromRGBO(0, 179, 255, 1.0), fontSize: 20.0)),
          actions: [
            TextButton(
              onPressed: _criarEvento,
              child: Text(Translations.translate(context, 'create'),
                  style: TextStyle(
                      color: Color.fromRGBO(0, 179, 255, 1.0), fontSize: 20.0)),
            )
          ],
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    padding: EdgeInsets.only(right: 8.0),
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
                      hintText: Translations.translate(context, 'insert_title'),
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
                            context, 'insert_description')),
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
                      Translations.translate(context, 'image'),
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
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _image != null
                          ? Image.file(_image!, fit: BoxFit.cover)
                          : Center(
                              child: Text(
                                Translations.translate(context, 'insert_image'),
                              ),
                            ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 30),
            Row(children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    Translations.translate(context, 'date'),
                    style: TextStyle(fontSize: 18),
                    maxLines: 1,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedDate == null
                        ? Text(Translations.translate(context, 'selected_date'))
                        : Text(DateFormat('dd-MM-yyyy').format(_selectedDate!)),
                  ),
                ),
              ),
            ]),
            SizedBox(height: screenSize.height * 0.03),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: formItems.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    if (index > 0)
                      SizedBox(
                          height: screenSize.height *
                              0.02), // Add spacing between dynamic items
                    buildDynamicRow(index),
                  ],
                );
              },
            ),
            SizedBox(height: screenSize.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      formItems.add(FormItem());
                    });
                  },
                ),
              ],
            ),
          ]),
        )));
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
            hint: Text(
              Translations.translate(context, 'category'),
            ),
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
  final int categoriaSelecionada; // Use this to fetch subcategories
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
    _loadSubcategorias(); // Load subcategories when widget is initialized
  }

  @override
  void didUpdateWidget(covariant DropDownSubCategorias oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoriaSelecionada != oldWidget.categoriaSelecionada) {
      _selectedSubCategoria = null; // Reset selected subcategoria
      _loadSubcategorias(); // Reload subcategories when category changes
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
            hint: Text(
              Translations.translate(context, 'subcategory'),
            ),
            onChanged: (value) {
              setState(() {
                _selectedSubCategoria = value;
              });
              widget.onChanged(value!); // Notify parent widget
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

class FormItem {
  String title = '';
  String content = '';
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
