import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';


class ReportarIncidentePage extends StatefulWidget {
  const ReportarIncidentePage({Key? key}) : super(key: key);

  @override
  _ReportarIncidentePageState createState() => _ReportarIncidentePageState();
}

class _ReportarIncidentePageState extends State<ReportarIncidentePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patenteController = TextEditingController();
  final TextEditingController _otroMotivoController = TextEditingController();
  String _motivoSeleccionado = 'Robo'; // Inicializa con un motivo por defecto
  File? _image;
  String _initialSeleccionada = 'M';
  int? _lugarSeleccionado;
  int _maxLugares = 1; // Inicializa con un lugar por defecto

  @override
  void initState() {
    super.initState();
    _fetchMaxLugares();
  }

  Future<void> _fetchMaxLugares() async {
    // Determinar la colección correcta basada en la inicial seleccionada
    final collection = _initialSeleccionada == 'M' ? 'lugares_meyer' : 'lugares_chuyaca';
    final lugaresSnapshot = await FirebaseFirestore.instance.collection(collection).get();
    setState(() {
      _maxLugares = lugaresSnapshot.docs.length;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _submitIncident() async {
    // Validación del formulario
    if (_formKey.currentState!.validate()) {
      String? motivo;
      String? imageUrl;

      // Validar el motivo
      if (_motivoSeleccionado != 'Otro' || _otroMotivoController.text.isNotEmpty) {
        motivo = _motivoSeleccionado != 'Otro' ? _motivoSeleccionado : _otroMotivoController.text;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor ingrese un motivo válido.')),
        );
        return;
      }

      // Subir imagen a Firebase Storage si existe
      if (_image != null) {
        try {
          imageUrl = await _uploadImage(_image!);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir la imagen: $e')),
          );
          return;
        }
      }

      // Obtener el userId y los detalles del usuario
      String? userId;
      String? userName;
      String? userPhone;

      try {
        final vehiculoSnapshot = await FirebaseFirestore.instance
            .collection('vehiculos')
            .where('patente', isEqualTo: _patenteController.text)
            .limit(1)
            .get();

        if (vehiculoSnapshot.docs.isNotEmpty) {
          userId = vehiculoSnapshot.docs.first.data()['userId'];
          final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

          if (userSnapshot.exists) {
            userName = userSnapshot.data()!['name'];
            userPhone = userSnapshot.data()!['phone'];
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener detalles del usuario: $e')),
        );
        return;
      }

      // Determinar la colección correcta basada en la inicial seleccionada
      final incidentesCollection = _initialSeleccionada == 'M' ? 'incidentes_meyer' : 'incidentes_chuyaca';

      // Guardar el incidente en Firestore
      try {
        await FirebaseFirestore.instance.collection(incidentesCollection).add({
          'patente': _patenteController.text,
          'motivo': motivo,
          'foto': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': userId,
          'userName': userName,
          'userPhone': userPhone,
          'lugar': '$_initialSeleccionada${_lugarSeleccionado.toString()}',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incidente reportado exitosamente')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el incidente: $e')),
        );
      }
    }
  }

  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance.ref().child('incident_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() => null);
    final url = await snapshot.ref.getDownloadURL();
    return url;
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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Text('Registro de incidentes', style: TextStyle(fontSize: 28, color: Color(0xFF000000))),
                  const SizedBox(height: 15),

                  _buildTextField(label: 'Patente', controller: _patenteController),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 15),
                      const Text('Lugar:', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _initialSeleccionada,
                        items: ['M', 'C'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _initialSeleccionada = newValue!;
                            _fetchMaxLugares(); // Actualiza los lugares disponibles al cambiar la letra
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<int>(
                        value: _lugarSeleccionado,
                        hint: const Text('Lugar'),
                        items: List<int>.generate(_maxLugares, (index) => index + 1)
                            .map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _lugarSeleccionado = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text('Motivo:', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Column(
                    children: <String>['Robo', 'Choque', 'Mal estacionado', 'Otro']
                        .map((String motivo) => RadioListTile<String>(
                      title: Text(motivo),
                      value: motivo,
                      groupValue: _motivoSeleccionado,
                      onChanged: (String? value) {
                        setState(() {
                          _motivoSeleccionado = value!;
                        });
                      },
                    ))
                        .toList(),
                  ),
                  if (_motivoSeleccionado == 'Otro')
                    _buildTextField(label: 'Especifique el motivo', controller: _otroMotivoController),
                  const SizedBox(height: 5),

                  if (_image != null)
                    _buildImagenField(),

                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text('Tomar Foto'),
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: _submitIncident,
                        child: const Text('Reportar Incidente'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImagenField() {
    return Container(
      height: 160, // Ajusta el tamaño del contenedor según sea necesario
      width: MediaQuery.of(context).size.width, // Ancho máximo del contenedor
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Image.file(_image!, fit: BoxFit.cover),
    );
  }
}