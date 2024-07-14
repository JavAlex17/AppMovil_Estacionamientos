import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uparking/selecionar_lugar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:intl/intl.dart';

import 'menuh.dart';
import 'seleccionar_lugar_chuyaca.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({Key? key}) : super(key: key);

  @override
  _UsuarioPageState createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  Map<String, dynamic>? _selectedVehicle;
  Map<String, dynamic>? reservaActiva;
  String? reservaActivaId;

  @override
  void initState() {
    super.initState();
    _fetchReservaActiva();
    _fetchUserVehicles();
  }

  Future<void> _fetchReservaActiva() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reservas')
          .where('uid', isEqualTo: user.uid)
          .where('activa', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final reserva = querySnapshot.docs.first;
        setState(() {
          reservaActiva = reserva.data();
          reservaActivaId = reserva.id;
        });
      }
    }
  }

  Future<void> _fetchUserVehicles() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final vehicleDocs = await FirebaseFirestore.instance
          .collection('vehiculos')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (vehicleDocs.docs.isNotEmpty) {
        setState(() {
          _selectedVehicle = vehicleDocs.docs.first.data() as Map<String, dynamic>;
          _selectedVehicle!['vehicleId'] = vehicleDocs.docs.first.id;
        });
      }
    }
  }



  Future<String> _getUserName() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userDoc['name'] as String;
    }
    return 'Nombre Usuario';
  }

  Future<List<Map<String, dynamic>>> _getUserVehicles() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final QuerySnapshot vehicleDocs = await FirebaseFirestore.instance
          .collection('vehiculos')
          .where('userId', isEqualTo: user.uid)
          .get();

      return vehicleDocs.docs.map((doc) {
        Map<String, dynamic> vehicleData = doc.data() as Map<String, dynamic>;
        vehicleData['vehicleId'] = doc.id; // Agregar el ID del documento como 'vehicleId'
        return vehicleData;
      }).toList();
    }
    return [];
  }

  Future<void> _refreshUserVehicles() async {
    setState(() {
      // No es necesario realizar ninguna operación aquí.
      // Simplemente setState() fuerza a FutureBuilder a reconstruirse
      // y volverá a llamar a _getUserVehicles().
    });
  }

  Future<void> _deleteVehicle(String vehicleId) async {
    await FirebaseFirestore.instance.collection('vehiculos').doc(vehicleId).delete();
    _refreshUserVehicles();
  }

  String _getSelectedVehiclePatente() {
    if (_selectedVehicle != null) {
      return _selectedVehicle!['patente'] ?? 'Patente no disponible';
    }
    return 'Patente no seleccionada';
  }

  void _navigateToModifyData(Map<String, dynamic> vehicleData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModificarDatos(
          vehicleData: vehicleData,
          onUpdate: _refreshUserVehicles,
        ),
      ),
    );
    _refreshUserVehicles();
  }

  Future<void> _liberarLugar() async {
    if (reservaActivaId != null && reservaActiva != null) {
      try {
        // Actualiza el estado de la reserva para desactivarla
        await FirebaseFirestore.instance.collection('reservas').doc(reservaActivaId!).update({
          'activa': false,
        });

        // Usa el atributo 'lugar' del documento de reserva activa
        final String lugarId = reservaActiva!['lugar'];
        final String campus = reservaActiva!['campus']; // Obtener el campus de la reserva activa
        if (lugarId.isNotEmpty) {
          // Determinar la colección de lugares según el campus
          String lugaresCollection = campus == 'C' ? 'lugares_chuyaca' : 'lugares_meyer';

          // Actualiza el lugar en la colección correspondiente para marcarlo como disponible
          final lugarDoc = await FirebaseFirestore.instance.collection(lugaresCollection).doc(lugarId).get();
          if (lugarDoc.exists) {
            await FirebaseFirestore.instance.collection(lugaresCollection).doc(lugarId).update({
              'disponible': true,
            });

            setState(() {
              reservaActiva = null;
              reservaActivaId = null;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lugar liberado exitosamente')),
            );
          } else {
            throw 'El documento del lugar no existe en la colección $lugaresCollection';
          }
        } else {
          throw 'El campo lugar no está presente o está vacío en la reserva activa';
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al liberar el lugar: $e')),
        );
        print('Error al liberar el lugar: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay reserva activa para liberar')),
      );
    }
  }


  Future<List<Map<String, dynamic>>> _getUltimasReservasInactivas() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final QuerySnapshot reservaDocs = await FirebaseFirestore.instance
          .collection('reservas')
          .where('uid', isEqualTo: user.uid)
          .where('activa', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      return reservaDocs.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    }
    return [];
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0055B7),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('lib/assets/img/logoulagos.png', height: 35),
          ),
        ],
      ),
      drawer: const MenuHamburguesa(),
      body: RefreshIndicator(
        onRefresh: _refreshUserVehicles,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<String>(
              future: _getUserName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar los datos del usuario'));
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data ?? 'Nombre Usuario',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text('Datos de mi vehículo:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _selectedVehicle != null
                          ? GestureDetector(
                        onTap: () => _navigateToModifyData(_selectedVehicle!),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text('Patente: ${_selectedVehicle!['patente']}', style: const TextStyle(fontSize: 18)),
                                  Text('Color: ${_selectedVehicle!['color']}', style: const TextStyle(fontSize: 18)),
                                  Text('Modelo: ${_selectedVehicle!['modelo']}', style: const TextStyle(fontSize: 18)),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteVehicle(_selectedVehicle!['vehicleId']);
                                setState(() {
                                  _selectedVehicle = null;
                                });
                              },
                            ),
                          ],
                        ),
                      )
                          : const Center(child: Text('No hay vehículo seleccionado.')),
                      const Divider(color: Colors.black),
                      const SizedBox(height: 20),
                      const Text(
                        'Estacionamiento actual:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (reservaActiva != null) ...[
                        Text('Lugar: ${reservaActiva!['lugar']}', style: TextStyle(fontSize: 18)),
                        Text('Campus: ${reservaActiva!['campus']}', style: TextStyle(fontSize: 18)),
                        Text('Hora de entrada: ${reservaActiva!['hora_inicio']}', style: TextStyle(fontSize: 18)),
                        Text('Hora de salida: ${reservaActiva!['hora_fin']}', style: TextStyle(fontSize: 18)),
                      ] else ...[
                        const Text('No hay reservas activas.', style: TextStyle(fontSize: 18)),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: reservaActiva != null ? null : () async {
                              String userName = await _getUserName();
                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                String uid = user.uid;
                                String patente = _getSelectedVehiclePatente(); // Obtener la patente del vehículo seleccionado

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReservaPage(
                                      userName: userName,
                                      uid: uid,
                                      patente: patente, // Pasar la patente a ReservaPage
                                    ),
                                  ),
                                );
                              } else {
                                // Handle case where user is not logged in
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF0055B7),
                            ),
                            child: Text(reservaActiva != null ? 'Reserva activa' : 'Reservar en Meyer'),
                          ),
                          ElevatedButton(
                            onPressed: reservaActiva != null ? null : () async {
                              String userName = await _getUserName();
                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                String uid = user.uid;
                                String patente = _getSelectedVehiclePatente(); // Obtener la patente del vehículo seleccionado

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReservaChuyacaPage(
                                      userName: userName,
                                      uid: uid,
                                      patente: patente, // Pasar la patente a ReservaPage
                                    ),
                                  ),
                                );
                              } else {
                                // Handle case where user is not logged in
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF0055B7),
                            ),
                            child: Text(reservaActiva != null ? 'Reserva activa' : 'Reservar en Chuyaca'),
                          ),
                        ],
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: _liberarLugar,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF0055B7),
                          ),
                          child: const Text('Liberar lugar'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.black),
                      const SizedBox(height: 20),
                      const Text(
                        'Últimas entradas:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _getUltimasReservasInactivas(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(child: Text('Error al cargar las reservas'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No hay reservas recientes.'));
                          } else {
                            final ultimasReservas = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: ultimasReservas.length,
                              itemBuilder: (context, index) {
                                final reserva = ultimasReservas[index];
                                final timestamp = reserva['timestamp'] as Timestamp;
                                final formattedFecha = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
                                final horaInicio = reserva['hora_inicio'] ?? 'Hora desconocida'; // Usar hora_inicio como cadena
                                final lugar = reserva['lugar'] ?? 'Lugar desconocido';
                                final campus = reserva['campus'] ?? 'Campus no registrado';
                                return ListTile(
                                  title: Text('Fecha: $formattedFecha', style: TextStyle(fontSize: 18)),
                                  subtitle: Text('Hora: $horaInicio\nLugar: $lugar\nCampus: $campus', style: TextStyle(fontSize: 16)),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _getUserVehicles(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar los datos'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay vehículos registrados.'));
                  } else {
                    final vehicles = snapshot.data!;
                    return ListView.builder(
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return ListTile(
                          title: Text('Patente: ${vehicle['patente']}'),
                          subtitle: Text('Modelo: ${vehicle['modelo']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteVehicle(vehicle['vehicleId']);
                              Navigator.pop(context);
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _selectedVehicle = vehicle;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }
                },
              );
            },
          );
        },
        backgroundColor: const Color(0xFF0055B7),
        child: const FaIcon(FontAwesomeIcons.car, color: Colors.white),
      ),
    );
  }
}



class ModificarDatos extends StatefulWidget {
  final Map<String, dynamic> vehicleData;
  final Function onUpdate;

  const ModificarDatos({Key? key, required this.vehicleData, required this.onUpdate}) : super(key: key);

  @override
  _ModificarDatosState createState() => _ModificarDatosState();
}

class _ModificarDatosState extends State<ModificarDatos> {
  late TextEditingController patenteController;
  late TextEditingController colorController;
  late TextEditingController modeloController;

  @override
  void initState() {
    super.initState();
    patenteController = TextEditingController(text: widget.vehicleData['patente'] ?? '');
    colorController = TextEditingController(text: widget.vehicleData['color'] ?? '');
    modeloController = TextEditingController(text: widget.vehicleData['modelo'] ?? '');
  }

  @override
  void dispose() {
    patenteController.dispose();
    colorController.dispose();
    modeloController.dispose();
    super.dispose();
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text('Modificar Datos', style: TextStyle(fontSize: 28, color: Color(0xFF000000))),
              const SizedBox(height: 15),
              _buildTextField(controller: patenteController, label: 'Patente'),
              const SizedBox(height: 15),
              _buildTextField(controller: colorController, label: 'Color'),
              const SizedBox(height: 15),
              _buildTextField(controller: modeloController, label: 'Modelo'),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFFFEFEFF),
                        backgroundColor: const Color(0xFFB6ADA4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: const Text('Volver sin Guardar', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 180,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveChanges();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFFFEFEFF),
                        backgroundColor: const Color(0xFF0055B7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: const Text('Guardar', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label}) {
    return Container(
      width: 350,
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _saveChanges() async {
    final String patente = patenteController.text;
    final String color = colorController.text;
    final String modelo = modeloController.text;
    final String vehicleId = widget.vehicleData['vehicleId'];

    try {
      await FirebaseFirestore.instance.collection('vehiculos')
          .doc(vehicleId)
          .update({
        'patente': patente,
        'color': color,
        'modelo': modelo,
      });

      // Llamar a la función de actualización pasada desde UsuarioPage
      widget.onUpdate();

      Navigator.pop(context);
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Error al actualizar los datos. Inténtalo de nuevo más tarde.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
