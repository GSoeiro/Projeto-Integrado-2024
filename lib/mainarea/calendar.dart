import 'package:flutter/material.dart';
import 'package:softshares/backend/apiservice.dart';
import 'package:softshares/backend/localdb.dart';
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

  Future<void> buscarEventos() async {
    List<Map<String, dynamic>> post = await widget.bd.mostrarPosts();
    List<Map<String, dynamic>> postsFinal = [];

    for (var pub in post) {
      if (pub['ESPACO'] == 1) {
        postsFinal.add(pub);
      }
    }

    Map<DateTime, List<Map<String, dynamic>>> eventosPorData = {};

for (var evento in postsFinal) {
  var dataEvento = evento['DATAEVENTO'];

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
        print('Data no formato dd-MM-yyyy: $eventoData');
      } catch (e) {
        print('Erro ao converter DATAEVENTO para DateTime: $e');
        continue; // Pula para o próximo evento
      }
    }
  } else if (dataEvento is DateTime) {
    eventoData = dataEvento;
  } else {
    print('Tipo de dado inválido para DATAEVENTO: $dataEvento');
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
    });
  }

  @override
  void initState() {
    super.initState();
    buscarEventos(); // Carregar eventos quando a página for inicializada
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendário de Eventos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              if (_events.containsKey(selectedDay)) {
                Navigator.push(context,MaterialPageRoute(
                    builder: (context) => EventPage(events: _events[selectedDay]!),
                  ),
                );
              }
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: (day) {
            // Usa só o "day" sem horas para comparar datas corretamente
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
      ),
    );
  }
}

class EventPage extends StatelessWidget {
  final List<Map<String, dynamic>> events;

  EventPage({required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos'),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text(event['TITLE'] ?? 'Evento sem título'),
            subtitle: Text(event['DESCRIPTION'] ?? 'Sem descrição'),
          );
        },
      ),
    );
  }
}
