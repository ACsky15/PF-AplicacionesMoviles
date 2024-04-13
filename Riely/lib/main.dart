import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Para formateo de fechas

void main() {
  runApp(const MediReminderApp());
}

class MediReminderApp extends StatelessWidget {
  const MediReminderApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediReminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
          background: const Color.fromRGBO(164, 202, 232, 1),
        ),
      ),
      home: const MediReminderHomePage(),
    );
  }
}

class MediReminderHomePage extends StatefulWidget {
  const MediReminderHomePage({Key? key});

  @override
  _MediReminderHomePageState createState() => _MediReminderHomePageState();
}

class _MediReminderHomePageState extends State<MediReminderHomePage> {
  List<Map<String, dynamic>> medications = [];
  bool isMedicationVisible = false; // Variable para controlar la visibilidad del contenedor de medicación
  Map<String, dynamic>? selectedMedication; // Variable para almacenar los detalles de la medicación seleccionada

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final medicationsData = prefs.getString('medications');
    if (medicationsData != null) {
      setState(() {
        medications = json.decode(medicationsData) as List<Map<String, dynamic>>;
      });
    }
  }

  void _saveMedications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('medications', json.encode(medications));
  }

  void addMedication(Map<String, dynamic> medicationDetails) {
    setState(() {
      medications.add(medicationDetails);
      _saveMedications(); // Guardar medicación al añadir
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediReminder'),
        leading: Image.asset(
          'assets/Logo.ico',
          width: 40,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7), // Contenedor blanco con transparencia
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.watch, size: 40), // Icono de reloj
                            const SizedBox(height: 10),
                            StreamBuilder<DateTime>(
                              stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final now = snapshot.data!;
                                  return Column(
                                    children: [
                                      Text(
                                        DateFormat('hh:mm a').format(now), // Formato de hora AM/PM
                                        style: const TextStyle(fontSize: 36),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        DateFormat('HH:mm').format(now), // Hora digital (formato militar)
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ],
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Botón para agregar medicación
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddMedicationScreen(addMedication)),
                    );
                  },
                  child: const Text('Agregar Medicación'),
                ),
                const SizedBox(height: 20),
                // Widget del Calendario
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // Color blanco con transparencia
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const CalendarWidget(),
                ),
                const SizedBox(height: 20),
                if (isMedicationVisible && selectedMedication != null) // Mostrar el contenedor de medicación si es visible y hay una medicación seleccionada
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7), // Color blanco con transparencia
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Medicación Seleccionada:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Text('Nombre: ${selectedMedication!['medicationName']}'),
                        Text('Dosis: ${selectedMedication!['dosage']}'),
                        Text('Horario: ${selectedMedication!['schedule']}'),
                        Text('Días: ${selectedMedication!['days']}'),
                        Text('Duración: ${selectedMedication!['duration']}'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Medicaciones:',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          if (medications.isEmpty)
                            const Text('No hay medicaciones agregadas.')
                          else
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: medications.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(medications[index]['medicationName']),
                                    subtitle: Text('Dosis: ${medications[index]['dosage']}, Horario: ${medications[index]['schedule']}, Días: ${medications[index]['days']}, Duración: ${medications[index]['duration']}'),
                                    onTap: () {
                                      setState(() {
                                        selectedMedication = medications[index]; // Establecer la medicación seleccionada
                                        isMedicationVisible = true; // Mostrar el contenedor de medicación al seleccionar una medicación
                                      });
                                      Navigator.pop(context); // Cerrar el modal de medicaciones
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Icon(Icons.notifications),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key});

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      calendarFormat: _calendarFormat,
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
    );
  }
}

class AddMedicationScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const AddMedicationScreen(this.onSave, {Key? key});

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  String medicationName = '';
  String dosage = '';
  String schedule = '';
  String days = '';
  String duration = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Medicación'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre de la Medicación'),
              onChanged: (value) {
                setState(() {
                  medicationName = value;
                });
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Dosis'),
              onChanged: (value) {
                setState(() {
                  dosage = value;
                });
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Horario'),
              onChanged: (value) {
                setState(() {
                  schedule = value;
                });
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Días'),
              onChanged: (value) {
                setState(() {
                  days = value;
                });
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Duración'),
              onChanged: (value) {
                setState(() {
                  duration = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> medicationDetails = {
                  'medicationName': medicationName,
                  'dosage': dosage,
                  'schedule': schedule,
                  'days': days,
                  'duration': duration,
                };

                widget.onSave(medicationDetails);

                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
