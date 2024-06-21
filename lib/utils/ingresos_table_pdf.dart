import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<Uint8List> generateIngresosTablePdf(
    List<DataRow> dataRows, DateTime desde, DateTime hasta) async {
  final doc = pw.Document();

// Define the page format with margins
  const pageFormat = PdfPageFormat.letter;

  pw.Font columnasFont = await PdfGoogleFonts.robotoCondensedBold();

  // Convert DataRow to List<List<String>>
  List<List<String>> data = dataRows.map((row) {
    return row.cells.map((cell) {
      return (cell.child as Text).data!;
    }).toList();
  }).toList();

  //Formato de fechas
  String desdeFormateada = DateFormat.yMMMEd('es').format(desde);
  String hastaFormateada = DateFormat.yMMMEd('es').format(hasta);

  doc.addPage(
    pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Container(
              width: double.infinity,
              height: double.infinity,
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'Detalle de Pedidos Realizados',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Center(
                    child: pw.Text(
                        'Entre las siguientes fechas: $desdeFormateada al $hastaFormateada'),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Divider(),
                  pw.SizedBox(height: 5),
                  pw.TableHelper.fromTextArray(
                    headerAlignment: pw.Alignment.centerLeft,
                    columnWidths: const {
                      0: pw.FixedColumnWidth(50),
                      1: pw.FlexColumnWidth(),
                      2: pw.FixedColumnWidth(60),
                      3: pw.FixedColumnWidth(70),
                      4: pw.FixedColumnWidth(80),
                    },
                    context: context,
                    border: const pw.TableBorder(bottom: pw.BorderSide()),
                    headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        font: columnasFont,
                        fontSize: 10),
                    headers: [
                      '# Orden',
                      'Detalle pedido',
                      'Total (L)',
                      'Fecha',
                      'Método de pago'
                    ],
                    data: data,
                  ),
                ],
              ));
        }),
  );
  return doc.save();
}
