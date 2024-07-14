import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RegistroReservasGuardiaPage extends StatefulWidget {
  @override
  _RegistroReservasGuardiaPageState createState() => _RegistroReservasGuardiaPageState();
}

class _RegistroReservasGuardiaPageState extends State<RegistroReservasGuardiaPage> {
  Future<List<Map<String, dynamic>>> _getReservas() async {
    final QuerySnapshot reservaDocs = await FirebaseFirestore.instance
        .collection('reservas')
        .orderBy('timestamp', descending: true)
        .get();

    return reservaDocs.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  String _formatIndex(int index, int total) {
    return '#${(total - index).toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0055B7),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('lib/assets/img/logoulagos.png', height: 35), // Logo a la derecha
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Registros de reservas anteriores',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getReservas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar las reservas'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay reservas registradas.'));
                } else {
                  final reservas = snapshot.data!;
                  final totalReservas = reservas.length;
                  return ListView.separated(
                    itemCount: reservas.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      final reserva = reservas[index];
                      final timestamp = reserva['timestamp'] as Timestamp;
                      final formattedFecha = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
                      final horaInicio = reserva['hora_inicio'] ?? 'Hora desconocida'; // Usar hora_inicio como cadena
                      final horaFin = reserva['hora_fin'] ?? 'Hora desconocida';
                      final lugar = reserva['lugar'] ?? 'Lugar desconocido';
                      final campus = reserva['campus'] ?? 'Campus no registrado';
                      final patente = reserva['patente'] ?? 'Patente desconocida'; // Añadir patente
                      final activa = reserva['activa'] ?? false;
                      return ListTile(
                        title: Text(
                          _formatIndex(index, totalReservas),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Fecha: $formattedFecha\nHora: $horaInicio a $horaFin\nPatente: $patente\nLugar: $lugar\nCampus: $campus\nActiva: ${activa ? "Sí" : "No"}',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}