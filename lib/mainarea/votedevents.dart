import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:softshares/services/apiservice.dart';
import 'package:softshares/services/localdb.dart';

class VotedEvents extends StatefulWidget {
  final ApiService api;
  final BaseDeDados bd;

  VotedEvents({super.key, required this.api, required this.bd});

  @override
  State<VotedEvents> createState() => _VotedEventsState();
}

class _VotedEventsState extends State<VotedEvents> {
  String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return '';
    DateTime dateTime = DateTime.parse(dateTimeString);
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    return dateFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Eventos Inscrito'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: widget.api.verInscricaoEventos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                            child: Text('Não existem publicações disponíveis')),
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var post = snapshot.data![index];

                      return FutureBuilder<Map<String, dynamic>?>(
                          future: widget.bd.buscarPost(post['IDPUBLICACAO']),
                          builder: (context, postSnapshot) {
                            if (postSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              // Mostra um indicador de carregamento enquanto o post é buscado
                              return Center(child: CircularProgressIndicator());
                            } else if (postSnapshot.hasError) {
                              // Mostra um texto de erro, se houver algum erro ao buscar o post
                              return Center(
                                  child: Text(
                                      'Erro ao carregar post: ${postSnapshot.error}'));
                            } else if (!postSnapshot.hasData ||
                                postSnapshot.data == null) {
                              // Se não houver dados, ou se o post for null
                              return Center(child: Text('Post não encontrado'));
                            } else {
                              // Os dados do post estão disponíveis, renderiza o widget aqui
                              var pub = postSnapshot.data!;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/publicacoespage',
                                      arguments: pub);
                                },
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: theme.dividerColor),
                                    borderRadius: BorderRadius.circular(10),
                                    color: theme.cardColor,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post['TITULO'] ?? 'Não existe título',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '${post['categorium'] != null ? post['categorium']['NOME'] ?? 'Não existe categoria' : 'Não existe categoria'}'
                                        ' - ${post['subcategorium'] != null ? post['subcategorium']['NOME'] ?? 'Não existe subcategoria' : 'Não existe subcategoria'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme.disabledColor,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Data do Evento: ${post['evento'] != null ? post['evento']['DATAEVENTO'] ?? 'Não existe data' : 'Não existe data'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme.disabledColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          });
                    },
                  );
                } else {
                  // Certifica-se de que sempre há um retorno no final
                  return Center(child: Text('Nenhum dado disponível.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
