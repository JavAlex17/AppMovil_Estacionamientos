import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'registo_reservas_guardia.dart';
import 'registrar_vehiculo.dart';
import 'registro_incidentes.dart';
import 'registro_incidentes_guardia.dart';
import 'registro_reservas.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


class MenuHamburguesa extends StatelessWidget {
  const MenuHamburguesa({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    'Menú',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48), // Espacio para equilibrar el botón de cierre
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text(
              'Registrar vehículo',
              style: TextStyle(fontSize: 22),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegistroVehiculoPage()),
              );
            },
          ),
          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final userData = snapshot.data!.data();
              final bool isGuard = userData != null && userData['guard'] == true;

              return ListTile(
                leading: const Icon(Icons.history),
                title: const Text(
                  'Registros',
                  style: TextStyle(fontSize: 22),
                ),
                onTap: () {
                  if (isGuard) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistroReservasGuardiaPage()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistroReservasPage()),
                    );
                  }
                },
              );
            },
          ),
          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final userData = snapshot.data!.data();
              final bool isGuard = userData != null && userData['guard'] == true;

              return ListTile(
                leading: const Icon(Icons.report),
                title: const Text(
                  'Registros incidentes',
                  style: TextStyle(fontSize: 22),
                ),
                onTap: () {
                  if (isGuard) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistroGuardiaIncidentes()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistroIncidentes()),
                    );
                  }
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(fontSize: 22),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()), // Reemplaza con tu página de inicio de sesión
              );
              // Aquí se implementa la lógica para cerrar la sesión
            },
          ),
        ],
      ),
    );
  }
}

