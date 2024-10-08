import 'package:animate_do/animate_do.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/config/routes.dart';
import 'package:ez_order_ezr/presentation/providers/auth_supabase_manager.dart';
import 'package:ez_order_ezr/presentation/widgets/link_text_widget.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isTryingLogin = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.kGeneralOrangeBg, AppColors.kGeneralFadedOrange],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.87, -1.0),
          end: AlignmentDirectional(-0.87, 1.0),
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Gap(70),
              //Logo de EZOrder
              Container(
                width: 337.0,
                height: 108.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Image.asset(
                  'assets/images/EZOrderlogowhite.png',
                  width: 300.0,
                  height: 200.0,
                  fit: BoxFit.contain,
                ),
              ),
              const Gap(10),
              //Container principal con el formulario
              Container(
                width: 400.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BIENVENIDO',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            fontSize: 32.0,
                            color: AppColors.kTextPrimaryBlack,
                          ),
                        ),
                        const Gap(12),
                        Text(
                          'Inicie sesión con sus credenciales',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.0,
                            color: AppColors.kTextSecondaryGray,
                          ),
                        ),
                        const Gap(24),
                        //Input de correo
                        TextFormField(
                          controller: _emailController,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            labelStyle: GoogleFonts.inter(
                              color: AppColors.kTextPrimaryBlack,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white,
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
                              return 'Ingrese un correo válido';
                            }

                            return null;
                          },
                        ),
                        const Gap(16),
                        //Input de Contraseña
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _isObscured,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: GoogleFonts.inter(
                              color: AppColors.kTextPrimaryBlack,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white,
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
                            suffixIcon: InkWell(
                              onTap: () {
                                setState(() => _isObscured = !_isObscured);
                              },
                              child: Icon(
                                _isObscured
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.kIconGrayishIcon,
                                size: 24.0,
                              ),
                            ),
                          ),
                          style: GoogleFonts.inter(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obligatorio';
                            }

                            if (value.length < 6) {
                              return 'Debe ser de al menos 6 caracteres';
                            }

                            return null;
                          },
                        ),
                        const Gap(28),
                        //Botón para login
                        SizedBox(
                          height: 45,
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor: AppColors.kGeneralOrangeBg,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  )),
                              onPressed: () async {
                                _isTryingLogin ? null : await _trylogin();
                              },
                              child: _isTryingLogin
                                  ? SpinPerfect(
                                      infinite: true,
                                      child: const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                      ))
                                  : Text(
                                      'Iniciar sesión',
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )),
                        ),
                        const Gap(28),
                        //Botón para ir a Recover Password
                        /*Center(
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              context.goNamed(Routes.recovery);
                            },
                            child: RichText(
                              textScaler: MediaQuery.of(context).textScaler,
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: '¿Perdiste tu contraseña? - ',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: 'Restaurar',
                                    style: GoogleFonts.inter(
                                      color: AppColors.kTextSecondaryGray,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                                style: GoogleFonts.inter(
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Gap(12), */
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(40),
              //Ícono inferior
              const Icon(
                Icons.restaurant_outlined,
                color: Colors.white,
                size: 30.0,
              ),
              const Gap(30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '© 2024 ',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await _launchUrlWeb();
                    },
                    child: const LinkText(
                      textito: 'EZ Order.',
                      colorcito: Colors.white,
                    ),
                  ),
                  Text(
                    ' Todos los derechos reservados.',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _trylogin() async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() => _isTryingLogin = true);
      String loginTryMessage =
          await ref.read(authManagerProvider.notifier).tryLogin(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim(),
              );
      setState(() => _isTryingLogin = false);
      if (loginTryMessage == 'success') {
        if (!mounted) return;
        context.goNamed(Routes.pedidos);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.kGeneralErrorColor,
            content: Text(
              loginTryMessage == 'Invalid login credentials'
                  ? 'Revise su correo y contraseña!!'
                  : loginTryMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  Future<void> _launchUrlWeb() async {
    const url = 'https://ezorderhn.com/';
    final Uri parsedUrl = Uri.parse(url);

    if (await canLaunchUrl(parsedUrl)) {
      await launchUrl(parsedUrl);
    } else {
      throw 'No se pudo abrir $url';
    }
  }
}
