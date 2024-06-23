import 'package:flutter/material.dart';
import 'login.dart';
//import 'firebase_options.dart';
//import 'package:firebase_core/firebase_core.dart';

void main() {
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
      home: const HomePage(),
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
                  const Text('000', style: TextStyle(fontSize: 40, color: Color(0xFFFEFEFF))),
                  const SizedBox(height: 10),

                  const Text('Disponibles en Meyer:', style: TextStyle(fontSize: 25, color: Color(0xFFFEFEFF))),
                  const Text('000', style: TextStyle(fontSize: 40, color: Color(0xFFFEFEFF))),
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
