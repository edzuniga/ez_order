import 'package:flutter/material.dart';

class DatosFacturacionView extends StatefulWidget {
  const DatosFacturacionView({super.key});

  @override
  State<DatosFacturacionView> createState() => _AdminViewState();
}

class _AdminViewState extends State<DatosFacturacionView> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Datos Facturación VIEW'),
    );
  }
}
