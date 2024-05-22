import 'package:ez_order_ezr/data/menu_item_model.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AgregarMenuModal extends ConsumerStatefulWidget {
  const AgregarMenuModal({super.key});

  @override
  ConsumerState<AgregarMenuModal> createState() => _AgregarMenuModalState();
}

class _AgregarMenuModalState extends ConsumerState<AgregarMenuModal> {
  final GlobalKey<FormState> _agregarMenuKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _correlativoController = TextEditingController();
  final TextEditingController _informacionAdicionalController =
      TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _correlativoController.dispose();
    _informacionAdicionalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 554.0,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: const Color(0xFFF6F6F6),
                width: 1.0,
              ),
            ),
            child: Form(
              key: _agregarMenuKey,
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/pedidos.jpg',
                        width: double.infinity,
                        height: 233.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.black))),
                      child: Text(
                        'Subir imagen',
                        style: GoogleFonts.inter(
                          color: AppColors.kTextPrimaryBlack,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              controller: _nombreController,
                              autofillHints: const [AutofillHints.name],
                              decoration: InputDecoration(
                                labelText: 'Nombre',
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
                          const Gap(8),
                          Expanded(
                            child: TextFormField(
                              controller: _precioController,
                              autofillHints: const [AutofillHints.name],
                              decoration: InputDecoration(
                                labelText: 'Precio',
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
                      const Gap(12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              controller: _descripcionController,
                              autofillHints: const [AutofillHints.name],
                              decoration: InputDecoration(
                                labelText: 'Descripción',
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
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obligatorio';
                                }

                                return null;
                              },
                            ),
                          ),
                          const Gap(8),
                          Expanded(
                            child: TextFormField(
                              controller: _correlativoController,
                              autofillHints: const [AutofillHints.name],
                              decoration: InputDecoration(
                                labelText: 'Correlativo',
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
                      const Gap(12),
                      TextFormField(
                        controller: _informacionAdicionalController,
                        autofillHints: const [AutofillHints.name],
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Información adicional',
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
                              if (_agregarMenuKey.currentState!.validate()) {
                                //Crear el menuItemModel que se mandará a Supa
                                final menuItem = MenuItemModel(
                                  numMenu: _correlativoController.text,
                                  descripcion: _descripcionController.text,
                                  otraInfo:
                                      _informacionAdicionalController.text,
                                  img: 'pendiente',
                                  precio: double.parse(_precioController.text),
                                  nombreItem: _nombreController.text,
                                );
                                await _tryAddMenu(menuItem);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kGeneralPrimaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Agregar producto',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _tryAddMenu(MenuItemModel menuItemModel) async {
    //llamar la única instancia de supabase
    final supabaseClient = ref.read(supabaseManagementProvider.notifier);
    await supabaseClient.addMenuItem(menuItemModel).then((message) {
      if (message == 'success') {
        //context.pop();
      } else {
        //context.pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Ocurrió un error al intentar agregar el ítem de menú -> $message',
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
