import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/pedido_actual_provider.dart';

class NotaAdicionalModal extends ConsumerStatefulWidget {
  const NotaAdicionalModal({super.key});

  @override
  ConsumerState<NotaAdicionalModal> createState() => _TicketModalState();
}

class _TicketModalState extends ConsumerState<NotaAdicionalModal> {
  final TextEditingController _notaAdicionalController =
      TextEditingController();

  @override
  void dispose() {
    _notaAdicionalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 235,
      width: 450,
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
              'Nota adicional del pedido',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Gap(25),
            //Nuevo ticket (Input)
            SizedBox(
              width: 350,
              child: TextField(
                controller: _notaAdicionalController,
                decoration: InputDecoration(
                  hintText: 'Nota adicional de la orden...',
                  border: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E3E7), width: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.kTextPrimaryBlack,
                ),
              ),
            ),
            const Gap(35),
            //Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.pop();
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
                  onPressed: () {
                    if (_notaAdicionalController.text.isNotEmpty) {
                      //Change current nota adicional
                      _cambiarNotaAdicional();
                      context.pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kGeneralPrimaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Guardar nota adicional',
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

  void _cambiarNotaAdicional() {
    //Incorporar la nota adicional
    final pedidoActual = ref.read(pedidoActualProvider.notifier);
    pedidoActual.asignarNotaAdicional(_notaAdicionalController.text);
  }
}
