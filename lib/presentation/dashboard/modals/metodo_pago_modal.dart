import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/metodo_pago_actual.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/pedido_actual_provider.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/utils/metodo_pago_enum.dart';

class MetodoPagoModal extends ConsumerStatefulWidget {
  const MetodoPagoModal({super.key});

  @override
  ConsumerState<MetodoPagoModal> createState() => _MetodoPagoModalState();
}

class _MetodoPagoModalState extends ConsumerState<MetodoPagoModal> {
  bool _isTryingUpload = false;
  final TextEditingController _conCuantoPagaCliente = TextEditingController();
  double vuelto = 0.00;
  int userIdRestaurante = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      userIdRestaurante = int.parse(
          ref.read(userPublicDataProvider)['id_restaurante'].toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    PedidoModel pedidoActualInfo = ref.watch(pedidoActualProvider);
    MetodoDePagoEnum metodoSeleccionado = ref.watch(metodoPagoActualProvider);
    return Container(
      height: 700,
      width: 500,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 20,
          color: const Color(0xFFDFE3E7),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _isTryingUpload
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Gap(10),
                  Text('Por favor espere'),
                ],
              ),
            )
          : FutureBuilder(
              future: ref
                  .read(supabaseManagementProvider.notifier)
                  .cajaCerradaoAbierta(userIdRestaurante),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Por favor espere.'),
                        CircularProgressIndicator(),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Ocurrió un error!!'),
                  );
                }

                if (snapshot.data!) {
                  return SingleChildScrollView(
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Gap(20),
                            Text(
                              'Método de pago',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.kTextPrimaryBlack,
                              ),
                            ),
                            const Gap(5),
                            Text(
                              'Seleccione el método de pago',
                              style: GoogleFonts.inter(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                            const Gap(30),
                            //EFECTIVO y TARJETA
                            Row(
                              children: [
                                //EFECTIVO
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      _setMetodoDePago(
                                          MetodoDePagoEnum.efectivo);
                                    },
                                    child: Container(
                                      height: 128,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: metodoSeleccionado ==
                                                  MetodoDePagoEnum.efectivo
                                              ? AppColors.kGeneralPrimaryOrange
                                              : const Color(0xFFE1E1E1),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                              'assets/svg/efectivo.svg',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.contain,
                                              semanticsLabel: 'Efectivo'),
                                          const Gap(5),
                                          Text(
                                            'Efectivo',
                                            style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap(10),
                                //TARJETA
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      _setMetodoDePago(
                                          MetodoDePagoEnum.tarjeta);
                                    },
                                    child: Container(
                                      height: 128,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: metodoSeleccionado ==
                                                  MetodoDePagoEnum.tarjeta
                                              ? AppColors.kGeneralPrimaryOrange
                                              : const Color(0xFFE1E1E1),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                              'assets/svg/tarjeta.svg',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.contain,
                                              semanticsLabel: 'Tarjeta'),
                                          const Gap(5),
                                          Text(
                                            'Tarjeta',
                                            style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(10),
                            //TRANSFERENCIA y DELIVERY
                            Row(
                              children: [
                                //TRANSFERENCIA
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      _setMetodoDePago(
                                          MetodoDePagoEnum.transferencia);
                                    },
                                    child: Container(
                                      height: 128,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: metodoSeleccionado ==
                                                  MetodoDePagoEnum.transferencia
                                              ? AppColors.kGeneralPrimaryOrange
                                              : const Color(0xFFE1E1E1),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                              'assets/svg/transferencia.svg',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.contain,
                                              semanticsLabel: 'Transferencia'),
                                          const Gap(5),
                                          Text(
                                            'Transferencia',
                                            style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap(10),
                                //DELIVERY
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      _setMetodoDePago(
                                          MetodoDePagoEnum.delivery);
                                    },
                                    child: Container(
                                      height: 128,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: metodoSeleccionado ==
                                                  MetodoDePagoEnum.delivery
                                              ? AppColors.kGeneralPrimaryOrange
                                              : const Color(0xFFE1E1E1),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                              'assets/svg/delivery.svg',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.contain,
                                              semanticsLabel: 'Delivery'),
                                          const Gap(5),
                                          Text(
                                            'Delivery',
                                            style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(15),

                            metodoSeleccionado == MetodoDePagoEnum.efectivo
                                ? Row(
                                    children: [
                                      const Gap(10),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            const Text(
                                                '¿Con cuánto efectivo pagará el cliente?'),
                                            TextField(
                                              controller: _conCuantoPagaCliente,
                                              onChanged: (value) {
                                                if (value == '') {
                                                  setState(() {
                                                    vuelto = 0.00;
                                                  });
                                                } else {
                                                  setState(() {
                                                    vuelto =
                                                        double.parse(value) -
                                                            pedidoActualInfo
                                                                .total;
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Gap(10),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            const Text('El vuelto es de:'),
                                            Text(
                                              'L $vuelto',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Gap(10),
                                    ],
                                  )
                                : const SizedBox(),

                            const Gap(15),
                            //Detalles de factura (subtotal, impuesto, importe..., etc..)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.kInputLiteGray,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ExpansionTile(
                                dense: true,
                                title: const Text(
                                  'Detalles de facturación',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                                trailing:
                                    const Icon(Icons.arrow_drop_down_outlined),
                                children: [
                                  //Área de Subtotal
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Gap(15),
                                      const Icon(
                                        Icons.circle_outlined,
                                        color: AppColors.kTextSecondaryGray,
                                        size: 8,
                                      ),
                                      const Gap(5),
                                      Text(
                                        'Subtotal:',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'L ${pedidoActualInfo.subtotal}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      const Gap(15),
                                    ],
                                  ),
                                  //Área de Exonerado
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Gap(15),
                                      const Icon(
                                        Icons.circle_outlined,
                                        color: AppColors.kTextSecondaryGray,
                                        size: 8,
                                      ),
                                      const Gap(5),
                                      Text(
                                        'Importe exonerado:',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'L ${pedidoActualInfo.importeExonerado}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      const Gap(15),
                                    ],
                                  ),
                                  //Área de Exento
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Gap(15),
                                      const Icon(
                                        Icons.circle_outlined,
                                        color: AppColors.kTextSecondaryGray,
                                        size: 8,
                                      ),
                                      const Gap(5),
                                      Text(
                                        'Importe exento:',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'L ${pedidoActualInfo.importeExento}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      const Gap(15),
                                    ],
                                  ),
                                  //Área de Gravado
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Gap(15),
                                      const Icon(
                                        Icons.circle_outlined,
                                        color: AppColors.kTextSecondaryGray,
                                        size: 8,
                                      ),
                                      const Gap(5),
                                      Text(
                                        'Importe gravado:',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'L ${pedidoActualInfo.importeGravado}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      const Gap(15),
                                    ],
                                  ),
                                  //Área de descuento
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Gap(15),
                                      const Icon(
                                        Icons.circle_outlined,
                                        color: AppColors.kTextSecondaryGray,
                                        size: 8,
                                      ),
                                      const Gap(5),
                                      Text(
                                        'Descuento:',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'L ${pedidoActualInfo.descuento}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      const Gap(15),
                                    ],
                                  ),
                                  //Área de ISV
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Gap(15),
                                      const Icon(
                                        Icons.circle_outlined,
                                        color: AppColors.kTextSecondaryGray,
                                        size: 8,
                                      ),
                                      const Gap(5),
                                      Text(
                                        'ISV (15%):',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'L ${pedidoActualInfo.impuestos}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      const Gap(15),
                                    ],
                                  ),
                                  const Gap(5),
                                ],
                              ),
                            ),

                            const Gap(40),
                            SizedBox(
                              width: 350,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _tryConfirmarPedido();
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.kGeneralPrimaryOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    )),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Confirmar orden por ',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                          text: 'L ${pedidoActualInfo.total}',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.kGeneralFadedGray,
                            ),
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.yellow,
                            ),
                            Text('La caja se encuentra cerrada!!'),
                          ],
                        ),
                        const Gap(15),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kGeneralPrimaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Regresar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }),
    );
  }

  void _setMetodoDePago(MetodoDePagoEnum v) {
    ref.read(metodoPagoActualProvider.notifier).updateMetodoPago(v);
  }

  Future<void> _tryConfirmarPedido() async {
    final supabaseClient = ref.read(supabaseManagementProvider.notifier);
    setState(() => _isTryingUpload = true);
    PedidoModel pedidoActual = ref.read(pedidoActualProvider);
    await supabaseClient.agregarPedido(pedidoActual).then((message) {
      setState(() => _isTryingUpload = false);
      if (message == 'success') {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } else {
        if (!mounted) return;
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Ocurrió un error al intentar agregar el ítem de menú -> $message',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ));
      }
    });
  }
}
