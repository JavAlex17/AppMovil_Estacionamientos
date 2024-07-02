import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistroVehiculoPage extends StatelessWidget {
  const RegistroVehiculoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController patenteController = TextEditingController();
    final TextEditingController colorController = TextEditingController();
    final TextEditingController modeloController = TextEditingController();

    Future<void> _guardarDatos(BuildContext context) async {
      final String patente = patenteController.text.trim();
      final String color = colorController.text.trim();
      final String modelo = modeloController.text.trim();
      final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      if (userId.isNotEmpty) {
        await FirebaseFirestore.instance.collection('vehiculos').add({
          'patente': patente,
          'color': color,
          'modelo': modelo,
          'userId': userId,
          'timestamp': FieldValue.serverTimestamp(),
        });
        Navigator.pop(context); // Volver a la página anterior después de guardar
      } else {
        // Mostrar un mensaje de error si el usuario no está autenticado
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Usuario no autenticado. Por favor, inicia sesión.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Text('Registrar vehículo', style: TextStyle(fontSize: 28, color: Color(0xFF000000))),
            const SizedBox(height: 15),
            _buildTextField(controller: patenteController, label: 'Patente'),
            const SizedBox(height: 15),
            _buildTextField(controller: colorController, label: 'Color'),
            const SizedBox(height: 15),
            _buildTextField(controller: modeloController, label: 'Modelo'),
            const SizedBox(height: 30),
            Center(
              child: Row(
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
                      child: const Text('Volver', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 180,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => _guardarDatos(context),
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
            ),
          ],
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
}
