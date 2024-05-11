import 'package:email_validator/email_validator.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RecoveryView extends StatefulWidget {
  const RecoveryView({super.key});

  @override
  State<RecoveryView> createState() => _RecoveryViewState();
}

class _RecoveryViewState extends State<RecoveryView> {
  final GlobalKey<FormState> _recoveryFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F6F6),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 50,
      ),
      child: SizedBox(
        height: double.infinity,
        width: 570,
        child: Form(
          key: _recoveryFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  context.goNamed(Routes.login);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.kTextPrimaryBlack,
                      size: 24.0,
                    ),
                    const Gap(15),
                    Text(
                      'Regresar',
                      style: GoogleFonts.inter(),
                    ),
                  ],
                ),
              ),
              const Gap(20),
              Text(
                '¿Olvidó su contraseña?',
                style: GoogleFonts.roboto(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                'Ingrese el correo electrónico asociado a su cuenta; le enviaremos un correo con el enlace para restablecer su contraseña.',
                style: GoogleFonts.inter(),
              ),
              const Gap(15),
              TextFormField(
                controller: _emailController,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico...',
                  labelStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.kTextPrimaryBlack,
                  ),
                  hintText: 'Ingrese su correo electrónico...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: AppColors.kGeneralFadedGray,
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
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsetsDirectional.fromSTEB(
                      24.0, 24.0, 20.0, 24.0),
                ),
                style: GoogleFonts.inter(),
                maxLines: null,
                keyboardType: TextInputType.emailAddress,
                cursorColor: AppColors.kGeneralPrimaryOrange,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }

                  if (!EmailValidator.validate(value)) {
                    return 'Ingrese un correo válido';
                  }

                  return null;
                },
              ),
              const Gap(24),
              Center(
                child: SizedBox(
                  width: 280,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_recoveryFormKey.currentState!.validate()) {}
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kGeneralOrangeBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Restaurar contraseña',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
