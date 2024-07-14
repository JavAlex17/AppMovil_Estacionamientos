import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user.dart';
import 'user_guardia.dart';
import 'registro_usuario.dart';
import 'visitas.dart';

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

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Por favor, ingrese su correo y contraseña');
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        // Obtener datos del usuario desde Firestore
        final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          // Verificar el atributo 'guard'
          final bool isGuard = userDoc['guard'] == true;

          if (isGuard) {
            // Si es guardia, navegar a UserGuardiaPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserGuardiaPage()),
            );
          } else {
            // Si no es guardia, navegar a UsuarioPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UsuarioPage()),
            );
          }
        } else {
          _showErrorDialog('No se encontraron datos del usuario.');
        }
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
      _showErrorDialog('Error al iniciar sesión. Por favor, verifique sus datos e intente nuevamente.');
    }
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
            const SizedBox(height: 20),
            _buildTextField(
              controller: _emailController,
              label: 'Correo',
              isPassword: false,
              icon: Icons.email,
            ),
            _buildTextField(
              controller: _passwordController,
              label: 'Contraseña',
              isPassword: true,
              icon: Icons.lock,
            ),
            const SizedBox(height: 20),
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
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
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
                const SizedBox(width: 20),
                SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _login,
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
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VisitasPage()),
                );
              },
              child: const Text('¿Eres visita? Click aquí', style: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isPassword,
    required IconData icon,
  }) {
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