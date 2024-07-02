import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisitasPage extends StatelessWidget {
  VisitasPage({Key? key}) : super(key: key);

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController patenteController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  void _guardarVisita(BuildContext context) async {
    final String nombre = nombreController.text;
    final String patente = patenteController.text;
    final String color = colorController.text;
    final String telefono = telefonoController.text;

    // Aquí deberías implementar la lógica para seleccionar el lugar
    // Puedes guardar el lugar seleccionado en Firestore junto con los demás datos

    try {
      // Guardar los datos en Firestore
      await FirebaseFirestore.instance.collection('visitas').add({
        'nombre': nombre,
        'patente': patente,
        'color': color,
        'telefono': telefono,
        // Aquí debes agregar el campo para el lugar seleccionado
        // Ejemplo: 'lugar': lugarSeleccionado,
        'timestamp': Timestamp.now(), // Opcional: agregar una marca de tiempo
      });

      // Mostrar mensaje de éxito o redirigir a otra pantalla si es necesario

    } catch (e) {
      // Manejar errores, por ejemplo, mostrar un mensaje al usuario
      print('Error al guardar la visita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar la visita. Inténtalo de nuevo más tarde.'),
          duration: Duration(seconds: 3),
        ),
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
            child: Image.asset('lib/assets/img/logoulagos.png', height: 35),
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
              const Text('Registro de visitas', style: TextStyle(fontSize: 28, color: Color(0xFF000000))),
              const SizedBox(height: 15),

              _buildTextField(label: 'Nombre', controller: nombreController),
              const SizedBox(height: 15),
              _buildTextField(label: 'Patente', controller: patenteController),
              const SizedBox(height: 15),
              _buildTextField(label: 'Color', controller: colorController),
              const SizedBox(height: 15),
              _buildTextField(label: 'Teléfono', controller: telefonoController),
              const SizedBox(height: 15),

              SizedBox(
                width: 235,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    _guardarVisita(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFFFEFEFF),
                    backgroundColor: const Color(0xFFB6ADA4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  child: const Text('Seleccionar Lugar', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller}) {
    return Container(
      width: 320,
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