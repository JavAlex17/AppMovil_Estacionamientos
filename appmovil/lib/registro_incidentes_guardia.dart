import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para formateo de fechas


class RegistroGuardiaIncidentes extends StatefulWidget {
  @override
  _RegistroGuardiaIncidentesState createState() => _RegistroGuardiaIncidentesState();
}

class _RegistroGuardiaIncidentesState extends State<RegistroGuardiaIncidentes> {
  Future<List<Map<String, dynamic>>> _getIncidentes() async {
    try {
      // Obtener todos los incidentes de ambas colecciones
      final QuerySnapshot meyerDocs = await FirebaseFirestore.instance.collection('incidentes_meyer').get();
      final QuerySnapshot chuyacaDocs = await FirebaseFirestore.instance.collection('incidentes_chuyaca').get();

      // Mapear los documentos a una lista de mapas
      List<Map<String, dynamic>> incidentes = [];
      incidentes.addAll(meyerDocs.docs.map((doc) => doc.data() as Map<String, dynamic>));
      incidentes.addAll(chuyacaDocs.docs.map((doc) => doc.data() as Map<String, dynamic>));

      // Ordenar por timestamp descendente
      incidentes.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      return incidentes;
    } catch (e) {
      print('Error al cargar los incidentes: $e');
      return [];
    }
  }

  String _formatIndex(int index, int total) {
    return '#${(total - index).toString().padLeft(3, '0')}';
  }

  void _showImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay imagen disponible para este incidente')),
      );
    }
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
            padding: EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registros de incidentes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.0), // Espacio entre el título y el texto adicional
                Text(
                  '(Para ver la imagen presiona sobre el incidente)',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getIncidentes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar los incidentes'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay incidentes registrados.'));
                } else {
                  final incidentes = snapshot.data!;
                  final totalIncidentes = incidentes.length;
                  return ListView.separated(
                    itemCount: incidentes.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      final incidente = incidentes[index];
                      final timestamp = incidente['timestamp'] as Timestamp;
                      final formattedFecha = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
                      final motivo = incidente['motivo'] ?? 'Motivo desconocido';
                      final patente = incidente['patente'] ?? 'Patente desconocida';
                      final lugar = incidente['lugar'] ?? 'Lugar desconocido';
                      final userName = incidente['userName'] ?? 'Usuario no registrado';
                      final userPhone = incidente['userPhone'] ?? 'Teléfono no registrado';
                      final imageUrl = incidente['foto'] ?? '';

                      return ListTile(
                        onTap: () => _showImage(imageUrl),
                        title: Text(
                          _formatIndex(index, totalIncidentes),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha: $formattedFecha\nMotivo: $motivo\nPatente: $patente\nLugar: $lugar',
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 5),
                            Text('Nombre: $userName\nTeléfono: $userPhone', style: TextStyle(fontSize: 16)),
                          ],
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
