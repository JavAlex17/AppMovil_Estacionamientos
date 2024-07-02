import 'package:flutter/material.dart';
import 'package:uparking/registro_usuario.dart';
import 'package:uparking/visitas.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()), // Navegar a la página de registro
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFFFEFEFF),
                      backgroundColor: const Color(0xFFB6ADA4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    child: const Text('Registrar', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 20), // Espacio entre los dos botones
                SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();

                      try {
                        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        // Si el inicio de sesión es exitoso, navega a la página de usuario
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const UsuarioPage()),
                        );
                      } catch (e) {
                        // Manejo de errores
                        // Aquí puedes mostrar un mensaje de error al usuario
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFFFEFEFF),
                      backgroundColor: const Color(0xFFB6ADA4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20), // Espacio de 20 de altura entre el botón y el último texto

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VisitasPage()), // Navegar a la otra pantalla
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