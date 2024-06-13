import 'package:flutter/material.dart';

class ModificarDatos extends StatelessWidget {
  const ModificarDatos({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController patenteController = TextEditingController();
    final TextEditingController colorController = TextEditingController();
    final TextEditingController modeloController = TextEditingController();
    final TextEditingController telefonoController = TextEditingController();

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
            const Text('Modificar Datos', style: TextStyle(fontSize: 28, color: Color(0xFF000000))),
            const SizedBox(height: 15),

            _buildTextField(controller: patenteController, label: 'Patente'),
            const SizedBox(height: 15),
            _buildTextField(controller: colorController, label: 'Color'),
            const SizedBox(height: 15),
            _buildTextField(controller: modeloController, label: 'Modelo'),
            const SizedBox(height: 15),
            _buildTextField(controller: telefonoController, label: 'Teléfono'),
            const SizedBox(height: 30),

            Center(
              child:Row(
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
                      // Lógica para guardar los datos
                      final String patente = patenteController.text;
                      final String color = colorController.text;
                      final String modelo = modeloController.text;
                      final String telefono = telefonoController.text;

                      // Aquí iría la lógica para guardar los datos, por ejemplo, enviarlos a un servidor o guardarlos localmente.
                      // Luego de guardar, puedes navegar a otra pantalla o mostrar un mensaje de éxito.
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
      child:TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
