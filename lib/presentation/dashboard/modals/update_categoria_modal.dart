import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/data/categoria_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/categorias/listado_categorias.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class UpdateCategoriaModal extends ConsumerStatefulWidget {
  const UpdateCategoriaModal({required this.catRecibida, super.key});
  final CategoriaModelo catRecibida;

  @override
  ConsumerState<UpdateCategoriaModal> createState() => _CategoriaModalState();
}

class _CategoriaModalState extends ConsumerState<UpdateCategoriaModal> {
  final TextEditingController _categoriaController = TextEditingController();
  bool _isTryingToUpdateCategoria = false;
  final GlobalKey<FormState> _updateCatFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _categoriaController.text = widget.catRecibida.nombreCategoria;
  }

  @override
  void dispose() {
    _categoriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
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
      child: _isTryingToUpdateCategoria
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Form(
                key: _updateCatFormKey,
                child: Column(
                  children: [
                    //Título
                    const Text(
                      'Actualizar nombre de categoría',
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
                        controller: _categoriaController,
                        autofillHints: const [AutofillHints.name],
                        decoration: InputDecoration(
                          labelText: 'Actualizar categoría',
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
                            if (_updateCatFormKey.currentState!.validate()) {
                              int resId = int.parse(ref
                                  .read(
                                      userPublicDataProvider)['id_restaurante']
                                  .toString());
                              CategoriaModelo cat = CategoriaModelo(
                                idCategoria: widget.catRecibida.idCategoria,
                                nombreCategoria: _categoriaController.text,
                                idRestaurante: resId,
                                activo: true,
                              );
                              //Agregar la nueva categoría y recargar el query
                              _tryActualizarCategoria(cat);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kGeneralPrimaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Actualizar categoría',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    /*const Gap(10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Inactivar categoría',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),*/
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _tryActualizarCategoria(CategoriaModelo cat) async {
    setState(() => _isTryingToUpdateCategoria = true);
    await ref
        .read(supabaseManagementProvider.notifier)
        .actualizarCategoria(cat)
        .then((message) async {
      setState(() => _isTryingToUpdateCategoria = false);
      if (message == 'success') {
        await setCategoriasButtons();
        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.blue,
          content: Text(
            'Actualizado exitosamente!!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ));
        context.pop();
      } else {
        context.pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Ocurrió un error al intentar actualizar la categoría -> $message',
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

  Future<void> setCategoriasButtons() async {
    List<CategoriaModelo> listadoCats =
        await ref.read(supabaseManagementProvider.notifier).obtenerCategorias();
    ref.read(listadoCategoriasProvider.notifier).setCategorias(listadoCats);
  }
}
