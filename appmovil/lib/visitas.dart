import 'package:flutter/material.dart';

class VisitasPage extends StatelessWidget {
  const VisitasPage({super.key});

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

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            const SizedBox(height: 30),
            const Text('Registro de visitas', style: TextStyle(fontSize: 28, color: Color(0xFF000000))),
            const SizedBox(height: 20),

            _buildTextField(label: 'Nombre'), // Campo de nombre
            const SizedBox(height: 20), // Espacio entre los campos
            _buildTextField(label: 'Patente'), // Campo de patente
            const SizedBox(height: 20), // Espacio entre los campos
            _buildTextField(label: 'Color'), // Campo de color
            const SizedBox(height: 20), // Espacio entre los campos
            _buildTextField(label: 'Teléfono'), // Campo de teléfono
            const SizedBox(height: 20), // Espacio entre los campos y el botón

            SizedBox(
                width: 250,
                height: 40,
                child:
                ElevatedButton(
                    onPressed: (){

                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFFFEFEFF),
                      backgroundColor: const Color(0xFFB6ADA4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    child: const Text('Seleccionar Lugar', style: TextStyle(fontSize: 20))
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label}) {
    return Container(
      width: 340,
      height: 45,
        margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        decoration: InputDecoration(
          labelText: label, // Etiqueta del campo
          border: const OutlineInputBorder(), // Borde del campo
        ),
      ),
    );
  }
}