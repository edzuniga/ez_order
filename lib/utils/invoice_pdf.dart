import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import 'package:ez_order_ezr/data/datos_factura_modelo.dart';
import 'package:ez_order_ezr/data/pedido_detalle_model.dart';
import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/data/factura_modelo.dart';
import 'package:ez_order_ezr/utils/numbers_to_words.dart';

Future<Uint8List> generateFacturaPdf(
    FacturaModelo factura,
    DatosFacturaModelo datosFacturacion,
    List<PedidoDetalleModel> detallesPedido,
    PedidoModel pedidoParaView) async {
  final doc = pw.Document();

  // Define the page format with margins
  const margin1 = 10 * PdfPageFormat.mm;
  const margin2 = 3 * PdfPageFormat.mm;
  const receiptFormat = PdfPageFormat(
    80 * PdfPageFormat.mm,
    double.infinity,
    marginTop: margin1,
    marginBottom: margin1,
    marginLeft: margin2,
    marginRight: margin2,
  );

  // Número de factura con ceros
  String resultadoNumFactura = factura.numFactura.toString().padLeft(8, '0');
  String rangoInicialString =
      datosFacturacion.rangoInicial.toString().padLeft(8, '0');
  String rangoFinalString =
      datosFacturacion.rangoFinal.toString().padLeft(8, '0');

  // Formatear fecha y hora
  String formattedDate = DateFormat.yMMMEd('es').format(factura.fechaFactura);
  String formattedTime = DateFormat('h:mm a').format(factura.fechaFactura);

  Font fontTitulo = await PdfGoogleFonts.robotoCondensedBold();
  Font cuerpoFont = await PdfGoogleFonts.robotoRegular();
  pw.TextStyle estilo = pw.TextStyle(
    fontSize: 10,
    font: cuerpoFont,
    color: PdfColors.black,
  );
  pw.TextStyle estiloBold = pw.TextStyle(
    fontSize: 10,
    font: fontTitulo,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  // Fecha limite de emisión
  String fechaLimiteEmision = datosFacturacion.fechaLimite != null
      ? datosFacturacion.fechaLimite.toString().substring(0, 10)
      : '';

  pw.Row buildRow(String left, String right) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          left,
          style: estilo,
        ),
        pw.Text(
          right,
          style: estilo,
        ),
      ],
    );
  }

  doc.addPage(
    pw.Page(
      pageFormat: receiptFormat,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                datosFacturacion.nombreNegocio,
                style: pw.TextStyle(
                  fontSize: 16,
                  font: fontTitulo,
                  color: PdfColors.black,
                ),
              ),
            ),
            pw.Center(child: pw.Text(datosFacturacion.rtn, style: estilo)),
            pw.Center(
              child: pw.Text(
                datosFacturacion.direccion,
                style: estilo,
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Center(child: pw.Text(datosFacturacion.correo, style: estilo)),
            pw.Center(child: pw.Text(datosFacturacion.telefono, style: estilo)),
            pw.SizedBox(height: 10),
            pw.Divider(color: PdfColors.black),
            pw.SizedBox(height: 10),
            pw.Text(
              'FACTURA VENTA',
              style: estiloBold,
            ),
            pw.Text('000-001-01-$resultadoNumFactura', style: estilo),
            pw.Text('$formattedDate | $formattedTime', style: estilo),
            pw.SizedBox(height: 10),
            pw.Divider(color: PdfColors.black),
            pw.SizedBox(height: 10),
            pw.Text(
              'Cliente: ${factura.nombreCliente}',
              style: estiloBold.copyWith(fontSize: 12),
            ),
            pw.Text('RTN: ${factura.rtn}', style: estilo),
            pw.Text('NO. O/C EXENTA:', style: estilo),
            pw.Text('NO.REG DE EXONERADO:', style: estilo),
            pw.Text('NO. REG DE LA SAG:', style: estilo),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headerAlignment: pw.Alignment.centerLeft,
              columnWidths: const {
                0: pw.FixedColumnWidth(40),
                1: pw.FlexColumnWidth(),
                2: pw.FixedColumnWidth(70),
              },
              context: context,
              border: null,
              headerStyle: estiloBold.copyWith(fontSize: 10),
              headers: ['UDS', 'DESCRIPCIÓN', 'IMPORTE'],
              data: [
                ...detallesPedido.map((element) {
                  double precioOriginal =
                      (element.importeCobrado / element.cantidad);
                  return [
                    element.cantidad.toString(),
                    '${element.nombreMenuItem}\n1.0 x L ${precioOriginal.toStringAsFixed(2)}',
                    'L ${element.importeCobrado.toStringAsFixed(2)}',
                  ];
                }),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
                detallesPedido.length == 1
                    ? '1 Artículo'
                    : '${detallesPedido.length} Artículos',
                style: estilo),
            pw.SizedBox(height: 10),
            pw.Divider(color: PdfColors.black),
            pw.SizedBox(height: 10),
            buildRow('SUB-TOTAL', 'L ${pedidoParaView.subtotal}'),
            buildRow('DESCUENTOS Y REBAJAS', 'L ${pedidoParaView.descuento}'),
            buildRow('IMPORTE EXENTO', 'L ${pedidoParaView.importeExento}'),
            buildRow('IMPORTE GRAVADO', 'L ${pedidoParaView.importeGravado}'),
            buildRow('ISV (15%)', 'L ${pedidoParaView.impuestos}'),
            buildRow('TOTAL', 'L ${factura.total}'),
            pw.SizedBox(height: 10),
            pw.Divider(color: PdfColors.black),
            pw.SizedBox(height: 10),
            pw.Text(
              NumberToWordsEs.convertNumberToWords(factura.total!),
              style: estilo,
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'CAI ${datosFacturacion.cai}',
                style: estilo.copyWith(fontSize: 8),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Rango autorizado',
                style: estilo,
              ),
            ),
            pw.Center(
              child: pw.Text(
                '000-001-01-$rangoInicialString a 000-001-01-$rangoFinalString',
                style: estilo.copyWith(fontSize: 8),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Fecha límite de emisión: $fechaLimiteEmision',
                style: estilo,
              ),
            ),
            pw.SizedBox(height: 10),
            buildRow('Original:', 'Cliente'),
            buildRow('Copia:', 'Obligado Tributario Emisor'),
            pw.SizedBox(height: 25),
          ],
        );
      },
    ),
  );

  return doc.save();
}
