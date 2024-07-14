import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uparking/user.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';

import 'user_guardia.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Estacionamientos',
      theme: ThemeData(fontFamily: 'NeueMachina',
      ),
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({Key? key}) : super(key: key);

  Future<bool> checkIfGuard(User? user) async {
    if (user == null) return false;
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return doc['guard'] == true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: checkIfGuard(snapshot.data),
            builder: (context, guardSnapshot) {
              if (guardSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (guardSnapshot.hasData && guardSnapshot.data == true) {
                return const UserGuardiaPage();
              } else {
                return const UsuarioPage();
              }
            },
          );
        }
        return const HomePage();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  @override

  Widget build(BuildContext context){
    return Scaffold(
        backgroundColor: const Color(0xFF0055B7),
        body: Center(
            child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Image.asset('lib/assets/img/logoulagos.png', height: 95),
                  const SizedBox(height: 65),

                  const Text('Estacionamientos', style: TextStyle(fontSize: 40, color: Color(0xFFFEFEFF))),
                  const Text('Chuyaca - Meyer', style: TextStyle(fontSize: 30, color: Color(0xFFFEFEFF))),
                  const SizedBox(height: 30),

                  const Text('Disponibles en Chuyaca:', style: TextStyle(fontSize: 25, color: Color(0xFFFEFEFF))),
                  const Text('027', style: TextStyle(fontSize: 40, color: Color(0xFFFEFEFF))),
                  const SizedBox(height: 10),

                  const Text('Disponibles en Meyer:', style: TextStyle(fontSize: 25, color: Color(0xFFFEFEFF))),
                  const Text('086', style: TextStyle(fontSize: 40, color: Color(0xFFFEFEFF))),
                  const SizedBox(height: 40),



                  SizedBox(
                      width: 150,
                      height: 45,
                      child:
                      ElevatedButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color(0xFFFEFEFF),
                            backgroundColor: const Color(0xFFB6ADA4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          child: const Text('Entrar', style: TextStyle(fontSize: 22))
                      )
                  )
                ]
            )
        )
    );
  }
}
