import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class DatosFacturacionView extends ConsumerStatefulWidget {
  const DatosFacturacionView({super.key});

  @override
  ConsumerState<DatosFacturacionView> createState() => _AdminViewState();
}

class _AdminViewState extends ConsumerState<DatosFacturacionView> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _rtnNegocioController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _caiController = TextEditingController();
  final TextEditingController _rangoInicialController = TextEditingController();
  final TextEditingController _rangoFinalController = TextEditingController();
  final TextEditingController _fechaLimiteEmision = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _rtnNegocioController.dispose();
    _direccionController.dispose();
    _correoController.dispose();
    _telController.dispose();
    _caiController.dispose();
    _rangoInicialController.dispose();
    _rangoFinalController.dispose();
    _fechaLimiteEmision.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 15,
      ),
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Form(
        child: Column(
          children: [
            Text(
              'Ingresar nuevos datos',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const Gap(20),
            //Nombre
            Row(
              children: [
                //NOMBRE
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _nombreController,
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(
                      labelText: 'Nombre del negocio',
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
                ),
              ],
            ),
            const Gap(10),
            //Fecha límite y RTN
            Row(
              children: [
                //NOMBRE
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          DateTime hoy = DateTime.now();
                          DateTime lastDate =
                              DateTime(hoy.year + 3, hoy.month, hoy.day);
                          await showDatePicker(
                            context: context,
                            firstDate: hoy,
                            lastDate: lastDate,
                          ).then((value) {
                            if (value != null) {
                              _fechaLimiteEmision.text =
                                  value.toString().substring(0, 10);
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.calendar_month_outlined,
                          color: AppColors.kGeneralPrimaryOrange,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: TextFormField(
                          enabled: false,
                          controller: _fechaLimiteEmision,
                          autofillHints: const [AutofillHints.name],
                          decoration: InputDecoration(
                            labelText: 'Fecha límite de emisión',
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
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                //RTN
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _rtnNegocioController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(14),
                    ],
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(
                      labelText: 'RTN del negocio',
                      labelStyle: GoogleFonts.inter(
                        color: AppColors.kTextPrimaryBlack,
                      ),
                      hintText: 'Solamente números...',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.black26,
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
                ),
              ],
            ),
            const Gap(10),
            //Dirección, Correo y Teléfono
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //DIRECCIÓN
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    maxLines: 4,
                    controller: _direccionController,
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(
                      labelText: 'Dirección del negocio',
                      labelStyle: GoogleFonts.inter(
                        color: AppColors.kTextPrimaryBlack,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obligatorio';
                      }

                      return null;
                    },
                  ),
                ),
                const Gap(10),
                //CORREO y TELÉFONO
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _correoController,
                        autofillHints: const [AutofillHints.name],
                        decoration: InputDecoration(
                          labelText: 'Correo del negocio',
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
                          if (!EmailValidator.validate(value)) {
                            return 'ingrese un correo válido';
                          }

                          return null;
                        },
                      ),
                      const Gap(15),
                      TextFormField(
                        controller: _telController,
                        autofillHints: const [AutofillHints.name],
                        decoration: InputDecoration(
                          labelText: 'Teléfono del negocio',
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
                    ],
                  ),
                ),
              ],
            ),
            const Gap(10),
            const Divider(
              color: AppColors.kGeneralFadedGray,
            ),
            const Gap(10),
            //CAI
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _caiController,
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(
                      labelText: 'Código CAI',
                      labelStyle: GoogleFonts.inter(
                        color: AppColors.kTextPrimaryBlack,
                      ),
                      hintText: 'xxxxxx-xxxxxx-xxxxxx-xxxxxx-xxxxxx-xx',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obligatorio';
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),
            const Gap(10),
            //RANGO INICIAL Y FINAL
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Rango Inicial
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _rangoInicialController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(
                      labelText: 'Rango autorizado inicial',
                      labelStyle: GoogleFonts.inter(
                        color: AppColors.kTextPrimaryBlack,
                      ),
                      hintText: 'Ej. 00000001',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obligatorio';
                      }

                      return null;
                    },
                  ),
                ),
                const Gap(10),
                //Rango Final
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _rangoInicialController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Rango autorizado final',
                      labelStyle: GoogleFonts.inter(
                        color: AppColors.kTextPrimaryBlack,
                      ),
                      hintText: 'Ej. 00000100',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obligatorio';
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),
            const Gap(25),
            //Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
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
                  onPressed: () async {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kGeneralPrimaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Guardar datos',
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
