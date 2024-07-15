import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/providers/menus_providers/descuento_provider.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class DescuentoMobileModal extends ConsumerStatefulWidget {
  const DescuentoMobileModal({super.key});

  @override
  ConsumerState<DescuentoMobileModal> createState() =>
      _DescuentoMobileModalState();
}

class _DescuentoMobileModalState extends ConsumerState<DescuentoMobileModal> {
  final GlobalKey<FormState> _descuentoFormKey = GlobalKey<FormState>();
  final TextEditingController _descuentoController = TextEditingController();

  @override
  void dispose() {
    _descuentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 250,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _descuentoFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Escriba el descuento que aplicará en esta orden',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(25),
              TextFormField(
                controller: _descuentoController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(
                  labelText: 'Descuento',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }

                  return null;
                },
              ),
              const Gap(25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.pop(false);
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
                    onPressed: () async {
                      await _tryAplicarDescuento();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kGeneralPrimaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Aplicar descuento',
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
      ),
    );
  }

  Future<void> _tryAplicarDescuento() async {
    if (_descuentoFormKey.currentState!.validate()) {
      double descuento = double.parse(_descuentoController.text);
      ref
          .read(descuentoPedidoActualProvider.notifier)
          .actualizarDescuento(descuento);
      context.pop(true);
    }
  }
}
