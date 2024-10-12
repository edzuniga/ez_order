import 'package:animate_do/animate_do.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/data/inventario_modelo.dart';
import 'package:ez_order_ezr/data/menu_inventario_modelo.dart';
import 'package:ez_order_ezr/domain/menu_inventario.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/widgets/custom_input.dart';
import 'package:ez_order_ezr/presentation/widgets/modal_purpose_enum.dart';

class MenuInventarioModal extends ConsumerStatefulWidget {
  const MenuInventarioModal({
    required this.modalPurpose,
    required this.titulo,
    this.menuInventario,
    required this.idMenu,
    required this.idRest,
    super.key,
  });

  final ModalPurpose modalPurpose;
  final MenuInventario? menuInventario;
  final String titulo;
  final int idMenu;
  final int idRest;

  @override
  ConsumerState<MenuInventarioModal> createState() =>
      _MenuInventarioModalState();
}

class _MenuInventarioModalState extends ConsumerState<MenuInventarioModal> {
  final GlobalKey<FormState> _menuInventarioFormKey = GlobalKey<FormState>();
  final TextEditingController _cantidad = TextEditingController();
  InventarioModelo? inventarioModeloSeleccionado;

  bool _isSendingData = false;
  late String _botonString;

  @override
  void initState() {
    super.initState();
    _botonString =
        widget.modalPurpose == ModalPurpose.add ? 'Agregar' : 'Editar';
    if (widget.modalPurpose == ModalPurpose.update) {
      _getFieldValues();
    }
  }

  Future<void> _getFieldValues() async {
    inventarioModeloSeleccionado = await ref
        .read(supabaseManagementProvider.notifier)
        .obtenerInventarioPorId(widget.menuInventario!.idInventario);
    setState(() {
      _cantidad.text = widget.menuInventario!.cantidadStock.toString();
    });
  }

  @override
  void dispose() {
    _cantidad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight:
            widget.modalPurpose == ModalPurpose.delete ? 280 : double.infinity,
        maxWidth: widget.modalPurpose == ModalPurpose.delete
            ? double.minPositive
            : 800,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: widget.modalPurpose != ModalPurpose.delete
          ? Form(
              key: _menuInventarioFormKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //Título del modal
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: const BoxDecoration(
                          color: AppColors.kGeneralPrimaryOrange,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.titulo} asociación',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.pop(false),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //Dropdown de inventario
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: SizedBox(
                        height: 48,
                        child: DropdownSearch<InventarioModelo>(
                          asyncItems: (filter) async {
                            return await ref
                                .read(supabaseManagementProvider.notifier)
                                .obtenerInventarioPorRestauranteModelos(
                                    widget.idRest);
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            baseStyle: const TextStyle(
                              fontSize: 13,
                            ),
                            dropdownSearchDecoration: InputDecoration(
                              hintText: 'Búsqueda por nombre...',
                              hintStyle: GoogleFonts.inter(
                                color: AppColors.kTextSecondaryGray,
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
                          ),
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                          ),
                          itemAsString: (InventarioModelo c) =>
                              c.inventarioAsString(),
                          onChanged: (InventarioModelo? data) {
                            //Asignar el cliente selecto al provider
                            inventarioModeloSeleccionado = data;
                          },
                          validator: (v) {
                            if (v == null) {
                              return 'Campo obligatorio';
                            }
                            return null;
                          },
                          selectedItem: inventarioModeloSeleccionado,
                        ),
                      ),
                    ),

                    //Stock
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomInputField(
                              controlador: _cantidad,
                              label: 'Cantidad',
                              isRequired: true,
                              isInt: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //Botones cancelar y agregar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          //Botón de cancelar
                          ElevatedButton(
                            onPressed: () => context.pop(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Gap(10),
                          //Botón de agregar/editar
                          ElevatedButton(
                            onPressed: _isSendingData
                                ? () {}
                                : () async {
                                    if (_menuInventarioFormKey.currentState!
                                        .validate()) {
                                      if (widget.modalPurpose ==
                                          ModalPurpose.add) {
                                        MenuInventarioModelo menuInventario =
                                            MenuInventarioModelo(
                                          createdAt: DateTime.now(),
                                          idRestaurante: widget.idRest,
                                          idMenu: widget.idMenu,
                                          idInventario:
                                              inventarioModeloSeleccionado!.id!,
                                          cantidadStock:
                                              int.parse(_cantidad.text),
                                        );
                                        await tryAddMenuInventario(
                                            menuInventario);
                                      } else {
                                        MenuInventarioModelo menuInventario =
                                            MenuInventarioModelo(
                                          id: widget.menuInventario!.id,
                                          createdAt:
                                              widget.menuInventario!.createdAt,
                                          idRestaurante: widget
                                              .menuInventario!.idRestaurante,
                                          idMenu: widget.menuInventario!.idMenu,
                                          idInventario:
                                              inventarioModeloSeleccionado!.id!,
                                          cantidadStock:
                                              int.parse(_cantidad.text),
                                        );
                                        await tryUpdateMenuInventario(
                                            menuInventario);
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kGeneralErrorColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isSendingData
                                ? SpinPerfect(
                                    infinite: true,
                                    child: const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _botonString,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Título del modal
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: const BoxDecoration(
                      color: AppColors.kGeneralPrimaryOrange,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.titulo} producto',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.pop(false),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(15),
                const Icon(
                  Icons.warning_amber,
                  color: AppColors.kGeneralErrorColor,
                  size: 50,
                ),
                const Gap(15),
                Text(
                  '¿Estás seguro que deseas borrar el registro?',
                  style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(10),
                //Botones cancelar y aceptar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //Botón de cancelar
                      ElevatedButton(
                        onPressed: () => context.pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Gap(10),
                      //Botón de aceptar
                      ElevatedButton(
                        onPressed: () async {
                          await tryDeleteMenuInventario(
                              widget.menuInventario!.id!);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kGeneralErrorColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Aceptar',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> tryAddMenuInventario(MenuInventarioModelo menuInventario) async {
    setState(() => _isSendingData = true);
    final supabase = ref.read(supabaseManagementProvider.notifier);

    String mensaje = await supabase.addMenuInventario(menuInventario);

    if (!mounted) return;

    if (mensaje == "success") {
      setState(() => _isSendingData = false);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Registro agregado exitosamente',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      context.pop(true);
    } else {
      setState(() => _isSendingData = false);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.kGeneralErrorColor,
          content: Text(
            'Error al intentar agregar el registro -> $mensaje',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  Future<void> tryUpdateMenuInventario(
      MenuInventarioModelo menuInventario) async {
    setState(() => _isSendingData = true);
    final supabase = ref.read(supabaseManagementProvider.notifier);

    String mensaje = await supabase.actualizarMenuInventario(menuInventario);

    if (!mounted) return;

    if (mensaje == "success") {
      setState(() => _isSendingData = false);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.blue,
          content: Text(
            'Registro actualizado exitosamente',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      context.pop(true);
    } else {
      setState(() => _isSendingData = false);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.kGeneralErrorColor,
          content: Text(
            'Error al intentar actualizar el registro -> $mensaje',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  Future<void> tryDeleteMenuInventario(int id) async {
    setState(() => _isSendingData = true);
    final supabase = ref.read(supabaseManagementProvider.notifier);

    String mensaje = await supabase.borrarMenuInventario(id);

    if (!mounted) return;

    if (mensaje == "success") {
      setState(() => _isSendingData = false);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.blue,
          content: Text(
            'Registro borrado exitosamente',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      context.pop(true);
    } else {
      setState(() => _isSendingData = false);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.kGeneralErrorColor,
          content: Text(
            'Error al intentar borrar el registro -> $mensaje',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
}
