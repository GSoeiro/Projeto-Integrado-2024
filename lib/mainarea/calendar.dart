import 'package:flutter/material.dart';
import 'package:softshares/services/apiservice.dart';
import 'package:softshares/services/localdb.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  final ApiService api;
  final BaseDeDados bd;

  CalendarPage({super.key, required this.api, required this.bd});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  List<Map<String, dynamic>> eventos = [];

  Future<void> buscarEventos() async {
    List<Map<String, dynamic>> post = await widget.bd.mostrarPosts();
    List<Map<String, dynamic>> postsFinal = [];

    for (var pub in post) {
      if (pub['ESPACO'] == 1) {
        postsFinal.add(pub);
      }
    }

    Map<DateTime, List<Map<String, dynamic>>> eventosPorData = {};
    List<Map<String, dynamic>> _eventos = [];

    for (var evento in postsFinal) {
      var dataEvento = evento['DATAEVENTO'];
      _eventos.add(evento);
      if (dataEvento == null || dataEvento.isEmpty) {
        print('DATAEVENTO está vazio ou nulo: $dataEvento');
        continue;
      }

      DateTime eventoData;
      if (dataEvento is String) {
        try {
          eventoData = DateTime.parse(dataEvento); // Tenta usar o formato padrão ISO 8601
          print('Data no formato ISO 8601: $eventoData');
        } catch (e) {
          try {
            eventoData = DateFormat('dd-MM-yyyy').parse(dataEvento); // Tenta o formato dd-MM-yyyy
          } catch (e) {
            continue; 
          }
        }
      } else if (dataEvento is DateTime) {
        eventoData = dataEvento;
      } else {
        continue;
      }

      // Adiciona o evento no mapa de eventos
      if (!eventosPorData.containsKey(eventoData)) {
        eventosPorData[eventoData] = [];
      }
      eventosPorData[eventoData]!.add(evento);
    }

    setState(() {
      _events = eventosPorData;
      eventos = _eventos;
    });

   
  }

  Widget mostrarCardCalendario(List<Map<String, dynamic>> posts) {
  final ThemeData theme = Theme.of(context);
  if (posts.isEmpty) {
    return Column(
      children: [Text('Não existem eventos para mostrar!')],
    );
  }
  List<Widget> widgets = [];
  for (var evento in posts) {
    widgets.add(
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/publicacoespage', arguments: evento);
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
                evento['TITULO'] ?? 'Não existe título',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                '${evento['NOMECATEGORIA'] ?? 'Não existe categoria'} - ${evento['NOMESUBCATEGORIA'] ?? 'Não existe subcategoria'}',
                style: TextStyle(
                    fontSize: 14, color: theme.disabledColor),
              ),
              SizedBox(height: 5),
              Text(
                'Data do Evento: ${evento['DATAEVENTO'] ?? 'Não existe data'}',
                style: TextStyle(
                    fontSize: 14, color: theme.disabledColor),
              ),
            ],   
          ),
          
        ),
      ),
    );
  }
  return Column(
    children: widgets,
  );
}

  @override
  void initState() {
    super.initState();
    buscarEventos();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Calendário de Eventos'),
    ),
    body: Column(
      children: [
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: (day) {
            return _events[DateTime(day.year, day.month, day.day)] ?? [];
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 5.0,
                    height: 5.0,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: mostrarCardCalendario(eventos),
          ),
        ),
      ],
    ),
  );
}
}
