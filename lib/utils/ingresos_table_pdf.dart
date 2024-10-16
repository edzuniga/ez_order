import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<Uint8List> generateIngresosTablePdf(
    List<DataRow> dataRows, DateTime desde, DateTime hasta) async {
  final doc = pw.Document();

  const pageFormat = PdfPageFormat.letter;

  pw.Font columnasFont = await PdfGoogleFonts.robotoCondensedBold();

  // Convert DataRow to List<List<String>>
  List<List<String>> data = dataRows.map((row) {
    return row.cells.map((cell) {
      return (cell.child as Text).data!;
    }).toList();
  }).toList();

  // Formato de fechas
  String desdeFormateada = DateFormat.yMMMEd('es').format(desde);
  String hastaFormateada = DateFormat.yMMMEd('es').format(hasta);

  // Función para dividir los datos en fragmentos
  List<List<List<String>>> splitDataIntoChunks(
      List<List<String>> data, int chunkSize) {
    List<List<List<String>>> chunks = [];
    for (var i = 0; i < data.length; i += chunkSize) {
      int end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      chunks.add(data.sublist(i, end));
    }
    return chunks;
  }

  // Dividir los datos en fragmentos de 8 filas
  List<List<List<String>>> dataChunks = splitDataIntoChunks(data, 8);

  // Crear una nueva página para cada fragmento
  for (var chunk in dataChunks) {
    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                    'Entre las siguientes fechas: $desdeFormateada al $hastaFormateada',
                  ),
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
                  border: const pw.TableBorder(bottom: pw.BorderSide()),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    font: columnasFont,
                    fontSize: 10,
                  ),
                  headers: [
                    '# Orden',
                    'Detalle pedido',
                    'Total (L)',
                    'Fecha',
                    'Método de pago',
                  ],
                  data: chunk,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  return doc.save();
}

Future<Uint8List> generateVentasPorProductoTablePdf(
    List<DataRow> dataRows, DateTime desde, DateTime hasta) async {
  final doc = pw.Document();

  const pageFormat = PdfPageFormat.letter;

  pw.Font columnasFont = await PdfGoogleFonts.robotoCondensedBold();

  // Convert DataRow to List<List<String>>
  List<List<String>> data = dataRows.map((row) {
    return row.cells.map((cell) {
      return (cell.child as Text).data!;
    }).toList();
  }).toList();

  // Formato de fechas
  String desdeFormateada = DateFormat.yMMMEd('es').format(desde);
  String hastaFormateada = DateFormat.yMMMEd('es').format(hasta);

  // Función para dividir los datos en fragmentos
  List<List<List<String>>> splitDataIntoChunks(
      List<List<String>> data, int chunkSize) {
    List<List<List<String>>> chunks = [];
    for (var i = 0; i < data.length; i += chunkSize) {
      int end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      chunks.add(data.sublist(i, end));
    }
    return chunks;
  }

  // Dividir los datos en fragmentos de 8 filas
  List<List<List<String>>> dataChunks = splitDataIntoChunks(data, 8);

  // Crear una nueva página para cada fragmento
  for (var chunk in dataChunks) {
    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Ventas por producto',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Entre las siguientes fechas: $desdeFormateada al $hastaFormateada',
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Divider(),
                pw.SizedBox(height: 5),
                pw.TableHelper.fromTextArray(
                  headerAlignment: pw.Alignment.centerLeft,
                  columnWidths: const {
                    0: pw.FlexColumnWidth(),
                    1: pw.FixedColumnWidth(60),
                    2: pw.FixedColumnWidth(80),
                  },
                  border: const pw.TableBorder(bottom: pw.BorderSide()),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    font: columnasFont,
                    fontSize: 10,
                  ),
                  headers: [
                    'Producto',
                    'Cantidad',
                    'Total (L)',
                  ],
                  data: chunk,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  return doc.save();
}

Future<Uint8List> generateMovimientosInventarioTablePdf(
    List<DataRow> dataRows, DateTime desde, DateTime hasta) async {
  final doc = pw.Document();

  const pageFormat = PdfPageFormat.letter;

  pw.Font columnasFont = await PdfGoogleFonts.robotoCondensedBold();

  // Convert DataRow to List<List<String>>
  List<List<String>> data = dataRows.map((row) {
    return row.cells.map((cell) {
      return (cell.child as Text).data!;
    }).toList();
  }).toList();

  // Formato de fechas
  String desdeFormateada = DateFormat.yMMMEd('es').format(desde);
  String hastaFormateada = DateFormat.yMMMEd('es').format(hasta);

  // Función para dividir los datos en fragmentos
  List<List<List<String>>> splitDataIntoChunks(
      List<List<String>> data, int chunkSize) {
    List<List<List<String>>> chunks = [];
    for (var i = 0; i < data.length; i += chunkSize) {
      int end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      chunks.add(data.sublist(i, end));
    }
    return chunks;
  }

  // Dividir los datos en fragmentos de 8 filas
  List<List<List<String>>> dataChunks = splitDataIntoChunks(data, 8);

  // Crear una nueva página para cada fragmento
  for (var chunk in dataChunks) {
    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Movimientos del Inventario',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Entre las siguientes fechas: $desdeFormateada al $hastaFormateada',
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Divider(),
                pw.SizedBox(height: 5),
                pw.TableHelper.fromTextArray(
                  headerAlignment: pw.Alignment.centerLeft,
                  columnWidths: const {
                    0: pw.FlexColumnWidth(),
                    1: pw.FixedColumnWidth(60),
                    2: pw.FlexColumnWidth(80),
                    3: pw.FixedColumnWidth(80),
                  },
                  border: const pw.TableBorder(bottom: pw.BorderSide()),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    font: columnasFont,
                    fontSize: 10,
                  ),
                  headers: [
                    'Producto',
                    'Movimiento',
                    'Descripción',
                    'Cantidad',
                  ],
                  data: chunk,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  return doc.save();
}
