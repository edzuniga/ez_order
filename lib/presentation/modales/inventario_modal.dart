import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/data/inventario_modelo.dart';
import 'package:ez_order_ezr/domain/inventario.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:ez_order_ezr/presentation/widgets/custom_input.dart';
import 'package:ez_order_ezr/presentation/widgets/modal_purpose_enum.dart';

class InventarioModal extends ConsumerStatefulWidget {
  const InventarioModal({
    required this.modalPurpose,
    required this.titulo,
    this.inventario,
    super.key,
  });

  final ModalPurpose modalPurpose;
  final Inventario? inventario;
  final String titulo;

  @override
  ConsumerState<InventarioModal> createState() => _InventarioModalState();
}

class _InventarioModalState extends ConsumerState<InventarioModal> {
  final GlobalKey<FormState> _inventarioFormKey = GlobalKey<FormState>();
  final TextEditingController _codigo = TextEditingController();
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();
  final TextEditingController _precioCosto = TextEditingController();
  final TextEditingController _stock = TextEditingController();
  final TextEditingController _proveedor = TextEditingController();

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
    setState(() {
      _codigo.text = widget.inventario!.codigo.toString();
      _nombre.text = widget.inventario!.nombre;
      _descripcion.text = widget.inventario!.descripcion.toString();
      _precioCosto.text = widget.inventario!.precioCosto.toString();
      _stock.text = widget.inventario!.stock.toString();
      _proveedor.text = widget.inventario!.proveedor.toString();
    });
  }

  @override
  void dispose() {
    _codigo.dispose();
    _nombre.dispose();
    _descripcion.dispose();
    _precioCosto.dispose();
    _stock.dispose();
    _proveedor.dispose();
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
              key: _inventarioFormKey,
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

                    //Código
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomInputField(
                              controlador: _codigo,
                              label: 'Código del producto',
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //Nombre
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomInputField(
                              controlador: _nombre,
                              label: 'Nombre del producto',
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //Descripción
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomInputField(
                              controlador: _descripcion,
                              label: 'Descripción',
                              isTextArea: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //Precio de costo
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomInputField(
                              controlador: _precioCosto,
                              label: 'Precio de costo',
                              isRequired: true,
                              isMoney: true,
                            ),
                          ),
                        ],
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
                              controlador: _stock,
                              label: 'Stock',
                              isRequired: true,
                              isInt: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //Proveedor
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomInputField(
                              controlador: _proveedor,
                              label: 'Proveedor',
                              isRequired: true,
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
                                    if (_inventarioFormKey.currentState!
                                        .validate()) {
                                      //Obtener el ID del restaurante
                                      int? idRes = int.tryParse(ref
                                          .read(userPublicDataProvider)[
                                              'id_restaurante']
                                          .toString());

                                      if (widget.modalPurpose ==
                                          ModalPurpose.add) {
                                        if (idRes != null) {
                                          InventarioModelo inventario =
                                              InventarioModelo(
                                            createdAt: DateTime.now(),
                                            idRestaurante: idRes,
                                            codigo: _codigo.text,
                                            nombre: _nombre.text,
                                            descripcion: _descripcion.text,
                                            precioCosto:
                                                double.parse(_precioCosto.text),
                                            stock: int.parse(_stock.text),
                                            proveedor: _proveedor.text,
                                          );
                                          await tryAddInventario(inventario);
                                        }
                                      } else {
                                        if (idRes != null) {
                                          InventarioModelo inventario =
                                              InventarioModelo(
                                            id: widget.inventario!.id,
                                            createdAt:
                                                widget.inventario!.createdAt,
                                            idRestaurante: widget
                                                .inventario!.idRestaurante,
                                            codigo: _codigo.text,
                                            nombre: _nombre.text,
                                            descripcion: _descripcion.text,
                                            precioCosto:
                                                double.parse(_precioCosto.text),
                                            stock: int.parse(_stock.text),
                                            proveedor: _proveedor.text,
                                          );
                                          await tryUpdateInventario(inventario);
                                        }
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
                          await tryDeleteInventario(widget.inventario!.id!);
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

  Future<void> tryAddInventario(InventarioModelo inventario) async {
    setState(() => _isSendingData = true);
    final supabase = ref.read(supabaseManagementProvider.notifier);

    String mensaje = await supabase.addInventario(inventario);

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

  Future<void> tryUpdateInventario(InventarioModelo inventario) async {
    setState(() => _isSendingData = true);
    final supabase = ref.read(supabaseManagementProvider.notifier);

    String mensaje = await supabase.actualizarInventario(inventario);

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

  Future<void> tryDeleteInventario(int id) async {
    setState(() => _isSendingData = true);
    final supabase = ref.read(supabaseManagementProvider.notifier);

    String mensaje = await supabase.borrarInventario(id);

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
