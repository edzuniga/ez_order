import 'dart:convert';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as web;
import 'package:flutter/material.dart';

import 'package:ez_order_ezr/utils/ingresos_table_pdf.dart';

Future<void> exportDataTableToPDFAndDownload(List<DataRow> rows,
    DateTime initialDate, DateTime finalDate, int tipo) async {
  Uint8List? pdfData;
  if (tipo == 1) {
    pdfData = await generateIngresosTablePdf(rows, initialDate, finalDate);
  } else if (tipo == 2) {
    pdfData =
        await generateVentasPorProductoTablePdf(rows, initialDate, finalDate);
  } else {
    pdfData = await generateMovimientosInventarioTablePdf(
        rows, initialDate, finalDate);
  }

  List<int> fileInts = List.from(pdfData);
  // Crear un enlace y hacer clic para descargar el archivo
  final url =
      "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}";
  web.AnchorElement(href: url)
    ..setAttribute("download", "${DateTime.now().millisecondsSinceEpoch}.pdf")
    ..click();
}
