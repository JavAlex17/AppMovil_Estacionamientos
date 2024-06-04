import 'package:appmovil/visitas.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0055B7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/img/logoulagos.png', height: 120),
            const SizedBox(height: 35),

            const Text('Estacionamientos', style: TextStyle(fontSize: 30, color: Color(0xFFFEFEFF))),
            const Text('Chuyaca - Meyer', style: TextStyle(fontSize: 25, color: Color(0xFFFEFEFF))),
            const SizedBox(height: 20),// Espacio de 20 de altura entre el logo y el primer texto

            _buildTextField(label: 'Correo Institucional', isPassword: false, icon: Icons.email),
            _buildTextField(label: 'Contraseña', isPassword: true, icon: Icons.lock),

            const SizedBox(height: 20), // Espacio de 20 de altura entre el último campo de entrada de texto y el botón

            SizedBox(
                width: 120,
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
                    child: const Text('Login', style: TextStyle(fontSize: 20))
                )
            ),

            const SizedBox(height: 20), // Espacio de 20 de altura entre el botón y el último texto

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VisitasPage()), // Navegar a la otra pantalla
                );
              },
              child: const Text('¿Eres visita? Click aquí', style: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF))),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTextField({required String label, required bool isPassword, required IconData icon}) {
    return Container(
      width: 340,
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}