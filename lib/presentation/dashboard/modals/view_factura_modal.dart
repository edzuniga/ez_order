import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as web;

import 'package:ez_order_ezr/data/datos_factura_modelo.dart';
import 'package:ez_order_ezr/data/pedido_detalle_model.dart';
import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/presentation/providers/facturacion/detalles_pedido_para_view.dart';
import 'package:ez_order_ezr/utils/invoice_pdf.dart';
import 'package:ez_order_ezr/utils/numbers_to_words.dart';
import 'package:ez_order_ezr/data/factura_modelo.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/facturacion/datos_factura_provider.dart';
import 'package:ez_order_ezr/presentation/providers/facturacion/pedido_para_view.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';

class ViewFacturaModal extends ConsumerStatefulWidget {
  const ViewFacturaModal({required this.factura, super.key});
  final FacturaModelo factura;

  @override
  ConsumerState<ViewFacturaModal> createState() => _ViewFacturaModalState();
}

class _ViewFacturaModalState extends ConsumerState<ViewFacturaModal> {
  final GlobalKey<State> _shareButtonKey = GlobalKey<State>();
  bool _isRetrievingInfo = true;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _retrieveInfoPedidoYDetalles();
  }

  Future<void> _retrieveInfoPedidoYDetalles() async {
    await ref
        .read(supabaseManagementProvider.notifier)
        .getPedidoPorUuid(widget.factura.uuidPedido);
    await ref
        .read(detallesParaPedidoViewProvider.notifier)
        .getYSetListado(widget.factura.uuidPedido);
    setState(() => _isRetrievingInfo = false);
  }

  @override
  Widget build(BuildContext context) {
    DatosFacturaModelo datosFacturacion =
        ref.watch(datosFacturaManagerProvider);
    PedidoModel pedidoParaView = ref.watch(pedidoParaViewProvider);
    List<PedidoDetalleModel> detallesPedido =
        ref.watch(detallesParaPedidoViewProvider);

//--------tratamiento de las variables
    //----Numero de factura con ceros
    String resultadoNumFactura = '';
    String numeroFacturaString = widget.factura.numFactura.toString();
    for (int i = 1; i <= 8 - numeroFacturaString.length; i++) {
      resultadoNumFactura += '0';
    }
    resultadoNumFactura += numeroFacturaString;
    String rangoInicialString = '';
    String rangoInicialStr = datosFacturacion.rangoInicial.toString();
    for (int i = 1; i <= 8 - rangoInicialStr.length; i++) {
      rangoInicialString += '0';
    }
    rangoInicialString += rangoInicialStr;
    String rangoFinalString = '';
    String rangoFinalStr = datosFacturacion.rangoFinal.toString();
    for (int i = 1; i <= 8 - rangoFinalStr.length; i++) {
      rangoFinalString += '0';
    }
    rangoFinalString += rangoFinalStr;
    //Format date
    String formattedDate =
        DateFormat.yMMMEd('es').format(widget.factura.fechaFactura);
    String formattedTime =
        DateFormat('h:mm a').format(widget.factura.fechaFactura);

    //Fecha límite de emisión
    String fechaLimiteEmision = datosFacturacion.fechaLimite != null
        ? datosFacturacion.fechaLimite.toString().substring(0, 10)
        : '';

//--------tratamiento de las variables
    return Container(
      height: 800,
      width: 320,
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 10,
          color: AppColors.kInputLiteGray,
        ),
        color: Colors.white,
      ),
      child: _isRetrievingInfo //|| _isGeneratingPdf
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                  datosFacturacion.nombreNegocio.isNotEmpty
                      ? Center(
                          child: Text(
                            datosFacturacion.nombreNegocio,
                            style: GoogleFonts.archivoNarrow(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        )
                      : const SizedBox(),
                  datosFacturacion.rtn.isNotEmpty
                      ? Center(child: Text(datosFacturacion.rtn))
                      : const SizedBox(),
                  datosFacturacion.direccion.isNotEmpty
                      ? Center(
                          child: SizedBox(
                            child: Text(
                              datosFacturacion.direccion,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const SizedBox(),
                  datosFacturacion.correo.isNotEmpty
                      ? Center(child: Text(datosFacturacion.correo))
                      : const SizedBox(),
                  datosFacturacion.telefono.isNotEmpty
                      ? Center(child: Text(datosFacturacion.telefono))
                      : const SizedBox(),
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
                  resultadoNumFactura != '00000000'
                      ? Text('000-001-01-$resultadoNumFactura')
                      : const SizedBox(),
                  Text('$formattedDate | $formattedTime'),
                  const Gap(10),
                  const Divider(
                    color: Colors.black,
                  ),
                  const Gap(10),
                  Text(
                    'Cliente: ${widget.factura.nombreCliente.toString()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'RTN: ${widget.factura.rtn.toString()}',
                  ),
                  const Text('NO. O/C EXENTA:'),
                  const Text('NO.REG DE EXONERADO:'),
                  const Text('NO. REG DE LA SAG:'),
                  const Gap(10),
                  Table(
                    columnWidths: const {
                      0: FixedColumnWidth(35),
                      1: FlexColumnWidth(),
                      2: FixedColumnWidth(70),
                    },
                    children: [
                      const TableRow(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide()),
                          ),
                          children: [
                            Text('UDS'),
                            Text('DESCRIPCIÓN'),
                            Text('IMPORTE'),
                          ]),
                      ...detallesPedido.map((element) {
                        double precioOriginal =
                            (element.importeCobrado / element.cantidad);
                        return TableRow(
                          children: [
                            Text(element.cantidad.toString()),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(element.nombreMenuItem.toString()),
                                Text(
                                    '1.0 x L ${precioOriginal.toStringAsFixed(2)}'),
                              ],
                            ),
                            Text(
                                'L ${element.importeCobrado.toStringAsFixed(2)}'),
                          ],
                        );
                      })
                    ],
                  ),
                  const Gap(20),
                  Text(detallesPedido.length == 1
                      ? '1 Artículo'
                      : '${detallesPedido.length} Artículos'),
                  const Gap(10),
                  const Divider(
                    color: Colors.black,
                  ),
                  const Gap(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SUB-TOTAL'),
                      const Gap(15),
                      Text('L ${pedidoParaView.subtotal}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('DESCUENTOS Y REBAJAS'),
                      const Gap(15),
                      Text('L ${pedidoParaView.descuento}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('IMPORTE EXENTO'),
                      const Gap(15),
                      Text('L ${pedidoParaView.importeExento}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('IMPORTE GRAVADO'),
                      const Gap(15),
                      Text('L ${pedidoParaView.importeGravado}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ISV (15%)'),
                      const Gap(15),
                      Text('L ${pedidoParaView.impuestos}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL'),
                      const Gap(15),
                      Text('L ${widget.factura.total}'),
                    ],
                  ),
                  const Gap(10),
                  const Divider(
                    color: Colors.black,
                  ),
                  const Gap(10),
                  SizedBox(
                    height: 60,
                    child: Text(NumberToWordsEs.convertNumberToWords(
                        widget.factura.total!)),
                  ),
                  const Gap(10),
                  Center(
                    child: Text(
                      'CAI ${datosFacturacion.cai}',
                      style: const TextStyle(
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
                  Center(
                    child: Text(
                      '000-001-01-$rangoInicialString a 000-001-01-$rangoFinalString',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Fecha límite de emisión: $fechaLimiteEmision',
                      style: const TextStyle(
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
                  const Gap(25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //ENVIAR
                      IconButton(
                        key: _shareButtonKey,
                        onPressed: () async {
                          if (kIsWeb) {
                            _isGeneratingPdf
                                ? null
                                : await _generateAndDownloadPdf(
                                    widget.factura,
                                    datosFacturacion,
                                    detallesPedido,
                                    pedidoParaView);
                          } else {
                            _isGeneratingPdf
                                ? null
                                : await _generateAndShare(
                                    widget.factura,
                                    datosFacturacion,
                                    detallesPedido,
                                    pedidoParaView);
                          }
                        },
                        tooltip: 'Compartir',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.kGeneralPrimaryOrange,
                        ),
                        icon: kIsWeb
                            ? const Icon(
                                Icons.download,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.share,
                                color: Colors.white,
                              ),
                      ),

                      const Gap(15),
                      //IMPRIMIR
                      IconButton(
                        onPressed: () async {
                          await _generatePdfAndPrint(widget.factura,
                              datosFacturacion, detallesPedido, pedidoParaView);
                        },
                        tooltip: 'Imprimir',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        icon: const Icon(
                          Icons.print,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Future<File> _generateAndSavePdf(
      FacturaModelo factura,
      DatosFacturaModelo datosFacturacion,
      List<PedidoDetalleModel> detallesPedido,
      PedidoModel pedidoParaView) async {
    // Generar el archivo PDF
    final pdfData = await generateFacturaPdf(
        factura, datosFacturacion, detallesPedido, pedidoParaView);

    // Guardar el archivo PDF en el directorio temporal
    final output = await getTemporaryDirectory();
    final file = File(
        "${output.path}/factura_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(pdfData);

    return file;
  }

  Future<void> _generateAndDownloadPdf(
      FacturaModelo factura,
      DatosFacturaModelo datosFacturacion,
      List<PedidoDetalleModel> detallesPedido,
      PedidoModel pedidoParaView) async {
    // Generar el archivo PDF
    final pdfData = await generateFacturaPdf(
        factura, datosFacturacion, detallesPedido, pedidoParaView);

    List<int> fileInts = List.from(pdfData);
    // Crear un enlace y hacer clic para descargar el archivo
    final url =
        "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}";
    web.AnchorElement(href: url)
      ..setAttribute("download", "${DateTime.now().millisecondsSinceEpoch}.pdf")
      ..click();
  }

  Future<void> _sharePdf(File file) async {
    final xFile = XFile(file.path);

    // Esperar hasta que el widget se haya construido completamente
    await Future.delayed(const Duration(milliseconds: 100));

    RenderBox? box;
    while (_shareButtonKey.currentContext == null) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    box = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;

    if (box != null) {
      // Obtener la posición del botón
      final position = box.localToGlobal(Offset.zero) & box.size;

      // Compartir el archivo PDF (Para Móviles)
      await Share.shareXFiles(
        [xFile],
        text: 'Aquí está tu recibo en PDF',
        sharePositionOrigin: position,
      );
    } else {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: 'Pruebe nuevamente',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
        webPosition: 'center',
        webBgColor: 'red',
      );
    }
    setState(() => _isGeneratingPdf = false);
  }

  Future<void> _generateAndShare(
      FacturaModelo factura,
      DatosFacturaModelo datosFacturacion,
      List<PedidoDetalleModel> detallesPedido,
      PedidoModel pedidoParaView) async {
    setState(() => _isGeneratingPdf = true);

    // Generar y guardar el PDF
    final file = await _generateAndSavePdf(
        factura, datosFacturacion, detallesPedido, pedidoParaView);

    // Compartir el PDF
    await _sharePdf(file);
  }

  Future<void> _generatePdfAndPrint(
      FacturaModelo factura,
      DatosFacturaModelo datosFacturacion,
      List<PedidoDetalleModel> detallesPedido,
      PedidoModel pedidoParaView) async {
    final pdfData = await generateFacturaPdf(
        factura, datosFacturacion, detallesPedido, pedidoParaView);
    // Definir el formato de página de 80mm
    const receiptFormat = PdfPageFormat(
      80 * PdfPageFormat.mm,
      double.infinity,
      marginTop: 10 * PdfPageFormat.mm,
      marginBottom: 10 * PdfPageFormat.mm,
      marginLeft: 3 * PdfPageFormat.mm,
      marginRight: 3 * PdfPageFormat.mm,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      format: receiptFormat,
    );
  }
}
