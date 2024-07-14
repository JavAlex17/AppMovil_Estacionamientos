import 'package:flutter/material.dart';

class MapaChuyaca extends StatelessWidget {
  final Map<int, bool> disponibilidadLugares;
  final int? lugarSeleccionado;
  final Function(int) onToggleSeleccion;

  const MapaChuyaca({
    Key? key,
    required this.disponibilidadLugares,
    required this.lugarSeleccionado,
    required this.onToggleSeleccion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilaLugares(0, 14),
                _buildFilaLugaresConPreferencial(14, 1),
                const SizedBox(width: 20),
                const Text('Entrada', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 20),
                _buildFilaLugares(15, 19),
                _buildFilaLugaresConPreferencial(34, 1),
                const SizedBox(width: 20),
                const Text('Entrada', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 20),
                _buildFilaLugares(35, 15),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilaLugares(50, 15),
                const SizedBox(width: 100),
                _buildFilaLugares(65, 15),
                const SizedBox(width: 300),
                _buildFilaLugares(80, 7),
                const SizedBox(width: 260),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilaLugares(int startIndex, int count) {
    List<Widget> lugares = [];
    for (int i = startIndex; i < startIndex + count; i++) {
      lugares.add(
        GestureDetector(
          onTap: () => onToggleSeleccion(i),
          child: Container(
            margin: const EdgeInsets.all(5),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: _getLugarColor(i),
            ),
            child: Center(
              child: Text(
                (i + 1).toString(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Row(children: lugares);
  }

  Color _getLugarColor(int lugarIndex) {
    int lugarRealId = lugarIndex + 1;

    if (lugarSeleccionado == lugarRealId - 1) {
      return Colors.green;
    } else if (disponibilidadLugares.containsKey(lugarRealId) &&
        !disponibilidadLugares[lugarRealId]!) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  Widget _buildFilaLugaresConPreferencial(int startIndex, int count) {
    List<Widget> lugares = [];
    for (int i = startIndex; i < startIndex + count; i++) {
      lugares.add(
        GestureDetector(
          onTap: () => onToggleSeleccion(i),
          child: Container(
            margin: EdgeInsets.all(5),
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: _getLugarColorPreferencia(i),
            ),
            child: const Center(
              child: Icon(
                Icons.accessible,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      );
    }
    return Row(children: lugares);
  }

  Color _getLugarColorPreferencia(int lugarIndex) {
    if (lugarSeleccionado == lugarIndex) {
      return Colors.green;
    } else if (disponibilidadLugares.containsKey(lugarIndex) &&
        !disponibilidadLugares[lugarIndex]!) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }
}
