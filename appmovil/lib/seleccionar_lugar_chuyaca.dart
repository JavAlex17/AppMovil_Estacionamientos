import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uparking/user.dart';

import 'mapa_chuyaca.dart';

class ReservaChuyacaPage extends StatefulWidget {
  final String userName;
  final String uid;
  final String patente;

  const ReservaChuyacaPage({super.key, required this.userName, required this.uid, required this.patente});


  @override
  _ReservaChuyacaPageState createState() => _ReservaChuyacaPageState();
}

class _ReservaChuyacaPageState extends State<ReservaChuyacaPage> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Map<int, bool> disponibilidadLugares = {};
  int? lugarSeleccionado; // Variable para mantener el lugar seleccionado

  @override
  void initState() {
    super.initState();
    _createLugaresSiNoExisten();
    _fetchDisponibilidadLugares();
  }

  Future<void> _createLugaresSiNoExisten() async {
    CollectionReference lugares = FirebaseFirestore.instance.collection('lugares_chuyaca');

    for (int i = 1; i <= 87; i++) {  // Cambiado el inicio de 1
      String lugarId = i.toString();
      DocumentReference docRef = lugares.doc(lugarId);
      DocumentSnapshot docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        await docRef.set({'disponible': true}); // Por defecto, lugar disponible
      }
    }
  }

  Future<void> _fetchDisponibilidadLugares() async {
    FirebaseFirestore.instance.collection('lugares_chuyaca').get().then((querySnapshot) {
      Map<int, bool> fetchedDisponibilidad = {};
      for (var doc in querySnapshot.docs) {
        int lugarId = int.parse(doc.id); // Asumiendo que el ID del documento es el número del lugar
        bool disponible = doc['disponible'] as bool;
        fetchedDisponibilidad[lugarId] = disponible;
      }
      setState(() {
        disponibilidadLugares = fetchedDisponibilidad;
      });
    });
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      if (isStartTime) {
        if (_endTime != null && !_isStartTimeValid(picked, _endTime!)) {
          _showInvalidTimeDialog(context,
              'La hora de inicio debe ser menor que la hora de fin y debe haber al menos 5 minutos de diferencia.');
        } else {
          setState(() {
            _startTime = picked;
          });
        }
      } else {
        if (_startTime != null && !_isEndTimeValid(_startTime!, picked)) {
          _showInvalidTimeDialog(context,
              'La hora de fin debe ser mayor que la hora de inicio y debe haber al menos 5 minutos de diferencia.');
        } else {
          setState(() {
            _endTime = picked;
          });
        }
      }
    }
  }

  bool _isStartTimeValid(TimeOfDay start, TimeOfDay end) {
    return (start.hour < end.hour) ||
        (start.hour == end.hour && start.minute + 5 <= end.minute);
  }

  bool _isEndTimeValid(TimeOfDay start, TimeOfDay end) {
    return (end.hour > start.hour) ||
        (end.hour == start.hour && end.minute >= start.minute + 5);
  }

  void _showInvalidTimeDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hora inválida'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _toggleSeleccion(int lugarIndex) {
    setState(() {
      if (lugarSeleccionado == lugarIndex) {
        lugarSeleccionado = null; // Deselecciona el lugar si ya estaba seleccionado
      } else {
        lugarSeleccionado = lugarIndex; // Selecciona el nuevo lugar
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0055B7),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('lib/assets/img/logoulagos.png', height: 35),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text('Selección de lugar',
                  style: TextStyle(fontSize: 28, color: Color(0xFF000000))),
              const SizedBox(height: 15),
              _buildTiempoReserva(context), // Selector de tiempo de reserva
              const SizedBox(height: 30),
              const Text('Mapa',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              _buildMapaLugaresContainer(), // Mapa interactivo de lugares
              const SizedBox(height: 30),
              _buildLegenda(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Lógica para reservar el lugar
                  if (_startTime == null || _endTime == null) {
                    _showInvalidTimeDialog(context,
                        'Por favor, seleccione ambas horas de inicio y fin.');
                  } else if (!_isStartTimeValid(_startTime!, _endTime!)) {
                    _showInvalidTimeDialog(context,
                        'La hora de inicio debe ser menor que la hora de fin y debe haber al menos 5 minutos de diferencia.');
                  } else {
                    _realizarReserva(); // Método para realizar la reserva
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFFFEFEFF),
                  backgroundColor: const Color(0xFF0055B7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                child: const Text('Reservar', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTiempoReserva(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tiempo de reserva:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _selectTime(context, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(
                    _startTime != null ? _startTime!.format(context) : '00:00',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text('-', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _selectTime(context, false),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(
                    _endTime != null ? _endTime!.format(context) : '00:00',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapaLugaresContainer() {
    return Container(
      height: 250,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: MapaChuyaca(
          disponibilidadLugares: disponibilidadLugares,
          lugarSeleccionado: lugarSeleccionado,
          onToggleSeleccion: _toggleSeleccion,
        ),
      ),
    );
  }




  Widget _buildLegenda() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendaItem('Disponible', Colors.grey),
        const SizedBox(width: 20),
        _buildLegendaItem('Seleccionado', Colors.green),
        const SizedBox(width: 20),
        _buildLegendaItem('Ocupado', Colors.red),
      ],
    );
  }

  Widget _buildLegendaItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }

  void _realizarReserva() {
    // Obtenemos el lugar seleccionado
    if (lugarSeleccionado != null) {
      String lugarId = (lugarSeleccionado! + 1).toString(); // ID del lugar seleccionado, ajustado para comenzar desde 1

      // Guardamos la reserva en Firestore
      FirebaseFirestore.instance.collection('reservas').add({
        'usuario': widget.userName,
        'uid': widget.uid,
        'patente': widget.patente,
        'lugar': lugarId,
        'campus': 'C',
        'hora_inicio': '${_startTime!.hour}:${_startTime!.minute}',
        'hora_fin': '${_endTime!.hour}:${_endTime!.minute}',
        'activa': true,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((reservaRef) {
        // Reserva creada exitosamente
        // Actualizamos la disponibilidad del lugar a ocupado (false)
        FirebaseFirestore.instance.collection('lugares_chuyaca').doc(lugarId).update({
          'disponible': false,
        }).then((value) {
          // Mostramos mensaje de reserva exitosa
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Reserva exitosa'),
                content: const Text('Su reserva ha sido realizada correctamente.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UsuarioPage(), // Página de usuario
                        ),
                      );
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              );
            },
          );
        }).catchError((error) {
          // Error al actualizar la disponibilidad
          _showErrorDialog('Error al actualizar la disponibilidad del lugar.');
        });
      }).catchError((error) {
        // Error al crear la reserva
        _showErrorDialog('Error al realizar la reserva. Por favor, inténtelo nuevamente.');
      });
    } else {
      // No se ha seleccionado un lugar
      _showErrorDialog('Por favor, seleccione un lugar antes de continuar.');
    }
  }




  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error en la reserva'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }

}

