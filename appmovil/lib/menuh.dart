import 'package:flutter/material.dart';
import 'modificar_datos.dart';
import 'registrar_vehiculo.dart';


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
                    const Text('Menú',
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
              title: const Text('Registrar vehículo',
                style: TextStyle(fontSize: 22),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistroVehiculoPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modificar datos',
                style: TextStyle(fontSize: 22),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ModificarDatos()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Registros',
                style: TextStyle(fontSize: 22),
              ),
              onTap: () {
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Registros incidentes',
                style: TextStyle(fontSize: 22),
              ),
              onTap: () {
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión',
                style: TextStyle(fontSize: 22),
              ),
              onTap: () {
                // Aquí se implementa la lógica para cerrar la sesión
              },
            ),
          ],
        ),
    );
  }
}

