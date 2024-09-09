import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:softshares/other/translations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:softshares/services/apiservice.dart';
import 'package:url_launcher/url_launcher.dart';

class MyImageWidget extends StatelessWidget {
  final Map<String, dynamic> post;

  MyImageWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    return Image.file(File(post['IMAGEM']));
  }
}

class PostDetailsPage extends StatefulWidget {
  final ApiService api;
  final Map<String, dynamic> event;
  PostDetailsPage({required this.api, required this.event});
  @override
  State<PostDetailsPage> createState() => PostDetailsPageState();
}

class PostDetailsPageState extends State<PostDetailsPage> {
  List<Map<String, dynamic>> listaopcoes = [];
  List<Map<String, dynamic>> listavotos = [];
  int avaliacaoEstrelas = 0;
  int comentarioCriado = 0;
  int rating = 0;
  TextEditingController comentarController = TextEditingController();
  TextEditingController textoDenunciarController = TextEditingController();

  bool atualizar = true;

  void _update() {
    setState(() {
      atualizar = false;
    });
  }

  void _shareAppInfo() {
    Share.share(
      'Aplicação SoftShares!',
      subject: 'PINT-2024',
    );
  }

  void _openGoogleMaps(String coordenadas) async {
    final String url =
        'https://www.google.com/maps/search/?api=1&query=$coordenadas';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o Google Maps com as coordenadas fornecidas.';
    }
  }

 

  Future<void> _launchWebsite(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o URL: $url';
    }
  }

  List<Widget> _buildVotingOptions(
      List<dynamic> listaopcoes, List<dynamic> listavotos) {
    int totalVotos = 0;
    int jaVotou = 0;

    for (var opcao in listaopcoes) {
      for (var voto in listavotos) {
        if (voto['IDOPCOESESCOLHA'] == opcao['IDOPCAO']) {
          totalVotos++;
        }
      }
    }
    return listaopcoes.map((opcao) {
      int votosPorOpcao = listavotos
          .where((voto) => voto['IDOPCOESESCOLHA'] == opcao['IDOPCAO'])
          .length;
      double percentagem = totalVotos > 0 ? (votosPorOpcao / totalVotos) : 0.0;

      for (var opcao in listaopcoes) {
        for (var voto in listavotos) {
          if (voto['IDOPCOESESCOLHA'] == opcao['IDOPCAO'] &&
              voto['IDCOLABORADOR'] == widget.api.IDCOLABORADOR) {
            jaVotou = 1;
          }
        }
      }
      if (jaVotou == 1) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(opcao['NOME'] ?? 'Opção desconhecida'),
            LinearProgressIndicator(
              value: percentagem,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 15,
            ),
            SizedBox(height: 10),
          ],
        );
      } else {
        return GestureDetector(
          onTap: () async {
            widget.api.votar(opcao['IDOPCAO']);
            _update();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(opcao['NOME'] ?? 'Opção desconhecida'),
              LinearProgressIndicator(
                value: percentagem,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: 15,
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      }
    }).toList();
  }

  Widget build(BuildContext context) {
    final Map<String, dynamic> post = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final ThemeData theme = Theme.of(context);

    Uint8List imageBytes;
    List<Widget> children = [];

    try {
      widget.api.views(post['IDPUBLICACAO'], post['VIEWS']);
      try {
        imageBytes = post['IMAGEM'] != null && post['IMAGEM'].isNotEmpty
            ? base64Decode(post['IMAGEM'])
            : Uint8List(0);
      } catch (e) {
        print('Error decoding image: $e');
        imageBytes = Uint8List(0);
      }

      if (post['EVENTO'] == 1) {
        //Evento é espaço
        children = [
          Text(
            '${post['NOMECATEGORIA'] ?? 'Não existe categoria'} - ${post['NOMESUBCATEGORIA'] ?? 'Não existe subcategoria'}',
            style: TextStyle(fontSize: 18, color: theme.disabledColor),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              if (post['WEBSITE'] != null && post['WEBSITE']!.isNotEmpty) {
                print(post['WEBSITE']);
                _launchWebsite(post['WEBSITE']!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Nenhum website disponível')),
                );
              }
            },
            child: Text(
              'Website: ${post['WEBSITE'] ?? 'Não existe website'}',
              style: TextStyle(
                fontSize: 16,
                color: theme.disabledColor,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Avaliação: ${post['RATING'] ?? 'Não existe rating'} - Visualizações: ${post['VIEWS'] ?? 'Não existe rating'}',
            style: TextStyle(fontSize: 16, color: theme.disabledColor),
          ),
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text(
              'Publicado por: ${post['NOMECOLABORADOR'] ?? 'Não existe nome'}',
              style: TextStyle(fontSize: 15, color: theme.disabledColor),
            )
          ]),
          SizedBox(height: 10),
          post['IMAGEM'] != 'semimagem'
              ? MyImageWidget(post: post)
              : SizedBox(height: 10),
          SizedBox(height: 10),
          Text(
            post['TEXTO'] ?? 'Não existe descrição',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          _criarComentario(post),
          SizedBox(height: 20),
          FutureBuilder<List<dynamic>>(
            future: downloadComentariosPublicacoes(post),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: [Text("A carregar!")],
                );
              } else if (snapshot.hasError) {
                return Column(
                  children: [Text("Erro nos comentrários!")],
                );
              } else if (snapshot.hasData) {
                var listaComentarios = snapshot.data ?? [];
                return Column(
                  children: _buildComentarios(listaComentarios, post) ,
                );
              } else {
                List<dynamic> comentarios = snapshot.data!;
                return Column(
                  children: _buildComentarios(comentarios, post),
                );
              }
            },
          ),
        ];
      } else if (post['ESPACO'] == 1) {
        return FutureBuilder<List<dynamic>>(
          future: downloadOpcoesEVotos(post),
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(),
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(),
                body: Center(child: Text('Erro: ${snapshot.error}')),
              );
            } else if (snapshot.hasData) {
              var listaopcoes = snapshot.data![0] ?? [];
              var listavotos = snapshot.data![1] ?? [];
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    post['TITULO'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        if (post['COORDENADAS'] != null &&
                            post['COORDENADAS'].isNotEmpty) {
                          try {
                            String coordenadasString =
                                post['COORDENADAS'].trim();
                            _openGoogleMaps(coordenadasString);
                          } catch (e) {
                            // Captura qualquer erro
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Erro ao processar coordenadas: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Nenhuma coordenada disponível')),
                          );
                        }
                      },
                      icon: Icon(Icons.pin_drop_rounded),
                    ),
                    IconButton(
                        onPressed: () {
                          _shareAppInfo();
                        },
                        icon: Icon(Icons.ios_share_rounded)),
                  ],
                ),
                body: ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    Text(
                      '${post['NOMECATEGORIA'] ?? 'Não existe categoria'} - ${post['NOMESUBCATEGORIA'] ?? 'Não existe subcategoria'}',
                      style: TextStyle(
                          fontSize: 18, color: Theme.of(context).disabledColor),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Avaliação: ${post['RATING'] ?? 'Não existe rating'} - Visualizações: ${post['VIEWS'] ?? 'Não existe rating'}',
                      style:
                          TextStyle(fontSize: 16, color: theme.disabledColor),
                    ),
                    SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text(
                        'Publicado por: ${post['NOMECOLABORADOR'] ?? 'Não existe nome'}',
                        style:
                            TextStyle(fontSize: 15, color: theme.disabledColor),
                      ),
                    ]),
                    SizedBox(height: 10),
                    Text(
                      'Data do Evento: ${post['DATAEVENTO'] ?? 'Não é possível mostrar a data'}',
                      style:
                          TextStyle(fontSize: 16, color: theme.disabledColor),
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
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildVotingOptions(listaopcoes, listavotos),
                    ),
                    SizedBox(height: 20),
                    _criarComentario(post),
                    SizedBox(height: 20),
                    FutureBuilder<List<dynamic>>(
                      future: downloadComentariosPublicacoes(post),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<dynamic>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                            children: [Text("A carregar!")],
                          );
                        } else if (snapshot.hasError) {
                          return Column(
                            children: [Text("Erro!")],
                          );
                        } else if (snapshot.hasData) {
                          var listaComentarios = snapshot.data ?? [];
                          return Column(
                            children: _buildComentarios(listaComentarios, post),
                          );
                        } else {
                          return Center(child: Text("Erro!"));
                        }
                      },
                    ),
                  ],
                ),
              );
            } else {
              return Scaffold(
                appBar: AppBar(),
                body: Center(child: Text("Nenhum dado disponível")),
              );
            }
          },
        );
      }
      // Default return for "espaco"
      return Scaffold(
        appBar: AppBar(
          title: Text(
            post['TITULO'],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                // Verifica se as coordenadas estão disponíveis no post
                if (post['COORDENADAS'] != null &&
                    post['COORDENADAS'].isNotEmpty) {
                  try {
                    // Pega as coordenadas diretamente
                    String coordenadasString = post['COORDENADAS'].trim();

                    // Passa a string de coordenadas para a função _openGoogleMaps
                    _openGoogleMaps(coordenadasString);
                  } catch (e) {
                    // Captura qualquer erro
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Erro ao processar coordenadas: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Nenhuma coordenada disponível')),
                  );
                }
              },
              icon: Icon(Icons.pin_drop_rounded),
            ),
            IconButton(
                onPressed: () {
                  _shareAppInfo();
                },
                icon: Icon(Icons.ios_share_rounded)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      );
    } catch (err) {
      throw Exception(err);
    }
  }



  Widget _criarComentario(Map<String, dynamic> post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Translations.translate(context, 'rating'),
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < avaliacaoEstrelas ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 25,
              ),
              onPressed: () {
                setState(() {
                  avaliacaoEstrelas = index + 1;
                });
              },
            );
          }),
        ),
        SizedBox(height: 15),
        Text(Translations.translate(context, 'comments'),
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        TextField(
          controller: comentarController,
          decoration: InputDecoration(
            hintText: Translations.translate(context, 'add_comment'),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () async {
                await widget.api.comentar(post['IDPUBLICACAO'].toString(),
                    avaliacaoEstrelas.toString(), comentarController.text);
                setState(() {
                  comentarioCriado = 0;
                });
                if (1 > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Comentário enviado com sucesso!'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Falha ao enviar o comentário. Tente novamente.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text(Translations.translate(context, 'comment')),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  List<Widget> _buildComentarios(List<dynamic> listaComentarios, Map<String, dynamic> post) {
    return listaComentarios.map((comentario) {
      if (comentario is List && comentario.isNotEmpty) {
        comentario = comentario[0];
      }
      if (comentario is Map<String, dynamic>) {
        if (comentario['APROVADO'] == 1) {
          print(comentario);
          print(comentario['IDCOMENTARIO']);
          print(post);
          print(post['CIDADE']);
          return ComentarioCard(comentario: comentario, cidade: post['CIDADE'], api: widget.api);
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(""),
          );
        }
      } else {
        // Handle unexpected data structure
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Erro ao carregar comentário'),
        );
      }
    }).toList();
  }

  Widget buildCommentsRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < avaliacaoEstrelas ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 25,
          ),
          onPressed: () {
            setState(() {
              avaliacaoEstrelas = index + 1;
            });
          },
        );
      }),
    );
  }

  Future<List<dynamic>> downloadOpcoesEVotos(Map<String, dynamic> post) async {
    List<Map<String, dynamic>> listaopcoes =
        await widget.api.downloadOpcoesEscolha(post['IDQUESTIONARIO']);
    List<Map<String, dynamic>> listavotos = await widget.api.downloadVotos();
    return [listaopcoes, listavotos];
  }

  Future<List<dynamic>> downloadComentariosPublicacoes(Map<String, dynamic> post) async {
    List<dynamic> listaComentarios;
    try {
      listaComentarios = await widget.api.downloadComentarios(post['IDPUBLICACAO']);
    } catch (e) {
      print("Erro ao baixar os comentários: $e");
      return [];
    }
    int count = 0;
    num ratingTotal = 0;
    for (var comentario in listaComentarios) {
      count++;
      ratingTotal += comentario['AVALIACAO'];
    }

    double resultado = (count == 0) ? 0 : ratingTotal / count;
    String resultadoFormatado = resultado.toStringAsFixed(1);
    double resultadoFinal = double.parse(resultadoFormatado);

    try {
      await widget.api.updateRatingPost(post['IDPUBLICACAO'], resultadoFinal);
      print("Rating atualizado com sucesso.");
    } catch (e) {
      print("Erro ao atualizar o rating: $e");
    }
    return listaComentarios;
  }
}


class ComentarioCard extends StatefulWidget {
  final Map<String, dynamic> comentario;
  final int cidade;
  final ApiService api;

  ComentarioCard({required this.comentario, required this.cidade, required this.api});

  @override
  _ComentarioCardState createState() => _ComentarioCardState();
}

class _ComentarioCardState extends State<ComentarioCard> {
  int rating = 0;
  bool hasUpvoted = false;
  bool hasDownvoted = false;
  TextEditingController textoDenunciarController = TextEditingController();

   void _denunciarPopUp(int idcomentario, int cidade) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Motivo da denuncia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                minLines: 1,
                maxLines: 6,
                controller: textoDenunciarController,
                decoration: InputDecoration(
                    hintText: 'Motivo da denuncia'),
                obscureText: false,
              ),
            ],
          ),
          actions: [
            TextButton(
  onPressed: () async {
    try {
      // Chama a função de denúncia
      await widget.api.denunciar(
        idcomentario, 
        textoDenunciarController.text, 
        widget.cidade,
      );
  
      Fluttertoast.showToast(
        msg: "Denúncia realizada com sucesso!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erro ao realizar denúncia. Tente novamente.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  },
  child: const Text("Denunciar"),
),

          ],
        );
      },
    );
  }

    List<Widget> buildRatingStars(int rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      stars.add(
        Icon(
          i <= rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16.0,
        ),
      );
    }
    return stars;
  }

  @override
  void initState() {
    super.initState();
    print(widget.comentario['AVALIACAO']);
    rating = widget.comentario['AVALIACAO'] ?? 0;
    print(rating);
    print("Cenas");
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comentario['APROVADO'] != 1) {
      return SizedBox.shrink();
    }

  return Card(
  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.comentario['NOMECOLABORADOR'] ?? 'Erro',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Row(
              children: [
                Text(
                  widget.comentario['DATACOMENTARIO'] ?? 'Erro',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _denunciarPopUp(widget.comentario['IDCOMENTARIO'], widget.cidade);
                  },
                  icon: Icon(Icons.flag, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.0),
        // Linha com o texto à esquerda e a avaliação à direita
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Texto do comentário alinhado à esquerda
            if (widget.comentario['TEXTO'] != '')
              Expanded(
                child: Text(
                  widget.comentario['TEXTO'] ?? 'Erro',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                  maxLines: 2, // Limita as linhas do texto, se necessário
                  overflow: TextOverflow.ellipsis, // Reticências se o texto for longo
                ),
              ),
            // Estrelas de avaliação alinhadas à direita
            Row(
              children: buildRatingStars(widget.comentario['AVALIACAO']),
            ),
          ],
        ),
        SizedBox(height: 16.0),
        // Seção de upvote e downvote
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () async {
                await widget.api.updateRatingComentario(
                  widget.comentario['IDCOMENTARIO'],
                  widget.comentario['RATING'] + 1,
                );
                setState(() {
                  rating = widget.comentario['RATING'] + 1;
                });
              },
              icon: Icon(Icons.thumb_up, color: Colors.green),
            ),
            Text(widget.comentario['RATING'].toString()), // Mostra o rating corrigido
            SizedBox(width: 16.0),
            IconButton(
              onPressed: () async {
                await widget.api.updateRatingComentario(
                  widget.comentario['IDCOMENTARIO'],
                  widget.comentario['RATING'] - 1,
                );
                setState(() {
                  rating = widget.comentario['RATING'] - 1;
                });
              },
              icon: Icon(Icons.thumb_down, color: Colors.red),
            ),
          ],
        ),
      ],
    ),
  ),
);


  }
}

