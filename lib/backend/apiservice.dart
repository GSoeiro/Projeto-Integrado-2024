import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softshares/backend/localdb.dart';
import 'package:sqflite/sqflite.dart';

class ApiService {
  static const String apiUrl =
      'https://pint-backend-8vxk.onrender.com/colaborador/';
  static const String url = 'https://pint-backend-8vxk.onrender.com/';

  BaseDeDados bd = BaseDeDados();
  String token = '';
  String nomeColaborador = '';
  int IDCOLABORADOR = 0;
  int cidade = 0;
  int mudouPassword = 0;
  int IDPUBLICACAO = 0;
  int idcategoria = 0;
  int idsubcategoria = 0;

  //Função para converter DateTime em String (O flutter não permite o uso de DateTime como tipo de variável)
  String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return '';
    DateTime dateTime = DateTime.parse(dateTimeString);
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    return dateFormat.format(dateTime);
  }

  Future<void> createUserOnBackend(
      String email, String password, String nome, int cidade) async {
    String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    var responseVerificar = await http.get(
      Uri.parse(url + 'colaborador/getByEmail/$email'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    Map<String, dynamic> datapost = {
      'EMAIL': email,
      'PASSWORDCOLABORADOR': password,
      'NOME': nome,
      'TELEMOVEL': '0',
      'CIDADE': cidade.toString(),
      'DATANASCIMENTO': '2024-01-01',
      'DATAREGISTO': formattedDate,
      'ULTIMOLOGIN': '2024-01-01',
      'TIPOCONTA': 1,
      'CARGO': 2,
      'ATIVO': 1,
      'MUDOUPASSWORD': 0
    };
    try {
      if (responseVerificar.statusCode == 500) {
        var responseDataVerificar = json.decode(responseVerificar.body);
        if (responseDataVerificar['success'] == false) {
          var response = await http.post(
            Uri.parse(apiUrl + 'create'),
            headers: {"Content-Type": "application/json"},
            body: json.encode(datapost),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Parse the JSON response
            var responseData = json.decode(response.body);

            if (responseData['success'] == true) {
              // Show success message
              Fluttertoast.showToast(
                msg: responseData['message'],
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            } else {
              Fluttertoast.showToast(
                msg: responseData['message'] ?? 'Erro ao criar utilizador',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            }
          } else {
            print('HTTP Error: ${response.statusCode}, ${response.body}');
            Fluttertoast.showToast(
              msg: 'Erro: HTTP ${response.statusCode}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: 'Email já registado!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      }
    } catch (error) {
      print('Error: $error');
      Fluttertoast.showToast(
        msg: 'Erro: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  //Login User on backend, com o datapost
  Future<int> loginUserOnBackend(String email, String password) async {
    Map<String, dynamic> datapost = {
      'email': email,
      'password': password,
    };

    try {
      var response = await http.post(
        Uri.parse(apiUrl + 'login'),
        headers: {
          'Authorization': 'Bearer ESTGV',
          'Content-Type': 'application/json',
        },
        body: json.encode(datapost),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          token = responseData["token"];
          IDCOLABORADOR = responseData["id"];
          cidade = responseData['cidade'];
          mudouPassword = responseData['mudoupassword'];
          nomeColaborador = responseData['nome'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('nomeColaborador', nomeColaborador);
          await prefs.setInt('cidade', cidade);
          await prefs.setInt('mudoupassword', mudouPassword);

          await downloadPosts(cidade);
          return 1;
        } else {
          return 0;
        }
      } else {  
        return 0;
      }
    } catch (error) {
      return 0;
    }
  }

  Future<bool> updatePassword(String novaPassword) async {
    try {
      var response = await http.post(
        Uri.parse(apiUrl + 'updatePassword/$IDCOLABORADOR'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'PASSWORD': novaPassword,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('HTTP Error: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  Future<int> resetPassword(String novaPassword, String email) async {
    try {
      var response = await http.get(
        Uri.parse(url + 'colaborador/getByEmail/$email'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          var id = responseData['data'];
          var response2 = await http.post(
            Uri.parse(apiUrl + 'updatePassword/$id'),
            headers: {
              'Authorization': 'Bearer ESTGV',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'PASSWORD': novaPassword,
            }),
          );
          if (response2.statusCode == 200) {
            var responseData2 = jsonDecode(response2.body);
            if (responseData2["success"] == true) {
              return 1;
            }
          }
        }
      }
    } catch (error) {
      print('Error: $error');
    }
    return 0;
  }

  Future<void> downloadCategorias() async {
    try {
      var response = await http.get(
        Uri.parse(url + 'categoria/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          List<dynamic> categories = responseData['data'];

          for (var categoria in categories) {
            Map<String, dynamic> categorias = {
              'IDCATEGORIA': categoria['IDCATEGORIA'],
              'NOME': categoria['NOME'],
              'DESCRICAO': categoria['DESCRICAO']
            };

            Database db = await bd.basededados;
            var existingCategoria = await db.query(
              'CATEGORIA',
              where: 'IDCATEGORIA = ?',
              whereArgs: [categoria['IDCATEGORIA']],
            );

            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setInt('IDCATEGORIA', idcategoria);

            if (existingCategoria.isEmpty) {
              await bd.insertCategoria(categorias);
            } else {
              await db.update(
                'CATEGORIA',
                categorias,
                where: 'IDCATEGORIA = ?',
                whereArgs: [categoria['IDCATEGORIA']],
              );
            }
          }
        } else {
          throw Exception('Erro ao carregar as categorias');
        }
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erro a transferir as categorias: $error');
    }
  }

  Future<void> downloadSubCategorias({int? subcategoria}) async {
    try {
      var response = await http.get(
        Uri.parse(url + 'subcategoria/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          List<dynamic> subcategories = responseData['data'];
          for (var subcategoria in subcategories) {
            Map<String, dynamic> subcategorias = {
              'IDSUBCATEGORIA': subcategoria['IDSUBCATEGORIA'],
              'NOME': subcategoria['NOME'],
              'DESCRICAO': subcategoria['DESCRICAO'],
              'IDCATEGORIA': subcategoria['IDCATEGORIA']
            };

            Database db = await bd.basededados;
            var existingSubcategory = await db.query(
              'SUBCATEGORIA',
              where: 'IDSUBCATEGORIA = ?',
              whereArgs: [subcategoria['IDSUBCATEGORIA']],
            );

            if (existingSubcategory.isEmpty) {
              await bd.insertSubcategoria(subcategorias);
            } else {
              await db.update(
                'SUBCATEGORIA',
                subcategorias,
                where: 'IDSUBCATEGORIA = ?',
                whereArgs: [subcategoria['IDSUBCATEGORIA']],
              );
            }
          }
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('IDSUBCATEGORIA', idsubcategoria);
        } else {
          throw Exception('Erro ao carregar as subcategorias');
        }
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erro a transferir as subcategorias: $error');
    }
  }

  Future<String> saveImageToFileSystem(Uint8List imageData, String imageName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$imageName';
    final file = File(path);
    await file.writeAsBytes(imageData);
    return path;
  }

Future<void> downloadPosts(int id) async {
  try {
    var response = await http.get(
      Uri.parse(url + 'post/listBlob/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        await bd.apagarPosts();

        for (var post in responseData['data']) {
          List<int> imageData = [];
          Uint8List imageBytes = Uint8List(0);
          String caminho = '${post['COLABORADOR']}post${post['IDPUBLICACAO']}';
          String path;

          if (post['IMAGEM'] != null && post['IMAGEM']['data'] != null) {
            imageData = List<int>.from(post['IMAGEM']['data']);
            imageBytes = Uint8List.fromList(imageData);
            path = await saveImageToFileSystem(imageBytes, caminho);
          } else {
            print("IMAGEM é nula para o post ID ${post['IDPUBLICACAO']}");  
            path ='semimagem'; 
          }

          // Montando o mapa de publicações
          Map<String, dynamic> publicacoes = {
            'IDPUBLICACAO': post['IDPUBLICACAO'],
            'CIDADE': post['CIDADE'],
            'NOMECIDADE': post['cidade']['NOME'],
            'APROVACAO': post['APROVACAO'],
            'COLABORADOR': post['COLABORADOR'],
            'NOMECOLABORADOR': post['colaborador']['NOME'],
            'CATEGORIA': post['CATEGORIA'],
            'NOMECATEGORIA': post['categorium']['NOME'],
            'SUBCATEGORIA': post['SUBCATEGORIA'],
            'NOMESUBCATEGORIA': post['subcategorium']['NOME'],
            'ESPACO': post['ESPACO'],
            'EVENTO': post['EVENTO'],
            'DATAPUBLICACAO': formatDateTime(post['DATAPUBLICACAO']),
            'DATAULTIMAATIVIDADE': formatDateTime(post['DATAULTIMAATIVIDADE']),
            'TITULO': post['TITULO'],
            'TEXTO': post['TEXTO'],
            'RATING': post['RATING'],
            'IMAGEM': path, 
            'IDQUESTIONARIO': post['evento']?['IDQUESTIONARIO'],
            'DATAEVENTO': formatDateTime(post['evento']['DATAEVENTO']),
            'COORDENADAS': post['espaco']?['COORDENADAS'],
            'WEBSITE': post['espaco']?['WEBSITE'],
            'VIEWS': post['VIEWS'],
          };

          if (post['CIDADE'] == cidade && post['aprovacao']['APROVADA'] == 1) {
            await bd.insertPost(publicacoes);
          }
        }
      } else {
        throw Exception('Erro ao carregar os posts');
      }
    } else {
      throw Exception('Erro: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Erro a transferir os posts: $error');
  }
}

  Future<void> dowloadEspaco() async {
    try {
      var response = await http.get(
        Uri.parse(url + 'espaco/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          List<dynamic> spaces = responseData['data'];
          spaces.forEach((space) {
            Map<String, dynamic> espacos = {
              'IDESPACO': space['IDESPACO'],
              'COORDENADAS': space['COORDENADAS'],
              'WEBSITE': space['WEBSITE'],
            };
            bd.insertEspaco(espacos);
          });
        } else {
          throw Exception('Erro ao carregar os post');
        }
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erro a transferir os post: $error');
    }
  }

  Future<void> downloadEventos() async {
    try {
      var response = await http.get(
        Uri.parse(url + 'evento/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          List<dynamic> events = responseData['data'];
          events.forEach((event) {
            Map<String, dynamic> events = {
              'IDEVENTO': event['IDEVENTO'],
              'IDQUESTIONARIO': event['IDQUESTIONARIO'],
              'DATAEVENTO': formatDateTime(event['DATAEVENTO']),
              'ESTADO': event['ESTADO'],
              'PRECO': event['PRECO']
            };
            bd.insertEvento(event);
          });
        } else {
          throw Exception('Erro ao carregar os post');
        }
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erro a transferir os post: $error');
    }
  }

  Future<List<Map<String, dynamic>>> downloadVotos() async {
    try {
      var response = await http.get(
        Uri.parse(url + 'voto/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          List<dynamic> votes = responseData['data'];
          List<Map<String, dynamic>> votosList = [];
          for (var vote in votes) {
            Map<String, dynamic> votos = {
              'IDVOTO': vote['IDVOTO'],
              'IDCOLABORADOR': vote['IDCOLABORADOR'],
              'DATAVOTO': formatDateTime(vote['DATAVOTO']),
              'IDOPCOESESCOLHA': vote['IDOPCOESESCOLHA'],
            };

            // Inserir a opção na base de dados
            await bd.insertVoto(votos);

            // Adicionar a opção à lista de retorno
            votosList.add(votos);
          }

          return votosList;
        } else {
          throw Exception('Erro ao carregar os votos');
        }
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erro a transferir os votos: $error');
    }
  }

  Future<List<Map<String, dynamic>>> downloadOpcoesEscolha(
      int idquestionario) async {
    try {
      var response = await http.get(
        Uri.parse(url + 'opcoes_escolha/listByQuestionario/$idquestionario'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          List<dynamic> options = responseData['data'];
          List<Map<String, dynamic>> opcaoEscolhaList = [];

          for (var option in options) {
            Map<String, dynamic> opcaoEscolha = {
              'IDOPCAO': option['IDOPCAO'],
              'NOME': option['NOME'],
              'TIPOOPCAO': 1,
              'QUESTIONARIO': option['IDQUESTIONARIO'],
            };
            await bd.insertOpcoesEscolha(opcaoEscolha);

            // Adicionar a opção à lista de retorno
            opcaoEscolhaList.add(opcaoEscolha);
          }

          return opcaoEscolhaList;
        } else {
          throw Exception('Erro ao carregar as opções escolha');
        }
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erro ao transferir as opções escolha: $error');
    }
  }

  Future<void> downloadCidades() async {
    try {
      var response = await http.get(
        Uri.parse(url + 'cidade/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData["success"] == true) {
          List<dynamic> cities = responseData['data'];
          for (var cidade in cities) {
            Map<String, dynamic> cidades = {
              'IDCIDADE': cidade['IDCIDADE'],
              'NOME': cidade['NOME'],
            };

            // Check if the city already exists
            Database db = await bd.basededados;
            var existingCidade = await db.query(
              'CIDADE',
              where: 'IDCIDADE = ?',
              whereArgs: [cidade['IDCIDADE']],
            );

            if (existingCidade.isEmpty) {
              await bd.insertCidade(cidades);
            } else {
              await db.update(
                'CIDADE',
                cidades,
                where: 'IDCIDADE = ?',
                whereArgs: [cidade['IDCIDADE']],
              );
            }
          }
        } else {
          throw Exception('Erro ao carregar as cidades');
        }
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erro a transferir as cidades: $error');
    }
  }

  Future<int> views(int id, int views) async {
    try {
      var response = await http.put(
        Uri.parse(url + 'post/view/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'VIEWS': (views + 1).toString(),
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return 1;
      } else {
        print('HTTP Error: ${response.statusCode}, ${response.body}');
        return 0;
      }
    } catch (error) {
      print('Error: $error');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> downloadComentarios(int id) async {
    await bd.apagarComentarios();
    try {
      var response = await http.get(
        Uri.parse(url + 'comentario/listByPost/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          List<dynamic> comments = responseData['data'];
          List<Map<String, dynamic>> comentariosList = [];

          comments.forEach((comment) {
            Map<String, dynamic> comentarios = {
              'IDPOST': comment['IDPOST'],
              'APROVADO': comment['aprovacao']['APROVADA'],
              'IDCOLABORADOR': comment['IDCOLABORADOR'],
              'NOMECOLABORADOR': comment['colaborador'],
              'DATACOMENTARIO': formatDateTime(comment['DATACOMENTARIO']),
              'AVALIACAO': comment['AVALIACAO'],
              'TEXTO': comment['TEXTO'],
            };

            bd.insertComentario(comentarios);

            comentariosList.add(comentarios);
          });

          return comentariosList;
        } else {
          throw Exception('Erro ao carregar os comentarios');
        }
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erro a transferir os comentarios: $error');
    }
  }

  Future<int> updateRatingPost(int idpost, double rating) async {
    try {
      await http.put(
        Uri.parse(url + 'post/updateRating/$idpost'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'RATING': rating}),
      );
    } catch (err) {
      throw new Exception(err);
    }
    return 1;
  }

  Future<int> comentar(String idpost, String avaliacao, String texto) async {
    String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    var response;
    try {
      if (texto == '') {
        response = await http.post(
          Uri.parse(url + 'aprovacao/create'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'IDCOLABORADOR': IDCOLABORADOR,
            'DATAAPROVACAO': formattedDate,
            'APROVADA': 1
          }),
        );
      } else {
        response = await http.post(
          Uri.parse(url + 'aprovacao/create'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'IDCOLABORADOR': IDCOLABORADOR,
            'DATAAPROVACAO': formattedDate,
            'APROVADA': 0
          }),
        );
      }
      if (response.statusCode == 200 || response.statusCode == 204) {
        var responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          var response2 = await http.post(
            Uri.parse(url + 'comentario/create'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'IDPOST': idpost,
              'IDAPROVACAO': responseData['data']['IDAPROVACAO'],
              'IDCOLABORADOR': IDCOLABORADOR,
              'DATACOMENTARIO': formattedDate,
              'AVALIACAO': avaliacao,
              'TEXTO': texto
            }),
          );
          if (response2.statusCode == 200) {
            var responseData2 = json.decode(response2.body);
            if (responseData2['SUCCESS'] == true) {
              return 1;
            }
          }
        }
      } else {
        print('HTTP Error: ${response.statusCode}, ${response.body}');
        return 0;
      }
    } catch (err) {}
    return 1;
  }

  Future<int> votar(int IDOPCOESESCOLHA) async {
    String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    try {
      var response = await http.post(
        Uri.parse(url + 'voto/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'IDCOLABORADOR': IDCOLABORADOR,
          'DATAVOTO': formattedDate,
          'IDOPCOESESCOLHA': IDOPCOESESCOLHA
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return 1;
      } else {
        print('HTTP Error: ${response.statusCode}, ${response.body}');
        return 0;
      }
    } catch (error) {
      print('Error: $error');
      return 0;
    }
  }

Future<void> criarEspaco(String titulo, String descricao, String website, String categoria, String subcategoria, Uint8List? pathimagem) async {
  String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String coordenadas = '';

  final prefs = await SharedPreferences.getInstance();
  double? latitude = prefs.getDouble('selected_latitude');
  double? longitude = prefs.getDouble('selected_longitude');
  coordenadas = latitude.toString() + ' ' + longitude.toString();

  Map<String, dynamic> datapost_espaco = {
    'COORDENADAS': coordenadas,
    'WEBSITE': website,
  };

  try {
    // Fazer pedido de aprovação
    var responseAprovacao = await http.post(
      Uri.parse(url + 'aprovacao/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'IDCOLABORADOR': IDCOLABORADOR.toString(),
        'DATAAPROVACAO': formattedDate,
        'APROVADA': 0
      }),
    );

    print('Resposta Aprovacao: ${responseAprovacao.body}'); // Log da resposta de aprovação

    if (responseAprovacao.statusCode == 200) {
      var responseDataAprovacao = json.decode(responseAprovacao.body);

      if (responseDataAprovacao['success'] == true) {
        // Pedido de criação de espaço
        var responseEspaco = await http.post(
          Uri.parse(url + 'espaco/create'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(datapost_espaco),
        );

        print('Resposta Espaco: ${responseEspaco.body}'); // Log da resposta do espaço

        if (responseEspaco.statusCode == 200) {
          var respondeDataEspaco = json.decode(responseEspaco.body);
          if (respondeDataEspaco['success'] == true) {
            var request = http.MultipartRequest('POST', Uri.parse(url + 'post/create'));
            request.fields['CIDADE'] = cidade.toString();
            request.fields['APROVACAO'] = responseDataAprovacao['data']['IDAPROVACAO'].toString();
            request.fields['COLABORADOR'] = IDCOLABORADOR.toString();
            request.fields['CATEGORIA'] = categoria;
            request.fields['SUBCATEGORIA'] = subcategoria;
            request.fields['ESPACO'] = respondeDataEspaco['data']['IDESPACO'].toString();
            request.fields['EVENTO'] = '1';
            request.fields['DATAPUBLICACAO'] = formattedDate;
            request.fields['DATAULTIMAATIVIDADE'] = formattedDate;
            request.fields['TITULO'] = titulo;
            request.fields['TEXTO'] = descricao;
            request.fields['RATING'] = '0';

            try {
              if (pathimagem != null) {
                request.files.add(http.MultipartFile.fromBytes(
                  'IMAGEM', pathimagem!,
                  filename: 'IMAGEM'
                ));
                print('Imagem anexada com sucesso');
              } else {
                print('Nenhuma imagem fornecida');
              }
            } catch (err) {
              throw Exception("Erro ao inserir a imagem: $err");
            }

            // Enviar o request de criação de post
            var response = await request.send();
            var responseData = await response.stream.bytesToString();
            print('Resposta Post: $responseData'); // Log da resposta do post

            if (response.statusCode == 200) {
              var decodedResponse = json.decode(responseData);
              if (decodedResponse["success"] == true) {
                print('Post criado com sucesso');
              } else {
                print('Falha ao criar o post: ${decodedResponse["message"]}');
              }
            } else {
              print('Erro ao criar espaço1. Código de status: ${response.statusCode}');
            }
          } else {
            print('Falha ao criar espaço: ${respondeDataEspaco["message"]}');
          }
        } else {
          print('Erro ao criar o espaço. Código de status: ${responseEspaco.statusCode}');
        }
      } else {
        print('Falha ao aprovar: ${responseDataAprovacao["message"]}');
      }
    } else {
      print('Erro ao criar a aprovação. Código de status: ${responseAprovacao.statusCode}');
    }
  } catch (error) {
    print('Erro: $error');
  }
}


    Future<void> criarEvento(String titulo, String descricao, String categoria, String subcategoria, Uint8List? pathimagem, List<String> opcoes, String datavento) async {
  String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  try {
    print('Iniciando criação de evento...');

    // Criar questionário
    var responseQuestionario = await http.post(
      Uri.parse(url + 'questionario/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'NOME': titulo}),
    );
    print('Resposta do questionário: ${responseQuestionario.body}');
    if (responseQuestionario.statusCode == 200) {
      var responseQuestionarioData = json.decode(responseQuestionario.body);

      if (responseQuestionarioData['success'] == true) {
        print('Questionário criado com sucesso. ID: ${responseQuestionarioData['data']['IDQUESTIONARIO']}');

        // Criar evento
        var responseEvento = await http.post(
          Uri.parse(url + 'evento/create'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'IDQUESTIONARIO': responseQuestionarioData['data']['IDQUESTIONARIO'],
            'ESTADO': 1,
            'DATAEVENTO': responseQuestionarioData['data']['DATAEVENTO']
          }),
        );
        print('Resposta do evento: ${responseEvento.body}');
        if (responseEvento.statusCode == 200) {
          var responseEventoData = json.decode(responseEvento.body);

          if (responseEventoData['success'] == true) {
            print('Evento criado com sucesso. ID: ${responseEventoData['data']['IDEVENTO']}');

            // Criar opções
            for (var opcao in opcoes) {
              var responseopcao = await http.post(
                Uri.parse(url + 'opcoes_escolha/create'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
                body: json.encode({
                  'NOME': opcao,
                  'TIPOOPCAO': 1,
                  'IDQUESTIONARIO': responseQuestionarioData['data']['IDQUESTIONARIO']
                }),
              );
              print('Resposta da opção: ${responseopcao.body}');
              if (responseopcao.statusCode != 200) {
                print('Erro ao criar opção: ${responseopcao.statusCode}');
              }
            }

            // Criar aprovação
            var responseAprovacao = await http.post(
              Uri.parse(url + 'aprovacao/create'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'IDCOLABORADOR': IDCOLABORADOR.toString(),
                'DATAAPROVACAO': formattedDate,
                'APROVADA': 0
              }),
            );
            print('Resposta da aprovação: ${responseAprovacao.body}');
            if (responseAprovacao.statusCode == 200) {
              var responseAprovacaoData = json.decode(responseAprovacao.body);

              if (responseAprovacaoData['success'] == true) {
                print('Aprovação criada com sucesso. ID: ${responseAprovacaoData['data']['IDAPROVACAO']}');

                // Criar publicação
                var request = http.MultipartRequest('POST', Uri.parse(url + 'post/create'));
                request.fields['CIDADE'] = cidade.toString();
                request.fields['APROVACAO'] = responseAprovacaoData['data']['IDAPROVACAO'].toString();
                request.fields['COLABORADOR'] = IDCOLABORADOR.toString();
                request.fields['CATEGORIA'] = categoria;
                request.fields['SUBCATEGORIA'] = subcategoria;
                request.fields['ESPACO'] = '1';
                request.fields['EVENTO'] = responseEventoData['data']['IDEVENTO'].toString();
                request.fields['DATAPUBLICACAO'] = formattedDate;
                request.fields['DATAULTIMAATIVIDADE'] = formattedDate;
                request.fields['TITULO'] = titulo;
                request.fields['TEXTO'] = descricao;
                request.fields['RATING'] = '0';

                try {
                  if (pathimagem != null) {
                    request.files.add(http.MultipartFile.fromBytes(
                      'IMAGEM', pathimagem,
                      filename: 'IMAGEM',
                    ));
                  }
                } catch (err) {
                  print('Erro ao adicionar imagem: $err');
                  throw new Exception("Erro ao inserir a imagem");
                }

                var response = await request.send();
                var responseData = await response.stream.bytesToString();
                print('Resposta da publicação: $responseData');

                if (response.statusCode == 200) {
                  var decodedResponse = json.decode(responseData);

                  if (decodedResponse["success"] == true) {
                    print('Evento criado com sucesso');
                  } else {
                    print('Erro ao criar evento!');
                  }
                } else {
                  print('Erro ao criar evento! Código: ${response.statusCode}');
                }
              } else {
                print('Erro ao criar aprovação. Código: ${responseAprovacao.statusCode}');
              }
            } else {
              print('Erro ao criar aprovação. Código: ${responseAprovacao.statusCode}');
            }
          } else {
            print('Erro ao criar evento! Código: ${responseEvento.statusCode}');
          }
        } else {
          print('Erro ao criar evento! Código: ${responseEvento.statusCode}');
        }
      } else {
        print('Erro ao criar questionário! Código: ${responseQuestionario.statusCode}');
      }
    } else {
      print('Erro ao criar questionário! Código: ${responseQuestionario.statusCode}');
    }
  } catch (err) {
    print('Erro ao criar a publicação: $err');
    throw new Exception("Erro ao criar a publicação");
  }
}
}