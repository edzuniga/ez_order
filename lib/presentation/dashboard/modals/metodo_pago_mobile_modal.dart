import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/metodo_pago_actual.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/pedido_actual_provider.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/utils/metodo_pago_enum.dart';

class MetodoPagoMobileModal extends ConsumerStatefulWidget {
  const MetodoPagoMobileModal({super.key});

  @override
  ConsumerState<MetodoPagoMobileModal> createState() =>
      _MetodoPagoMobileModalState();
}

class _MetodoPagoMobileModalState extends ConsumerState<MetodoPagoMobileModal> {
  bool _isTryingUpload = false;

  @override
  Widget build(BuildContext context) {
    PedidoModel pedidoActualInfo = ref.watch(pedidoActualProvider);
    MetodoDePagoEnum metodoSeleccionado = ref.watch(metodoPagoActualProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        height: 600,
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
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
            : SingleChildScrollView(
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
                                  _setMetodoDePago(MetodoDePagoEnum.efectivo);
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                  _setMetodoDePago(MetodoDePagoEnum.tarjeta);
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset('assets/svg/tarjeta.svg',
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                  _setMetodoDePago(MetodoDePagoEnum.delivery);
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                        const Gap(30),
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
                        onPressed: () => context.pop(false),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.kGeneralFadedGray,
                        ),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
      ),
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
        context.pop(true);
      } else {
        context.pop(false);
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
