import 'package:animate_do/animate_do.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/config/routes.dart';

class RecoveryView extends ConsumerStatefulWidget {
  const RecoveryView({super.key});

  @override
  ConsumerState<RecoveryView> createState() => _RecoveryViewState();
}

class _RecoveryViewState extends ConsumerState<RecoveryView> {
  final GlobalKey<FormState> _recoveryFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _correoEnviado = false;
  bool _isTryingToSendEmail = false;

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
                    onPressed: () async {
                      _isTryingToSendEmail ? null : await _tryToSendEmail();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kGeneralOrangeBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isTryingToSendEmail
                        ? Center(
                            child: SpinPerfect(
                                infinite: true,
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                )),
                          )
                        : Text(
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
              const Gap(30),
              _correoEnviado
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Correo enviado!!\nPor favor revise su correo y siga las instrucciones para restablecer su contraseña.\nRevise también en correo no deseado.',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _tryToSendEmail() async {
    if (_recoveryFormKey.currentState!.validate()) {
      setState(() => _isTryingToSendEmail = true);
      SupabaseClient supabase = ref.read(supabaseManagementProvider);
      try {
        //Primero revisar que el correo exista
        final res = await supabase
            .from('usuarios_info')
            .select('email')
            .eq('email', _emailController.text)
            .limit(1);

        //En caso que existe
        if (res.isNotEmpty) {
          await supabase.auth.resetPasswordForEmail(_emailController.text,
              redirectTo: 'https://app.ezorderhn.com/pw_recovery');

          setState(() {
            _correoEnviado = true;
          });
          _emailController.clear();
          setState(() => _isTryingToSendEmail = false);
        } else {
          setState(() => _isTryingToSendEmail = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Este correo no se encuentra registrado!!',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ));
        }
      } on PostgrestException catch (e) {
        throw 'Ocurrió un error: $e';
      }
    }
  }
}
