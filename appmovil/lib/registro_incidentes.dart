import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistroIncidentes extends StatefulWidget {
  @override
  _RegistroIncidentesState createState() => _RegistroIncidentesState();
}

class _RegistroIncidentesState extends State<RegistroIncidentes> {
  Future<List<Map<String, dynamic>>> _getIncidentes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'Usuario no autenticado';
      }

      // Obtener las patentes del usuario desde la colección vehiculos
      final vehiculosQuery = await FirebaseFirestore.instance
          .collection('vehiculos')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Extraer las patentes del resultado de la consulta
      final List<String> patentes = vehiculosQuery.docs.map((doc) => doc['patente'] as String).toList();

      debugPrint('Patentes obtenidas: $patentes');

      if (patentes.isEmpty) {
        // Si no hay patentes, devolver una lista vacía
        return [];
      }

      // Consultar incidentes filtrando por las patentes del usuario en ambas colecciones
      final meyerDocsQuery = await FirebaseFirestore.instance
          .collection('incidentes_meyer')
          .where('patente', whereIn: patentes)
          .get();

      final chuyacaDocsQuery = await FirebaseFirestore.instance
          .collection('incidentes_chuyaca')
          .where('patente', whereIn: patentes)
          .get();

      // Mapear los documentos a una lista de mapas
      List<Map<String, dynamic>> incidentes = [];
      incidentes.addAll(meyerDocsQuery.docs.map((doc) => doc.data() as Map<String, dynamic>));
      incidentes.addAll(chuyacaDocsQuery.docs.map((doc) => doc.data() as Map<String, dynamic>));

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
                SizedBox(height: 5.0),
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
                  return Center(child: Text('Error al cargar los incidentes: ${snapshot.error}'));
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
                            Text(
                              'Fecha: $formattedFecha\nMotivo: $motivo\nPatente: $patente\nLugar: $lugar',
                              style: TextStyle(fontSize: 16),
                            ),
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
