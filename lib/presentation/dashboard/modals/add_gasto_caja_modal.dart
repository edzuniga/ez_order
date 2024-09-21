import 'package:ez_order_ezr/data/registro_caja_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class AddGastoModal extends ConsumerStatefulWidget {
  const AddGastoModal({super.key});

  @override
  ConsumerState<AddGastoModal> createState() => _DeleteMenuItemModalState();
}

class _DeleteMenuItemModalState extends ConsumerState<AddGastoModal> {
  final GlobalKey<FormState> _gastoCajaKey = GlobalKey<FormState>();
  final TextEditingController _cantidad = TextEditingController();
  final TextEditingController _proveedor = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();
  bool _isTryingUpload = false;

  @override
  void dispose() {
    _cantidad.dispose();
    _proveedor.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 410,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: _isTryingUpload
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text(
                  'Por favor espere!!',
                  style: TextStyle(
                    color: AppColors.kTextPrimaryBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Form(
                key: _gastoCajaKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Registro de gasto de CAJA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(25),
                    //CANTIDAD
                    TextFormField(
                      controller: _cantidad,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
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
                    const Gap(15),
                    //PROVEEDOR
                    TextFormField(
                      controller: _proveedor,
                      decoration: InputDecoration(
                        labelText: 'Proveedor',
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
                    const Gap(15),
                    //DESCRIPCIÓN
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _descripcion,
                        autofillHints: const [AutofillHints.name],
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          labelStyle: GoogleFonts.inter(
                            color: AppColors.kTextPrimaryBlack,
                          ),
                          hintText: 'Qué se compró y qué cantidad...',
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
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obligatorio';
                          }

                          return null;
                        },
                      ),
                    ),
                    const Gap(25),
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
                          onPressed: () async {
                            final datosRes = ref
                                .read(userPublicDataProvider)['id_restaurante'];
                            int idRes = 0;
                            if (datosRes != null) {
                              idRes = int.parse(datosRes);
                            }

                            RegistroCajaModelo registroCaja =
                                RegistroCajaModelo(
                              createdAt: DateTime.now(),
                              restauranteId: idRes,
                              ingreso: null,
                              egreso: double.parse(_cantidad.text),
                              proveedor: _proveedor.text,
                              descripcion: _descripcion.text,
                            );

                            await _tryAgregarGasto(registroCaja);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kGeneralPrimaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Agregar gasto',
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

  Future<void> _tryAgregarGasto(RegistroCajaModelo registroCaja) async {
    if (_gastoCajaKey.currentState!.validate()) {
      //llamar la única instancia de supabase
      final supabaseClient = ref.read(supabaseManagementProvider.notifier);
      setState(() => _isTryingUpload = true);
      await supabaseClient.agregarGastoCaja(registroCaja).then((message) {
        setState(() => _isTryingUpload = false);
        if (message == 'success') {
          if (!mounted) return;
          Navigator.of(context).pop(true);
        } else {
          if (!mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Ocurrió un error al intentar agregar el registro -> $message',
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
}
