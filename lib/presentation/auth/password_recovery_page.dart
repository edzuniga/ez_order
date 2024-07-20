import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ez_order_ezr/presentation/providers/auth_supabase_manager.dart';
import 'package:ez_order_ezr/presentation/widgets/link_text_widget.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/config/routes.dart';

class PasswordRecoveryPage extends ConsumerStatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  ConsumerState<PasswordRecoveryPage> createState() =>
      _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends ConsumerState<PasswordRecoveryPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordConfirmationController =
      TextEditingController();
  final GlobalKey<FormState> _pwRecoverFormKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isObscureConfirmation = true;
  bool _puedeAcceder = false;
  bool _passwordSuccesfullyChanged = false;
  bool _tryingPasswordChange = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  _checkAuthentication() {
    final supa = ref.read(supabaseManagementProvider);
    final session = supa.auth.currentSession;

    if (session != null) {
      setState(() {
        _puedeAcceder = true;
      });
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _newPasswordConfirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _puedeAcceder
          ? Center(
              child: SizedBox(
                width: 500,
                child: Form(
                  key: _pwRecoverFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.kGeneralPrimaryOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'images/EZOrderlogowhite.png',
                          ),
                        ),
                        const Gap(25),
                        Text(
                          'Ingrese su nueva contraseña',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const Gap(15),
                        //Input de Password
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: _newPasswordController,
                            obscureText: _isObscure,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() => _isObscure = !_isObscure);
                                },
                                child: Icon(
                                  _isObscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.kIconGrayishIcon,
                                  size: 24.0,
                                ),
                              ),
                              labelText: 'Nueva contraseña',
                              labelStyle: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.kTextPrimaryBlack,
                              ),
                              hintText: 'Nueva contraseña...',
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
                              contentPadding:
                                  const EdgeInsetsDirectional.fromSTEB(
                                      24.0, 24.0, 20.0, 24.0),
                            ),
                            style: GoogleFonts.inter(),
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: AppColors.kGeneralPrimaryOrange,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obligatorio';
                              }

                              if (value.length < 6) {
                                return 'Debe contener al menos 6 caracteres';
                              }

                              return null;
                            },
                          ),
                        ),
                        const Gap(10),
                        //Input de Confirmación de Password
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: _newPasswordConfirmationController,
                            obscureText: _isObscureConfirmation,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() => _isObscureConfirmation =
                                      !_isObscureConfirmation);
                                },
                                child: Icon(
                                  _isObscureConfirmation
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.kIconGrayishIcon,
                                  size: 24.0,
                                ),
                              ),
                              labelText: 'Confirmar contraseña',
                              labelStyle: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.kTextPrimaryBlack,
                              ),
                              hintText: 'Confirmar contraseña...',
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
                              contentPadding:
                                  const EdgeInsetsDirectional.fromSTEB(
                                      24.0, 24.0, 20.0, 24.0),
                            ),
                            style: GoogleFonts.inter(),
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: AppColors.kGeneralPrimaryOrange,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obligatorio';
                              }

                              if (value.length < 6) {
                                return 'Debe contener al menos 6 caracteres';
                              }

                              return null;
                            },
                          ),
                        ),
                        const Gap(20),
                        Center(
                          child: SizedBox(
                            width: 280,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                _tryingPasswordChange
                                    ? null
                                    : _tryPasswordChange();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.kGeneralOrangeBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _tryingPasswordChange
                                  ? Center(
                                      child: SpinPerfect(
                                        infinite: true,
                                        child: const Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'Restablecer contraseña',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        _passwordSuccesfullyChanged
                            ? const Gap(30)
                            : const SizedBox(),
                        _passwordSuccesfullyChanged
                            ? Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Su contraseña ha sido cambiada exitosamente.\nPuede iniciar sesión con su nueva contraseña. Si necesita más ayuda, no dude en contactarnos.',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : const SizedBox(),
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
                      ],
                    ),
                  ),
                ),
              ),
            )
          : SafeArea(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'images/error_page_img.png',
                            width: 538.0,
                            height: 420.0,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const Gap(20),
                        ElevatedButton(
                          onPressed: () => context.goNamed(Routes.login),
                          style: ElevatedButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: AppColors.kGeneralPrimaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              )),
                          child: Text(
                            'Ir a inicio',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _tryPasswordChange() async {
    if (_pwRecoverFormKey.currentState!.validate()) {
      //Chequear que ambas contraseñas son iguales
      if (_newPasswordController.text ==
          _newPasswordConfirmationController.text) {
        setState(() => _tryingPasswordChange = true);
        SupabaseClient supabase = ref.read(supabaseManagementProvider);
        try {
          await supabase.auth.updateUser(
            UserAttributes(
              password: _newPasswordController.text,
            ),
          );

          _newPasswordController.clear();
          _newPasswordConfirmationController.clear();

          setState(() {
            _tryingPasswordChange = false;
            _passwordSuccesfullyChanged = true;
          });
          await ref.read(authManagerProvider.notifier).tryLogout();
        } on PostgrestException catch (e) {
          setState(() => _tryingPasswordChange = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                'Contraseña actualizada con éxito!!',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
          throw 'Ocurrió un error: $e';
        }
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Las contraseñas NO coinciden!!',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
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
