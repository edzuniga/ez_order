import 'package:flutter/material.dart';

class FacturacionView extends StatefulWidget {
  const FacturacionView({super.key});

  @override
  State<FacturacionView> createState() => _AdminViewState();
}

class _AdminViewState extends State<FacturacionView> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Facturación VIEW'),
    );
  }
}
