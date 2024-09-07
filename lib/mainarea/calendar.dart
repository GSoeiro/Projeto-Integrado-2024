import 'package:flutter/material.dart';
import 'package:softshares/backend/apiservice.dart';
import 'package:softshares/backend/localdb.dart';
import 'package:table_calendar/table_calendar.dart';

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

  Map<DateTime, List<Map<String, dynamic>>> _events =
      {}; // Armazenar eventos por data

  // Função para buscar eventos e mapear para datas
  Future<void> buscarEventos() async {
    List<Map<String, dynamic>> post =
        await widget.bd.mostrarPosts(widget.api.cidade);
    List<Map<String, dynamic>> postsFinal = [];

    for (var pub in post) {
      if (pub['ESPACO'] == 1) {
        postsFinal.add(pub);
      }
    }

    Map<DateTime, List<Map<String, dynamic>>> eventosPorData = {};

    // Iterar sobre os posts e organizar no mapa de eventos
    for (var evento in postsFinal) {
      print(evento);
      var dataEvento = evento['DATAEVENTO'];
      print(evento['DATAEVENTO']); // Aqui assumimos que já é um DateTime

      if (dataEvento is DateTime) {
        if (eventosPorData[dataEvento] == null) {
          eventosPorData[dataEvento] = [];
        }

        eventosPorData[dataEvento]!.add(evento);
      } else {
        print('Tipo de dado inválido para DATAEVENTO: $dataEvento');
        continue; // Pule este evento se o tipo de dado for inválido
      }
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
          // Função para carregar eventos para um dia específico
          eventLoader: (day) {
            return _events[day] ?? [];
          },
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
