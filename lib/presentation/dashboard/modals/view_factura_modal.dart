import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewFacturaModal extends StatelessWidget {
  const ViewFacturaModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 800,
      width: 300,
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Nombre del negocio',
                style: GoogleFonts.archivoNarrow(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            const Center(child: Text('RTN del negocio')),
            const Center(
              child: SizedBox(
                //width: 200,
                child: Text(
                  'Dirección del negocio, teniendo en cuenta que podría tener varias líneas de texto',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Center(child: Text('Correo del negocio')),
            const Center(child: Text('Teléfono del negocio')),
            const Gap(10),
            const Divider(
              color: Colors.black,
            ),
            const Gap(10),
            const Text(
              'FACTURA VENTA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('000-001-01-00000001'),
            const Text('2024-12-31 / 07:21 am'),
            const Gap(10),
            const Divider(
              color: Colors.black,
            ),
            const Gap(10),
            const Text(
              'NOMBRE DEL CLIENTE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('NO. O/C EXENTA:'),
            const Text('NO.REG DE EXONERADO:'),
            const Text('NO. REG DE LA SAG:'),
            const Gap(10),
            Table(
              textDirection: TextDirection.ltr,
              columnWidths: const {
                0: FixedColumnWidth(40),
                1: FlexColumnWidth(),
                2: FixedColumnWidth(70),
              },
              children: const <TableRow>[
                TableRow(
                  decoration:
                      BoxDecoration(border: Border(bottom: BorderSide())),
                  children: [
                    Text('UDS'),
                    Text('DESCRIPCIÓN'),
                    Text('IMPORTE'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('2'),
                    Text('Marquesote'),
                    Text('L 30.0'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('3'),
                    Text('Café con leche'),
                    Text('L 55.0'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('2'),
                    Text('Pupusas con quesillo'),
                    Text('L 30.0'),
                  ],
                ),
              ],
            ),
            const Gap(20),
            const Text('3 Artículos'),
            const Gap(10),
            const Divider(
              color: Colors.black,
            ),
            const Gap(10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('SUB-TOTAL'),
                Gap(15),
                Text('L 115.00'),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('DESCUENTOS Y REBAJAS'),
                Gap(15),
                Text('L 0.00'),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('IMPORTE EXENTO'),
                Gap(15),
                Text('0.00'),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('IMPORTE GRAVADO'),
                Gap(15),
                Text('L 115.00'),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('ISV (15%)'),
                Gap(15),
                Text('L 17.25'),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('TOTAL'),
                Gap(15),
                Text('L 132.25'),
              ],
            ),
            const Gap(10),
            const Divider(
              color: Colors.black,
            ),
            const Gap(10),
            const SizedBox(
              height: 60,
              child:
                  Text('CIENTO TREINTA Y DOS MIL LEMPIRAS CON 25/100 CENTAVOS'),
            ),
            const Gap(10),
            const Center(
              child: Text(
                'CAI asdfas-asdfas-asdfas-asdfas-asdfas-as',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            const Gap(10),
            const Center(
              child: Text(
                'Rango autorizado',
              ),
            ),
            const Center(
              child: Text(
                '000-001-01-00000001 a 000-001-01-00000100',
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Fecha límite de emisión: 16-06-2025',
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
            const Gap(10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Original:'),
                Text('Cliente'),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Copia:'),
                Text('Obligado Tributario Emisor'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
