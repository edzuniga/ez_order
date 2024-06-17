import 'package:ez_order_ezr/presentation/providers/facturacion/datos_factura_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MensajeStatusView extends ConsumerWidget {
  const MensajeStatusView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datosFactura = ref.watch(datosFacturaManagerProvider);
    String mensajePrincipal = 'Sus datos de factura están en orden';
    Color colorFondo = Colors.green;

    //primera condición -> NO HA INGRESADO DATOS DE FACTURACIÓN
    if (datosFactura.idDatosFactura == 0) {
      mensajePrincipal = 'No ha ingresado datos de facturación';
      colorFondo = Colors.orange;
    }

    //Segunda condición -> hay datos pero ya están vencidos
    if (datosFactura.fechaLimite.isBefore(DateTime.now())) {
      mensajePrincipal =
          'Sus facturas ya expiraron.\nActualice datos de facturación.';
      colorFondo = Colors.orange;
    }

    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 15,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        height: 130,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          mensajePrincipal,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
