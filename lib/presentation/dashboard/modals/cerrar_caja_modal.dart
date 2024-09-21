import 'package:animate_do/animate_do.dart';
import 'package:ez_order_ezr/data/caja_apertura_modelo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/providers/caja/caja_abierta.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class CerrarCajaModal extends ConsumerStatefulWidget {
  const CerrarCajaModal({required this.cajaApertura, super.key});
  final CajaAperturaModelo cajaApertura;

  @override
  ConsumerState<CerrarCajaModal> createState() => _CerrarCajaModalState();
}

class _CerrarCajaModalState extends ConsumerState<CerrarCajaModal> {
  bool _isSendingData = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 250,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(
          width: 5,
          color: const Color(0xFFDFE3E7),
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            //Título
            const Text(
              '¿Está seguro de cerrar la caja?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Gap(25),

            //Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Gap(8),
                ElevatedButton(
                  onPressed: _isSendingData
                      ? () {}
                      : () async {
                          setState(() => _isSendingData = true);

                          //Calcular el valor que debe estar en caja
                          double cierreCajavalor = await ref
                              .read(supabaseManagementProvider.notifier)
                              .calcularTotalCierreCaja(
                                  widget.cajaApertura.restauranteUid);
                          //Actualizar el valor de caja
                          CajaAperturaModelo modelo =
                              widget.cajaApertura.copyWith(
                            cantidadCierre: cierreCajavalor,
                          );
                          await ref
                              .read(supabaseManagementProvider.notifier)
                              .actualizarCajaApertura(modelo);
                          //Cambiar el estado de la CAJA (abierta/cerrada)
                          ref
                              .read(supabaseManagementProvider.notifier)
                              .statusCaja(
                                  widget.cajaApertura.restauranteUid, false);
                          //refrescar el estado local del status de la caja
                          ref.read(cajaAbiertaProvider.notifier).refresh();
                          setState(() => _isSendingData = false);
                          if (!context.mounted) return;
                          Navigator.of(context).pop(true);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kGeneralPrimaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSendingData
                      ? SpinPerfect(
                          infinite: true,
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Cerrar',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
