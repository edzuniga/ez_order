import 'package:ez_order_ezr/presentation/providers/facturacion/detalles_pedido_para_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
  bool _isRetrievingInfo = true;

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
    final datosFacturacion = ref.watch(datosFacturaManagerProvider);
    final pedidoParaView = ref.watch(pedidoParaViewProvider);
    final detallesPedido = ref.watch(detallesParaPedidoViewProvider);

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
      child: _isRetrievingInfo
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
                  Center(
                    child: Text(
                      datosFacturacion.nombreNegocio,
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Center(child: Text(datosFacturacion.rtn)),
                  Center(
                    child: SizedBox(
                      //width: 200,
                      child: Text(
                        datosFacturacion.direccion,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Center(child: Text(datosFacturacion.correo)),
                  Center(child: Text(datosFacturacion.telefono)),
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
                  Text('000-001-01-$resultadoNumFactura'),
                  Text('$formattedDate | $formattedTime'),
                  const Gap(10),
                  const Divider(
                    color: Colors.black,
                  ),
                  const Gap(10),
                  Text(
                    widget.factura.nombreCliente.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('NO. O/C EXENTA:'),
                  const Text('NO.REG DE EXONERADO:'),
                  const Text('NO. REG DE LA SAG:'),
                  const Gap(10),
                  Table(
                    columnWidths: const {
                      0: FixedColumnWidth(40),
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
                        return TableRow(
                          children: [
                            Text(element.cantidad.toString()),
                            Text(element.nombreMenuItem.toString()),
                            Text('L 30.00'),
                          ],
                        );
                      })
                    ],
                  ),
                  const Gap(20),
                  Text('${detallesPedido.length} Artículos'),
                  const Gap(10),
                  const Divider(
                    color: Colors.black,
                  ),
                  const Gap(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('SUB-TOTAL'),
                      const Gap(15),
                      Text('L ${pedidoParaView.subtotal}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('DESCUENTOS Y REBAJAS'),
                      const Gap(15),
                      Text('L ${pedidoParaView.descuento}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('IMPORTE EXENTO'),
                      const Gap(15),
                      Text('L ${pedidoParaView.importeExento}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('IMPORTE GRAVADO'),
                      const Gap(15),
                      Text('L ${pedidoParaView.importeGravado}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('ISV (15%)'),
                      const Gap(15),
                      Text('L ${pedidoParaView.impuestos}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                  const SizedBox(
                    height: 60,
                    child: Text(
                        'CIENTO TREINTA Y DOS MIL LEMPIRAS CON 25/100 CENTAVOS'),
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
                      'Fecha límite de emisión: ${datosFacturacion.fechaLimite.toString().substring(0, 10)}',
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
                ],
              ),
            ),
    );
  }
}
