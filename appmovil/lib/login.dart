import 'package:flutter/material.dart';
import 'package:uparking/visitas.dart';
//import 'package:firebase_auth/firebase_auth.dart';

import 'user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
            const SizedBox(height: 20), // Espacio de 20 de altura entre el logo y el primer texto

            _buildTextField(
                controller: _emailController,
                label: 'Correo Institucional',
                isPassword: false,
                icon: Icons.email),
            _buildTextField(
                controller: _passwordController,
                label: 'Contraseña',
                isPassword: true,
                icon: Icons.lock),

            const SizedBox(height: 20), // Espacio de 20 de altura entre el último campo de entrada de texto y el botón

            SizedBox(
              width: 120,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UsuarioPage()), // Navegar a la otra pantalla
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFFFEFEFF),
                  backgroundColor: const Color(0xFFB6ADA4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 20)),
              ),
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

  Widget _buildTextField(
      {required TextEditingController controller,
        required String label,
        required bool isPassword,
        required IconData icon}) {
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
        controller: controller,
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