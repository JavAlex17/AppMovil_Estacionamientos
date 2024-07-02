import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReservaPage extends StatefulWidget {
  final String userName;
  final String uid;
  final String patente;

  const ReservaPage({super.key, required this.userName, required this.uid, required this.patente});


  @override
  _ReservaPageState createState() => _ReservaPageState();
}

class _ReservaPageState extends State<ReservaPage> {
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
    CollectionReference lugares = FirebaseFirestore.instance.collection('lugares_meyer');

    for (int i = 1; i <= 28; i++) {  // Cambiado el inicio de 1
      String lugarId = i.toString();
      DocumentReference docRef = lugares.doc(lugarId);
      DocumentSnapshot docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        await docRef.set({'disponible': true}); // Por defecto, lugar disponible
      }
    }
  }

  Future<void> _fetchDisponibilidadLugares() async {
    FirebaseFirestore.instance.collection('lugares_meyer').get().then((querySnapshot) {
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
      height: 250, // Altura deseada del contenedor
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: _buildMapaLugares(),
      ),
    );
  }

  Widget _buildMapaLugares() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente la columna de filas de lugares
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilaLugares(0, 6),
                _buildFilaLugaresConPreferencial(6, 1),
                const SizedBox(width: 20),
                // Espacio entre la primera fila y "Entrada"
                const Text('Entrada', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 20),
                _buildFilaLugaresConPreferencial(7, 1),
                _buildFilaLugares(8, 6),
              ],
            ),
            const SizedBox(height: 20), // Espacio entre filas de lugares
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilaLugares(14, 7),
                const SizedBox(width: 100), // Espacio entre los lugares 21 y 22
                _buildFilaLugares(21, 7),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilaLugares(int startIndex, int count) {
    List<Widget> lugares = [];
    for (int i = startIndex; i < startIndex + count; i++) {
      lugares.add(
        GestureDetector(
          onTap: () => _toggleSeleccion(i),
          child: Container(
            margin: const EdgeInsets.all(5),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: _getLugarColor(i),
            ),
            child: Center(
              child: Text(
                (i + 1).toString(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Row(children: lugares);
  }

  Widget _buildFilaLugaresConPreferencial(int startIndex, int count) {
    List<Widget> lugares = [];
    for (int i = startIndex; i < startIndex + count; i++) {
      lugares.add(
        GestureDetector(
          onTap: () => _toggleSeleccion(i),
          child: Container(
            margin: EdgeInsets.all(5),
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: _getLugarColorPreferencia(i),
            ),
            child: const Center(
              child: Icon(
                Icons.accessible,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      );
    }
    return Row(children: lugares);
  }

  Color _getLugarColor(int lugarIndex) {
    int lugarRealId = lugarIndex + 1;

    if (lugarSeleccionado == lugarRealId - 1) {
      return Colors.green; // Color cuando el lugar está seleccionado
    } else if (disponibilidadLugares.containsKey(lugarRealId) && !disponibilidadLugares[lugarRealId]!) {
      return Colors.red; // Color cuando el lugar no está disponible
    } else {
      return Colors.grey; // Color predeterminado para lugares disponibles pero no seleccionados
    }
  }

  Color _getLugarColorPreferencia(int lugarIndex) {
    if (lugarSeleccionado == lugarIndex) {
      return Colors.green; // Color cuando el lugar está seleccionado
    } else if (disponibilidadLugares.containsKey(lugarIndex) && !disponibilidadLugares[lugarIndex]!) {
      return Colors.red; // Color cuando el lugar no está disponible
    } else {
      return Colors.blue; // Color predeterminado para lugares disponibles pero no seleccionados
    }
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
        'hora_inicio': '${_startTime!.hour}:${_startTime!.minute}',
        'hora_fin': '${_endTime!.hour}:${_endTime!.minute}',
        'timestamp': FieldValue.serverTimestamp(),
      }).then((reservaRef) {
        // Reserva creada exitosamente
        // Actualizamos la disponibilidad del lugar a ocupado (false)
        FirebaseFirestore.instance.collection('lugares_meyer').doc(lugarId).update({
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
                      Navigator.of(context).pop();
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

