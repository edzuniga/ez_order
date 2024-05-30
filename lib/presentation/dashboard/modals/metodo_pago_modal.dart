import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/metodo_pago_actual.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/pedido_actual_provider.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/pedido_detalles_provider.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/utils/metodo_pago_enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class MetodoPagoModal extends ConsumerStatefulWidget {
  const MetodoPagoModal({super.key});

  @override
  ConsumerState<MetodoPagoModal> createState() => _MetodoPagoModalState();
}

class _MetodoPagoModalState extends ConsumerState<MetodoPagoModal> {
  final TextEditingController _notaPedido = TextEditingController();
  bool _isTryingUpload = false;

  @override
  Widget build(BuildContext context) {
    PedidoModel pedidoActualInfo = ref.watch(pedidoActualProvider);
    MetodoDePagoEnum metodoSeleccionado = ref.watch(metodoPagoActualProvider);
    return Container(
      height: 450,
      width: 500,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
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
                        'Seleccione el método de pago para esta orden',
                        style: GoogleFonts.inter(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                      const Gap(40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              const Icon(
                                Icons.money,
                                size: 60,
                                color: AppColors.kGeneralPrimaryOrange,
                              ),
                              const Gap(5),
                              Text(
                                'Efectivo',
                                style: GoogleFonts.inter(fontSize: 16),
                              ),
                              const Gap(5),
                              CupertinoRadio(
                                  value: MetodoDePagoEnum.efectivo,
                                  groupValue: metodoSeleccionado,
                                  onChanged: (v) {
                                    _setMetodoDePago(v!);
                                  }),
                            ],
                          ),
                          const Gap(65),
                          Column(
                            children: [
                              const Icon(
                                Icons.credit_card,
                                size: 60,
                                color: AppColors.kGeneralPrimaryOrange,
                              ),
                              const Gap(5),
                              Text(
                                'Tarjeta',
                                style: GoogleFonts.inter(fontSize: 16),
                              ),
                              const Gap(5),
                              CupertinoRadio(
                                  value: MetodoDePagoEnum.tarjeta,
                                  groupValue: metodoSeleccionado,
                                  onChanged: (v) {
                                    _setMetodoDePago(v!);
                                  }),
                            ],
                          ),
                          const Gap(65),
                          Column(
                            children: [
                              const Icon(
                                Icons.mobile_friendly_rounded,
                                size: 60,
                                color: AppColors.kGeneralPrimaryOrange,
                              ),
                              const Gap(5),
                              Text(
                                'Transferencia',
                                style: GoogleFonts.inter(fontSize: 16),
                              ),
                              const Gap(5),
                              CupertinoRadio(
                                  value: MetodoDePagoEnum.transferencia,
                                  groupValue: metodoSeleccionado,
                                  onChanged: (v) {
                                    _setMetodoDePago(v!);
                                  }),
                            ],
                          ),
                        ],
                      ),
                      const Gap(20),
                      //Nota adicional del pedido
                      TextFormField(
                        controller: _notaPedido,
                        autofillHints: const [AutofillHints.name],
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Nota adicional',
                          labelStyle: GoogleFonts.inter(
                            color: AppColors.kTextPrimaryBlack,
                          ),
                          hintText: 'Ej. Algo sobre la orden actual...',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.black26,
                          ),
                          alignLabelWithHint: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFe0e3e7),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.kGeneralPrimaryOrange,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.kGeneralErrorColor,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.kGeneralErrorColor,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: AppColors.kInputLiteGray,
                        ),
                        style: GoogleFonts.inter(),
                      ),

                      const Gap(40),
                      SizedBox(
                        width: 350,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _tryConfirmarPedido();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kGeneralPrimaryOrange,
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
