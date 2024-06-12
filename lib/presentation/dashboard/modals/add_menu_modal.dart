import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:ez_order_ezr/data/categoria_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/categorias/categoria_seleccionada.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:ez_order_ezr/data/menu_item_model.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';

class AgregarMenuModal extends ConsumerStatefulWidget {
  const AgregarMenuModal({super.key});

  @override
  ConsumerState<AgregarMenuModal> createState() => _AgregarMenuModalState();
}

class _AgregarMenuModalState extends ConsumerState<AgregarMenuModal> {
  final GlobalKey<FormState> _agregarMenuKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioSinIsvController = TextEditingController();
  final TextEditingController _precioConIsvController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _correlativoController = TextEditingController();
  final TextEditingController _informacionAdicionalController =
      TextEditingController();
  bool _precioIncluyeIsvSelected = false;
  bool _vaParaCocinaSelected = true;
  File? _selectedImage;
  bool _isTryingUpload = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriaActualProvider.notifier).resetCategoriaSeleccionada();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioSinIsvController.dispose();
    _precioConIsvController.dispose();
    _descripcionController.dispose();
    _correlativoController.dispose();
    _informacionAdicionalController.dispose();
    super.dispose();
  }

  Future<List<CategoriaModelo>> _getCategoriasForDropdown() async {
    return await ref
        .read(supabaseManagementProvider.notifier)
        .obtenerCategorias();
  }

  Widget imagenDisplay = Image.asset(
    'assets/images/pedidos.jpg',
    width: double.infinity,
    height: 233.0,
    fit: BoxFit.cover,
  );

  @override
  Widget build(BuildContext context) {
    CategoriaModelo categoriaSeleccionada = ref.watch(categoriaActualProvider);
    return _isTryingUpload
        ? Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: const Column(
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
            ),
          )
        : SingleChildScrollView(
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
                            child: imagenDisplay,
                          ),
                        ),
                        const Gap(12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                _seleccionarImagen();
                              },
                              style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(
                                          color: Colors.black))),
                              child: Text(
                                'Subir imagen',
                                style: GoogleFonts.inter(
                                  color: AppColors.kTextPrimaryBlack,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        Column(
                          children: [
                            //Nombre y correlativo
                            Row(
                              children: [
                                //Nombre del producto
                                SizedBox(
                                  width: 350,
                                  child: TextFormField(
                                    controller: _nombreController,
                                    autofillHints: const [AutofillHints.name],
                                    decoration: InputDecoration(
                                      labelText: 'Nombre del producto',
                                      labelStyle: GoogleFonts.inter(
                                        color: AppColors.kTextPrimaryBlack,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0xFFe0e3e7),
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color:
                                              AppColors.kGeneralPrimaryOrange,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: AppColors.kGeneralErrorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: AppColors.kGeneralErrorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
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
                                //Correlativo del producto
                                Expanded(
                                  child: TextFormField(
                                    controller: _correlativoController,
                                    autofillHints: const [AutofillHints.name],
                                    decoration: InputDecoration(
                                      labelText: 'Correlativo',
                                      labelStyle: GoogleFonts.inter(
                                        color: AppColors.kTextPrimaryBlack,
                                      ),
                                      hintText: 'Ej. 1, a, #1...',
                                      hintStyle: GoogleFonts.inter(
                                        color: Colors.black26,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0xFFe0e3e7),
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color:
                                              AppColors.kGeneralPrimaryOrange,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: AppColors.kGeneralErrorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: AppColors.kGeneralErrorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
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
                            //Descripción y precios
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Descripción del producto
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
                                      hintText:
                                          'Descripción general de lo que incluye el plato u otra información...',
                                      hintStyle: GoogleFonts.inter(
                                        color: Colors.black26,
                                      ),
                                      alignLabelWithHint: true,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0xFFe0e3e7),
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color:
                                              AppColors.kGeneralPrimaryOrange,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: AppColors.kGeneralErrorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: AppColors.kGeneralErrorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
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
                                //Precios
                                Expanded(
                                  child: Column(
                                    children: [
                                      //Precio SIN ISV
                                      SizedBox(
                                        height: 48,
                                        child: TextFormField(
                                          controller: _precioSinIsvController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}')),
                                          ],
                                          autofillHints: const [
                                            AutofillHints.name
                                          ],
                                          decoration: InputDecoration(
                                            labelText: 'Precio',
                                            labelStyle: GoogleFonts.inter(
                                              color:
                                                  AppColors.kTextPrimaryBlack,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFe0e3e7),
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: AppColors
                                                    .kGeneralPrimaryOrange,
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: AppColors
                                                    .kGeneralErrorColor,
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: AppColors
                                                    .kGeneralErrorColor,
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            filled: true,
                                            fillColor: AppColors.kInputLiteGray,
                                          ),
                                          style: GoogleFonts.inter(),
                                          onChanged: (v) {
                                            if (v == '' || v.isEmpty) {
                                              _precioConIsvController.text =
                                                  '0.00';
                                            } else {
                                              _calcularPrecioDeVenta();
                                            }
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Campo obligatorio';
                                            }

                                            return null;
                                          },
                                        ),
                                      ),
                                      const Gap(10),
                                      //Precio CON ISV
                                      SizedBox(
                                        height: 45,
                                        child: TextFormField(
                                          controller: _precioConIsvController,
                                          enabled: false,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}')),
                                          ],
                                          autofillHints: const [
                                            AutofillHints.name
                                          ],
                                          decoration: InputDecoration(
                                            labelText: 'Precio de venta',
                                            labelStyle: GoogleFonts.inter(
                                              color:
                                                  AppColors.kTextPrimaryBlack,
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFe0e3e7),
                                                width: 0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFe0e3e7),
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: AppColors
                                                    .kGeneralPrimaryOrange,
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: AppColors
                                                    .kGeneralErrorColor,
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: AppColors
                                                    .kGeneralErrorColor,
                                                width: 2.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFe0e3e7),
                                          ),
                                          style: GoogleFonts.inter(),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Campo obligatorio';
                                            }

                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Gap(12),
                            //Información adicional
                            TextFormField(
                              controller: _informacionAdicionalController,
                              autofillHints: const [AutofillHints.name],
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'Información adicional',
                                labelStyle: GoogleFonts.inter(
                                  color: AppColors.kTextPrimaryBlack,
                                ),
                                hintText: 'Ej. Incluye refresco y papas...',
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
                            ),
                            const Gap(12),
                            //DROPDOWN DE CATEGORÍAS
                            Row(
                              children: [
                                Text(
                                  'Categoría:',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                const Gap(10),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: DropdownSearch<CategoriaModelo>(
                                      asyncItems: (filter) async {
                                        return await _getCategoriasForDropdown();
                                      },
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        baseStyle: const TextStyle(
                                          fontSize: 13,
                                        ),
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          hintText: 'Búsqueda por nombre...',
                                          hintStyle: GoogleFonts.inter(
                                            color: AppColors.kTextSecondaryGray,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.white,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: AppColors
                                                  .kGeneralPrimaryOrange,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color:
                                                  AppColors.kGeneralErrorColor,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color:
                                                  AppColors.kGeneralErrorColor,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          filled: true,
                                          fillColor: AppColors.kInputLiteGray,
                                        ),
                                      ),
                                      popupProps: const PopupProps.menu(
                                        showSearchBox: true,
                                      ),
                                      itemAsString: (CategoriaModelo c) =>
                                          c.categoriaAsString(),
                                      onChanged: (CategoriaModelo? data) {
                                        //Asignar el cliente selecto al provider
                                        if (data != null) {
                                          ref
                                              .read(categoriaActualProvider
                                                  .notifier)
                                              .setCategoriaActual(data);
                                        }
                                      },
                                      selectedItem: categoriaSeleccionada,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(12),
                            //Sección de Cupertino Switches
                            Row(
                              children: [
                                Container(
                                  height: 150,
                                  width: 180,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFDFE3E7),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.percent,
                                        color: AppColors.kGeneralPrimaryOrange,
                                        size: 25,
                                      ),
                                      const Gap(10),
                                      const Text(
                                        '¿Precio incluye ISV?',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Gap(4),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Transform.scale(
                                          scale: 0.7,
                                          child: CupertinoSwitch(
                                            value: _precioIncluyeIsvSelected,
                                            onChanged: (v) {
                                              setState(() {
                                                _precioIncluyeIsvSelected =
                                                    !_precioIncluyeIsvSelected;
                                                _calcularPrecioDeVenta();
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Gap(10),
                                Container(
                                  height: 150,
                                  width: 180,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFDFE3E7),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.soup_kitchen_rounded,
                                        color: AppColors.kGeneralPrimaryOrange,
                                        size: 25,
                                      ),
                                      const Gap(10),
                                      const Text(
                                        '¿Es producto para cocina?',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Gap(4),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Transform.scale(
                                          scale: 0.7,
                                          child: CupertinoSwitch(
                                            value: _vaParaCocinaSelected,
                                            onChanged: (v) {
                                              setState(() {
                                                _vaParaCocinaSelected =
                                                    !_vaParaCocinaSelected;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
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
                                    if (_agregarMenuKey.currentState!
                                            .validate() &&
                                        categoriaSeleccionada.nombreCategoria !=
                                            'Seleccione categoría...') {
                                      if (_selectedImage != null) {
                                        final menuItem = MenuItemModel(
                                          numMenu: _correlativoController.text,
                                          descripcion:
                                              _descripcionController.text,
                                          otraInfo:
                                              _informacionAdicionalController
                                                  .text,
                                          img: _selectedImage!.path,
                                          precioSinIsv: double.parse(
                                              _precioSinIsvController.text),
                                          precioConIsv: double.parse(
                                              _precioConIsvController.text),
                                          nombreItem: _nombreController.text,
                                          idRestaurante: int.parse(ref
                                              .read(userPublicDataProvider)[
                                                  'id_restaurante']
                                              .toString()),
                                          precioIncluyeIsv:
                                              _precioIncluyeIsvSelected,
                                          vaParaCocina: _vaParaCocinaSelected,
                                          idCategoria: categoriaSeleccionada
                                              .idCategoria!,
                                        );
                                        await _tryAddMenu(menuItem);
                                      } else {
                                        Fluttertoast.cancel();
                                        Fluttertoast.showToast(
                                          msg:
                                              'Debe proveer de una imagen para el producto',
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 4,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                          webPosition: 'center',
                                          webBgColor: 'red',
                                        );
                                      }
                                    } else {
                                      Fluttertoast.cancel();
                                      Fluttertoast.showToast(
                                        msg:
                                            'Elija categoría y todos los campos requeridos!!',
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 4,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                        webPosition: 'center',
                                        webBgColor: 'red',
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.kGeneralPrimaryOrange,
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
    setState(() => _isTryingUpload = true);
    await supabaseClient
        .addMenuItem(menuItemModel, _selectedImage!)
        .then((message) {
      setState(() => _isTryingUpload = false);
      if (message == 'success') {
        //Resetear la categoría seleccionada
        ref.read(categoriaActualProvider.notifier).resetCategoriaSeleccionada();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Producto agregado exitosamente!!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ));
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Agregado exitosamente!!',
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

  Future<void> _seleccionarImagen() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);

    if (pickedImage == null) {
      return;
    }
    _selectedImage = File(pickedImage.path);
    setState(() {
      imagenDisplay = Image.file(
        _selectedImage!,
        width: double.infinity,
        height: 233.0,
        fit: BoxFit.cover,
      );
    });
  }

  void _calcularPrecioDeVenta() {
    if (_precioIncluyeIsvSelected) {
      _precioConIsvController.text = _precioSinIsvController.text;
    } else {
      if (_precioSinIsvController.text.isNotEmpty) {
        double precioSin =
            double.tryParse(_precioSinIsvController.text.toString())!;
        double precioCon = precioSin * 1.15;
        String precioFinalDeVenta = precioCon.toStringAsFixed(2);

        _precioConIsvController.text = precioFinalDeVenta;
      }
    }
  }
}
