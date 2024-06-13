import 'package:flutter/material.dart';
import 'menuh.dart';

class UsuarioPage extends StatelessWidget {
  const UsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0055B7),
        leading: Builder(
          builder: (BuildContext context) {
           return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white), // Icono de menú hamburguesa
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Abre el menú lateral
              },
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('lib/assets/img/logoulagos.png', height: 35), // Logo a la derecha
          ),
        ],
      ),
      drawer: const MenuHamburguesa(), // Menú hamburguesa desplegado al hacer clic en el icono de menú
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nombre Usuario',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Datos de mi vehículo:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text('Patente: ABC123', style: TextStyle(fontSize: 18)),
            const Text('Color: Gris', style: TextStyle(fontSize: 18)),
            const Text('Modelo: 2022', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            const Divider(color: Colors.black),

            const SizedBox(height: 20),

            const Text(
              'Estacionamiento actual:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Lugar: Zona A', style: TextStyle(fontSize: 18)),
            const Text('Hora de entrada: 10:00 AM', style: TextStyle(fontSize: 18)),
            const Text('Hora de salida: 02:00 PM', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0055B7),
                  ),
                  child: const Text('Reservar lugar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Lógica para liberar lugar
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0055B7),
                  ),
                  child: const Text('Liberar lugar'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Divider(color: Colors.black),

            const SizedBox(height: 20),
            const Text(
              'Últimas entradas:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('Fecha: 2024-06-11', style: TextStyle(fontSize: 18)),
                    subtitle: Text('Hora: 10:00 AM\nLugar: Zona A', style: TextStyle(fontSize: 16)),
                  ),
                  ListTile(
                    title: Text('Fecha: 2024-06-06', style: TextStyle(fontSize: 18)),
                    subtitle: Text('Hora: 09:00 AM\nLugar: Zona B', style: TextStyle(fontSize: 16)),
                  ),
                  ListTile(
                    title: Text('Fecha: 2024-05-20', style: TextStyle(fontSize: 18)),
                    subtitle: Text('Hora: 18:00 PM\nLugar: Zona C', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}