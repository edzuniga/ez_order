import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/num_pedido_actual.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TicketModal extends ConsumerStatefulWidget {
  const TicketModal({super.key});

  @override
  ConsumerState<TicketModal> createState() => _TicketModalState();
}

class _TicketModalState extends ConsumerState<TicketModal> {
  final TextEditingController _numeroTicketController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 235,
      width: 350,
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
              'Asignar # de ticket manualmente',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Gap(25),
            //Nuevo ticket (Input)
            SizedBox(
              width: 250,
              child: TextField(
                controller: _numeroTicketController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(
                  labelText: 'Nuevo número de ticket',
                  labelStyle: GoogleFonts.inter(
                    color: AppColors.kTextPrimaryBlack,
                  ),
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
                    if (_numeroTicketController.text.isNotEmpty) {
                      //Change current ticket number
                      int newValue = int.parse(_numeroTicketController.text);
                      ref
                          .read(numeroPedidoActualProvider.notifier)
                          .setCustomNumeroPedido(newValue);
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
                    'Nuevo # de Ticket',
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
