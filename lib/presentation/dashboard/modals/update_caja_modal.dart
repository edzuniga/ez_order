import 'package:animate_do/animate_do.dart';
import 'package:ez_order_ezr/data/caja_apertura_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class UpdateCajaModal extends ConsumerStatefulWidget {
  const UpdateCajaModal({required this.id, super.key});
  final int id;

  @override
  ConsumerState<UpdateCajaModal> createState() => _AperturarCajaModalState();
}

class _AperturarCajaModalState extends ConsumerState<UpdateCajaModal> {
  final TextEditingController _cantidadInicialController =
      TextEditingController();
  final GlobalKey<FormState> _aperturarCajaFormKey = GlobalKey<FormState>();
  bool _isSendingData = false;
  late CajaAperturaModelo cajaApertura;

  @override
  void initState() {
    super.initState();
    _getCajaAperturaDatos();
  }

  Future<void> _getCajaAperturaDatos() async {
    cajaApertura = await ref
        .read(supabaseManagementProvider.notifier)
        .getCajaApertura(widget.id);
    _cantidadInicialController.text = cajaApertura.cantidad.toString();
  }

  @override
  void dispose() {
    _cantidadInicialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
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
        child: Form(
          key: _aperturarCajaFormKey,
          child: Column(
            children: [
              //Título
              const Text(
                '¿Con cuánto efectivo aperturará caja hoy?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Gap(25),
              //Nuevo ticket (Input)
              SizedBox(
                width: 250,
                child: TextFormField(
                  controller: _cantidadInicialController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  autofillHints: const [AutofillHints.name],
                  decoration: InputDecoration(
                    labelText: 'Efectivo inicial en caja',
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
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Campo requerido';
                    }
                    return null;
                  },
                ),
              ),
              const Gap(35),
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
                            if (_aperturarCajaFormKey.currentState!
                                .validate()) {
                              setState(() => _isSendingData = true);
                              CajaAperturaModelo nuevoModelo =
                                  cajaApertura.copyWith(
                                cantidad: double.parse(
                                    _cantidadInicialController.text),
                              );
                              await ref
                                  .read(supabaseManagementProvider.notifier)
                                  .actualizarCajaApertura(nuevoModelo);
                              setState(() => _isSendingData = false);
                              if (!context.mounted) return;
                              Navigator.of(context).pop(true);
                            }
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
                            'Actualizar',
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
}
