import 'package:email_validator/email_validator.dart';
import 'package:ez_order_ezr/data/cliente_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class ClienteModal extends ConsumerStatefulWidget {
  const ClienteModal({super.key});

  @override
  ConsumerState<ClienteModal> createState() => _DeleteMenuItemModalState();
}

class _DeleteMenuItemModalState extends ConsumerState<ClienteModal> {
  final GlobalKey<FormState> _clienteFormKey = GlobalKey<FormState>();
  final TextEditingController _rtnController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  bool _clienteExonerado = false;
  bool _isTryingUpload = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 500,
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
                key: _clienteFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Datos del nuevo cliente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(25),
                    //RTN
                    TextFormField(
                      controller: _rtnController,
                      autofillHints: const [AutofillHints.name],
                      decoration: InputDecoration(
                        labelText: 'RTN',
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
                    const Gap(15),
                    //Nombre del cliente
                    TextFormField(
                      controller: _nombreController,
                      autofillHints: const [AutofillHints.name],
                      decoration: InputDecoration(
                        labelText: 'Nombre del cliente',
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
                    //Correo del cliente
                    TextFormField(
                      controller: _correoController,
                      autofillHints: const [AutofillHints.name],
                      decoration: InputDecoration(
                        labelText: 'Correo del cliente',
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
                        if (v != null &&
                            v.isNotEmpty &&
                            !EmailValidator.validate(v)) {
                          return 'ingrese un correo válido';
                        }
                        return null;
                      },
                    ),
                    const Gap(15),
                    Row(
                      children: [
                        const Text('¿Exonerado de impuesto?'),
                        const Gap(4),
                        Transform.scale(
                          scale: 0.7,
                          child: CupertinoSwitch(
                            value: _clienteExonerado,
                            onChanged: (v) {
                              setState(() {
                                _clienteExonerado = !_clienteExonerado;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const Gap(25),
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
                          onPressed: () async {
                            final clienteNuevo = ClienteModelo(
                              rtnCliente: _rtnController.text,
                              nombreCliente: _nombreController.text,
                              correoCliente: _correoController.text,
                              descuentoCliente: 0.0,
                              idRestaurante: int.parse(ref
                                  .read(
                                      userPublicDataProvider)['id_restaurante']
                                  .toString()),
                              exonerado: _clienteExonerado,
                            );
                            await _tryAgregarCliente(clienteNuevo);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kGeneralPrimaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Agregar cliente',
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

  Future<void> _tryAgregarCliente(ClienteModelo clienteNuevo) async {
    if (_clienteFormKey.currentState!.validate()) {
      //llamar la única instancia de supabase
      final supabaseClient = ref.read(supabaseManagementProvider.notifier);
      setState(() => _isTryingUpload = true);
      await supabaseClient.agregarCliente(clienteNuevo).then((message) {
        setState(() => _isTryingUpload = false);
        if (message == 'success') {
          context.pop();
        } else {
          context.pop();
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Ocurrió un error al intentar agregar el cliente -> $message',
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
