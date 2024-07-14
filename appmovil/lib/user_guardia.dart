import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'mapa_chuyaca.dart';
import 'mapa_meyer.dart';
import 'menuh.dart';
import 'reportar_incidentes.dart';


class UserGuardiaPage extends StatefulWidget {
  const UserGuardiaPage({Key? key}) : super(key: key);

  @override
  _UserGuardiaPageState createState() => _UserGuardiaPageState();
}

class _UserGuardiaPageState extends State<UserGuardiaPage> {
  late Future<String> userName;
  late Future<Map<String, dynamic>> lastIncident;
  Map<int, bool> disponibilidadMeyer = {};
  Map<int, bool> disponibilidadChuyaca = {};
  int? lugarSeleccionado;

  @override
  void initState() {
    super.initState();
    userName = _getUserName();
    lastIncident = _getLastIncident();
    _fetchDisponibilidadMeyer();
    _fetchDisponibilidadChuyaca();
  }

  Future<void> _refreshData() async {
    userName = _getUserName();
    lastIncident = _getLastIncident();
    await _fetchDisponibilidadMeyer();
    await _fetchDisponibilidadChuyaca();
  }

  Future<String> _getUserName() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userDoc['name'] as String;
    }
    return 'Nombre Guardia';
  }

  Future<Map<String, dynamic>> _getLastIncident() async {
    try {
      // Consultar el último incidente en la colección 'incidentes_meyer'
      final QuerySnapshot meyerDocs = await FirebaseFirestore.instance
          .collection('incidentes_meyer')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      // Consultar el último incidente en la colección 'incidentes_chuyaca'
      final QuerySnapshot chuyacaDocs = await FirebaseFirestore.instance
          .collection('incidentes_chuyaca')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      // Combinar los resultados de ambas consultas
      List<Map<String, dynamic>> allIncidents = [];
      allIncidents.addAll(meyerDocs.docs.map((doc) => doc.data() as Map<String, dynamic>));
      allIncidents.addAll(chuyacaDocs.docs.map((doc) => doc.data() as Map<String, dynamic>));

      // Ordenar por timestamp descendente si hay resultados
      if (allIncidents.isNotEmpty) {
        allIncidents.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        return allIncidents.first;
      }

      // Si no hay resultados, retornar un mapa con un mensaje indicando que no hay incidentes
      return {'description': 'No hay incidentes registrados.'};
    } catch (e) {
      print('Error al obtener el último incidente: $e');
      return {'description': 'Error al obtener el último incidente.'};
    }
  }

  Future<void> _fetchDisponibilidadMeyer() async {
    FirebaseFirestore.instance.collection('lugares_meyer').get().then((querySnapshot) {
      Map<int, bool> fetchedDisponibilidad = {};
      for (var doc in querySnapshot.docs) {
        int lugarId = int.parse(doc.id); // Asumiendo que el ID del documento es el número del lugar
        bool disponible = doc['disponible'] as bool;
        fetchedDisponibilidad[lugarId] = disponible;
      }
      setState(() {
        disponibilidadMeyer = fetchedDisponibilidad;
      });
    });
  }

  Future<void> _fetchDisponibilidadChuyaca() async {
    FirebaseFirestore.instance.collection('lugares_chuyaca').get().then((querySnapshot) {
      Map<int, bool> fetchedDisponibilidad = {};
      for (var doc in querySnapshot.docs) {
        int lugarId = int.parse(doc.id); // Asumiendo que el ID del documento es el número del lugar
        bool disponible = doc['disponible'] as bool;
        fetchedDisponibilidad[lugarId] = disponible;
      }
      setState(() {
        disponibilidadChuyaca = fetchedDisponibilidad;
      });
    });
  }

  void _toggleSeleccion(int lugarIndex) {
    setState(() {
      int lugarRealId = lugarIndex + 1; // Número real del lugar
      if (lugarSeleccionado == lugarIndex) {
        lugarSeleccionado = null; // Deselecciona el lugar si ya estaba seleccionado
      } else {
        lugarSeleccionado = lugarIndex; // Selecciona el nuevo lugar
      }
    });
  }


  Future<void> _reservarMeyer(BuildContext context) async {
    if (lugarSeleccionado == null) {
      // Mostrar mensaje si no hay lugar seleccionado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione un lugar para reservar.')),
      );
      return;
    }

    int lugarRealId = lugarSeleccionado! + 1;
    String lugarId = lugarRealId.toString();

    if (!disponibilidadMeyer.containsKey(lugarRealId) || !disponibilidadMeyer[lugarRealId]!) {
      // El lugar no está disponible, mostrar mensaje y no permitir reservar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este lugar no está disponible para reservar.')),
      );
      return;
    }

    TextEditingController nombreController = TextEditingController();
    TextEditingController patenteController = TextEditingController();
    TimeOfDay? horaInicio;
    TimeOfDay? horaSalida;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reservar Lugar'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: patenteController,
                    decoration: const InputDecoration(labelText: 'Patente del Vehículo'),
                  ),
                  Row(
                    children: [
                      const Text('Hora de Inicio: '),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: horaInicio ?? TimeOfDay.now(),
                          );
                          if (picked != null && picked != horaInicio) {
                            setState(() {
                              horaInicio = picked;
                            });
                          }
                        },
                        child: Text(
                          horaInicio != null ? horaInicio!.format(context) : 'Seleccionar',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Hora de Salida: '),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: horaSalida ?? TimeOfDay.now(),
                          );
                          if (picked != null && picked != horaSalida) {
                            setState(() {
                              horaSalida = picked;
                            });
                          }
                        },
                        child: Text(
                          horaSalida != null ? horaSalida!.format(context) : 'Seleccionar',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (horaInicio == null || horaSalida == null || nombreController.text.isEmpty || patenteController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, complete todos los campos.')),
                      );
                      return;
                    }

                    if (horaSalida!.hour < horaInicio!.hour || (horaSalida!.hour == horaInicio!.hour && horaSalida!.minute < horaInicio!.minute)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('La hora de salida no puede ser menor que la hora de inicio.')),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance.collection('reservas').add({
                      'lugar': lugarId,
                      'campus': 'M',
                      'name': nombreController.text,
                      'patente': patenteController.text,
                      'hora_inicio': '${horaInicio!.hour}:${horaInicio!.minute}',
                      'hora_fin': '${horaSalida!.hour}:${horaSalida!.minute}',
                      'activa': true,
                      'timestamp': FieldValue.serverTimestamp(),
                    }).then((reservaRef) {
                      // Reserva creada exitosamente
                      // Actualizamos la disponibilidad del lugar a ocupado (false)
                      FirebaseFirestore.instance.collection('lugares_meyer').doc(lugarId).update({
                        'disponible': false,
                      }).then((value) {
                        // Mostramos mensaje de reserva exitosa
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reserva realizada exitosamente.')),
                        );
                        Navigator.of(context).pop();
                      }).catchError((error) {
                        // Manejar error al actualizar la disponibilidad del lugar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al actualizar la disponibilidad del lugar: $error')),
                        );
                      });
                    }).catchError((error) {
                      // Manejar error al crear la reserva
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al realizar la reserva: $error')),
                      );
                    });
                  },
                  child: const Text('Reservar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _liberarMeyer(BuildContext context) {
    if (lugarSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione un lugar para liberar.')),
      );
      return;
    }

    int lugarRealId = lugarSeleccionado! + 1;
    String lugarId = lugarRealId.toString();

    // Actualizar disponibilidad del lugar a true (disponible)
    FirebaseFirestore.instance.collection('lugares_meyer').doc(lugarId).update({
      'disponible': true,
    }).then((value) {
      // Buscar y desactivar la reserva activa asociada a este lugar si existe
      FirebaseFirestore.instance.collection('reservas')
          .where('lugar', isEqualTo: lugarId)
          .where('activa', isEqualTo: true)
          .where('campus', isEqualTo: 'M')
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.update({
              'activa': false,
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lugar liberado exitosamente.')),
          );

          // Reiniciar la página actual después de liberar el lugar
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => UserGuardiaPage()),
                (Route<dynamic> route) => false,
          );
        } else {
          // No se encontró una reserva activa, pero liberar el lugar de todas formas si está marcado como no disponible
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró una reserva activa para este lugar. Liberando lugar de todas formas.')),
          );

          // Reiniciar la página actual después de liberar el lugar
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => UserGuardiaPage()),
                (Route<dynamic> route) => false,
          );
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar la reserva: $error')),
        );
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al liberar el lugar: $error')),
      );
    });
  }

  Future<void> _reservarChuyaca(BuildContext context) async {
    if (lugarSeleccionado == null) {
      // Mostrar mensaje si no hay lugar seleccionado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione un lugar para reservar.')),
      );
      return;
    }

    int lugarRealId = lugarSeleccionado! + 1;
    String lugarId = lugarRealId.toString();

    if (!disponibilidadChuyaca.containsKey(lugarRealId) || !disponibilidadChuyaca[lugarRealId]!) {
      // El lugar no está disponible, mostrar mensaje y no permitir reservar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este lugar no está disponible para reservar.')),
      );
      return;
    }

    TextEditingController nombreController = TextEditingController();
    TextEditingController patenteController = TextEditingController();
    TimeOfDay? horaInicio;
    TimeOfDay? horaSalida;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reservar Lugar'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: patenteController,
                    decoration: const InputDecoration(labelText: 'Patente del Vehículo'),
                  ),
                  Row(
                    children: [
                      const Text('Hora de Inicio: '),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: horaInicio ?? TimeOfDay.now(),
                          );
                          if (picked != null && picked != horaInicio) {
                            setState(() {
                              horaInicio = picked;
                            });
                          }
                        },
                        child: Text(
                          horaInicio != null ? horaInicio!.format(context) : 'Seleccionar',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Hora de Salida: '),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: horaSalida ?? TimeOfDay.now(),
                          );
                          if (picked != null && picked != horaSalida) {
                            setState(() {
                              horaSalida = picked;
                            });
                          }
                        },
                        child: Text(
                          horaSalida != null ? horaSalida!.format(context) : 'Seleccionar',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (horaInicio == null || horaSalida == null || nombreController.text.isEmpty || patenteController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, complete todos los campos.')),
                      );
                      return;
                    }

                    if (horaSalida!.hour < horaInicio!.hour || (horaSalida!.hour == horaInicio!.hour && horaSalida!.minute < horaInicio!.minute)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('La hora de salida no puede ser menor que la hora de inicio.')),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance.collection('reservas').add({
                      'lugar': lugarId,
                      'campus': 'C',
                      'name': nombreController.text,
                      'patente': patenteController.text,
                      'hora_inicio': '${horaInicio!.hour}:${horaInicio!.minute}',
                      'hora_fin': '${horaSalida!.hour}:${horaSalida!.minute}',
                      'activa': true,
                      'timestamp': FieldValue.serverTimestamp(),
                    }).then((reservaRef) {
                      // Reserva creada exitosamente
                      // Actualizamos la disponibilidad del lugar a ocupado (false)
                      FirebaseFirestore.instance.collection('lugares_chuyaca').doc(lugarId).update({
                        'disponible': false,
                      }).then((value) {
                        // Mostramos mensaje de reserva exitosa
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reserva realizada exitosamente.')),
                        );
                        Navigator.of(context).pop();
                      }).catchError((error) {
                        // Manejar error al actualizar la disponibilidad del lugar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al actualizar la disponibilidad del lugar: $error')),
                        );
                      });
                    }).catchError((error) {
                      // Manejar error al crear la reserva
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al realizar la reserva: $error')),
                      );
                    });
                  },
                  child: const Text('Reservar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _liberarChuyaca(BuildContext context) {
    if (lugarSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione un lugar para liberar.')),
      );
      return;
    }

    int lugarRealId = lugarSeleccionado! + 1;
    String lugarId = lugarRealId.toString();

    // Actualizar disponibilidad del lugar a true (disponible)
    FirebaseFirestore.instance.collection('lugares_chuyaca').doc(lugarId).update({
      'disponible': true,
    }).then((value) {
      // Buscar y desactivar la reserva activa asociada a este lugar si existe
      FirebaseFirestore.instance.collection('reservas')
          .where('lugar', isEqualTo: lugarId)
          .where('activa', isEqualTo: true)
          .where('campus', isEqualTo: 'C')
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.update({
              'activa': false,
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lugar liberado exitosamente.')),
          );

          // Reiniciar la página actual después de liberar el lugar
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => UserGuardiaPage()),
                (Route<dynamic> route) => false,
          );
        } else {
          // No se encontró una reserva activa, pero liberar el lugar de todas formas si está marcado como no disponible
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró una reserva activa para este lugar. Liberando lugar de todas formas.')),
          );

          // Reiniciar la página actual después de liberar el lugar
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => UserGuardiaPage()),
                (Route<dynamic> route) => false,
          );
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar la reserva: $error')),
        );
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al liberar el lugar: $error')),
      );
    });
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
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              FutureBuilder<String>(
                future: userName,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar el nombre'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('No se pudo obtener el nombre del usuario.'));
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data ?? 'Nombre Guardia',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const Divider(color: Colors.black),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 7),
              FutureBuilder<Map<String, dynamic>>(
                future: lastIncident,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar el último incidente'));
                  } else if (!snapshot.hasData || snapshot.data!['timestamp'] == null) {
                    return const Center(child: Text('No hay incidentes registrados.'));
                  } else {
                    final incident = snapshot.data!;
                    final timestamp = incident['timestamp'] as Timestamp;
                    final formattedFecha = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
                    final formattedHora = DateFormat('HH:mm').format(timestamp.toDate());
                    final motivo = incident['motivo'] ?? 'Motivo desconocido';
                    final patente = incident['patente'] ?? 'Patente desconocida';
                    final lugar = incident['lugar'] ?? 'Lugar desconocido';
                    final userName = incident['userName'] ?? 'Usuario no registrado';
                    final userPhone = incident['userPhone'] ?? 'Teléfono no registrado';
                    final imageUrl = incident['foto'] ?? '';

                    return GestureDetector(
                      onTap: () => _showImage(imageUrl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'Último incidente:',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              '(Para ver la imagen presiona sobre el incidente)',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            'Usuario: $userName',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Patente: $patente',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Fecha: $formattedFecha',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Hora: $formattedHora',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Lugar: $lugar',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Motivo: $motivo',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Teléfono: $userPhone',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReportarIncidentePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0055B7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  child: const Text('Reportar incidente'),
                ),
              ),
              const Divider(color: Colors.black),
              const SizedBox(height: 15),
              const Text('Mapa Meyer',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildMapaMeyerContainer(), // Mapa interactivo de lugares
              const SizedBox(height: 30),
              _buildLegenda(),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _reservarMeyer(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFFFEFEFF),
                      backgroundColor: const Color(0xFF0055B7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    child: const Text('Reservar Meyer'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _liberarMeyer(context);
                      //Logica para liberar un lugar y desactivar una reserva
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFFFEFEFF),
                      backgroundColor: const Color(0xFF0055B7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    child: const Text('Liberar Meyer'),
                  ),
                ],
              ),


              const Divider(color: Colors.black),
              const SizedBox(height: 15),
              const Text('Mapa Chuyaca',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildMapaChuyacaContainer(), // Mapa interactivo de lugares
              const SizedBox(height: 30),
              _buildLegenda(),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _reservarChuyaca(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFFFEFEFF),
                      backgroundColor: const Color(0xFF0055B7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    child: const Text('Reservar Chuyaca'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _liberarChuyaca(context);
                      //Logica para liberar un lugar y desactivar una reserva
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFFFEFEFF),
                      backgroundColor: const Color(0xFF0055B7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    child: const Text('Liberar Chuyaca'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }





  Widget _buildMapaMeyerContainer() {
    return Container(
      height: 250,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: MapaMeyer(
          disponibilidadLugares: disponibilidadMeyer,
          lugarSeleccionado: lugarSeleccionado,
          onToggleSeleccion: _toggleSeleccion,
        ),
      ),
    );
  }

  Widget _buildMapaChuyacaContainer() {
    return Container(
      height: 250,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: MapaChuyaca(
          disponibilidadLugares: disponibilidadChuyaca,
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
}