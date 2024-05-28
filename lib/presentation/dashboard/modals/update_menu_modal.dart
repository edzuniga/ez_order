import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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

class UpdateMenuModal extends ConsumerStatefulWidget {
  const UpdateMenuModal({required this.itemMenu, super.key});
  final MenuItemModel itemMenu;

  @override
  ConsumerState<UpdateMenuModal> createState() => _UpdateMenuModalState();
}

class _UpdateMenuModalState extends ConsumerState<UpdateMenuModal> {
  final GlobalKey<FormState> _agregarMenuKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _correlativoController = TextEditingController();
  final TextEditingController _informacionAdicionalController =
      TextEditingController();
  bool _precioIncluyeIsvSelected = false;
  bool _vaParaCocinaSelected = true;
  File? _selectedImage;
  bool _isTryingUpload = false;
  late final String _imgUrl;
  late Widget imagenDisplay;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.itemMenu.nombreItem;
    _precioController.text = widget.itemMenu.precio.toString();
    _descripcionController.text = widget.itemMenu.descripcion;
    _correlativoController.text = widget.itemMenu.numMenu;
    _informacionAdicionalController.text = widget.itemMenu.otraInfo;
    _vaParaCocinaSelected = widget.itemMenu.vaParaCocina;
    _precioIncluyeIsvSelected = widget.itemMenu.precioIncluyeIsv;
    _imgUrl = widget.itemMenu.img!;
    imagenDisplay = Image.network(
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        }
      },
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Text('Error al querer cargar imagen'),
      ),
      _imgUrl.toString(),
      width: double.infinity,
      height: 233.0,
      fit: BoxFit.cover,
    );
  }

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
                            Row(
                              children: [
                                SizedBox(
                                  width: 350,
                                  child: TextFormField(
                                    controller: _nombreController,
                                    autofillHints: const [AutofillHints.name],
                                    decoration: InputDecoration(
                                      labelText: 'Nombre del plato',
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
                                Expanded(
                                  child: TextFormField(
                                    controller: _precioController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
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
                            Row(
                              children: [
                                const Text('¿precio incluye ISV?'),
                                const Gap(4),
                                Transform.scale(
                                  scale: 0.7,
                                  child: CupertinoSwitch(
                                    value: _precioIncluyeIsvSelected,
                                    onChanged: (v) {
                                      setState(() {
                                        _precioIncluyeIsvSelected =
                                            !_precioIncluyeIsvSelected;
                                      });
                                    },
                                  ),
                                ),
                                const Text('¿Es producto para cocina?'),
                                const Gap(4),
                                Transform.scale(
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
                                    if (_agregarMenuKey.currentState!
                                        .validate()) {
                                      final menuItem = MenuItemModel(
                                        idMenu: widget.itemMenu.idMenu,
                                        numMenu: _correlativoController.text,
                                        descripcion:
                                            _descripcionController.text,
                                        otraInfo:
                                            _informacionAdicionalController
                                                .text,
                                        img: _selectedImage != null
                                            ? _selectedImage!.path
                                            : widget.itemMenu.img,
                                        precio: double.parse(
                                            _precioController.text),
                                        nombreItem: _nombreController.text,
                                        idRestaurante: int.parse(ref
                                            .read(userPublicDataProvider)[
                                                'id_restaurante']
                                            .toString()),
                                        precioIncluyeIsv:
                                            _precioIncluyeIsvSelected,
                                        vaParaCocina: _vaParaCocinaSelected,
                                      );
                                      await _tryUpdateMenu(menuItem);
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
                                    'Actualizar producto',
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

  Future<void> _tryUpdateMenu(MenuItemModel menuItemModel) async {
    //llamar la única instancia de supabase
    final supabaseClient = ref.read(supabaseManagementProvider.notifier);
    setState(() => _isTryingUpload = true);
    await supabaseClient
        .updateMenuItem(menuItemModel, _selectedImage)
        .then((message) {
      setState(() => _isTryingUpload = false);
      if (message == 'success') {
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
}
