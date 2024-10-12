import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/domain/inventario.dart';
import 'package:ez_order_ezr/presentation/widgets/modal_purpose_enum.dart';
import 'package:ez_order_ezr/data/movimiento_inventario_modelo.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/widgets/custom_input.dart';

class MovimientosModal extends ConsumerStatefulWidget {
  const MovimientosModal({
    required this.modalPurpose,
    required this.titulo,
    this.movimientoModelo,
    this.inventario,
    super.key,
  });

  final ModalPurpose modalPurpose;
  final String titulo;
  final MovimientoInventarioModelo? movimientoModelo;
  final Inventario? inventario;

  @override
  ConsumerState<MovimientosModal> createState() => _MovimientosModalState();
}

class _MovimientosModalState extends ConsumerState<MovimientosModal> {
  final GlobalKey<FormState> _movimientoInventarioFormKey =
      GlobalKey<FormState>();
  final TextEditingController _stock = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();
  bool _isSendingData = false;
  late String _botonString;
  late int _stockDisponible;

  int? selectedTipo;
  bool sobrepasaCantidadStock = false;

  @override
  void initState() {
    super.initState();
    _botonString =
        widget.modalPurpose == ModalPurpose.add ? 'Agregar' : 'Editar';
    if (widget.modalPurpose == ModalPurpose.update) {
      _getFieldValues();
    }
    if (widget.modalPurpose == ModalPurpose.add) {
      _stockDisponible = widget.inventario!.stock;
    } else {
      _obtenerStock();
    }
  }

  Future<void> _getFieldValues() async {
    setState(() {
      _stock.text = widget.movimientoModelo!.stock.toString();
      _descripcion.text = widget.movimientoModelo!.descripcion;
      selectedTipo = widget.movimientoModelo!.tipo;
    });
  }

  Future<void> _obtenerStock() async {
    Inventario inventarioProvi = await ref
        .read(supabaseManagementProvider.notifier)
        .obtenerInventarioPorId(widget.movimientoModelo!.idInventario);
    _stockDisponible = inventarioProvi.stock;
  }

  @override
  void dispose() {
    _stock.dispose();
    _descripcion.dispose();
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
              key: _movimientoInventarioFormKey,
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
                            '${widget.titulo} movimiento',
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

                    //Información del producto de inventario
                    widget.modalPurpose == ModalPurpose.add
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.kGeneralPrimaryOrange
                                    .withOpacity(0.05),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                      'Nombre del producto: ${widget.inventario!.nombre}'),
                                  Text(
                                    'Stock disponible: ${widget.inventario!.stock}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),

                    //Tipo de movimiento (entrada / salida)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<int>(
                          value: selectedTipo,
                          items: const [
                            DropdownMenuItem<int>(
                                value: 1, child: Text('Entrada')),
                            DropdownMenuItem<int>(
                                value: 2, child: Text('Salida')),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Tipo de movimiento',
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
                          validator: (v) {
                            if (v == null) {
                              return 'Campo obligatorio';
                            }
                            return null;
                          },
                          onChanged: widget.modalPurpose == ModalPurpose.add
                              ? (v) {
                                  setState(() {
                                    selectedTipo = v;
                                    if (v == 1) {
                                      sobrepasaCantidadStock = false;
                                    }
                                  });
                                }
                              : null,
                        ),
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
                              label: 'Descripción del movimiento',
                              isRequired: true,
                              isTextArea: true,
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
                              label: 'Cantidad de Stock',
                              isRequired: true,
                              isInt: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //Mensaje de STOCK sobrepasado
                    sobrepasaCantidadStock
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.kGeneralErrorColor,
                              ),
                              child: const Text(
                                'La cantidad no puede ser mayor al stock disponible',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        : const SizedBox(),

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
                                    if (_movimientoInventarioFormKey
                                        .currentState!
                                        .validate()) {
                                      if (int.parse(_stock.text) >
                                              _stockDisponible &&
                                          selectedTipo == 2 &&
                                          widget.modalPurpose ==
                                              ModalPurpose.add) {
                                        setState(() =>
                                            sobrepasaCantidadStock = true);
                                      } else {
                                        setState(() =>
                                            sobrepasaCantidadStock = false);

                                        if (widget.modalPurpose ==
                                            ModalPurpose.add) {
                                          MovimientoInventarioModelo
                                              movimientoInventario =
                                              MovimientoInventarioModelo(
                                            createdAt: DateTime.now(),
                                            idInventario:
                                                widget.inventario!.id!,
                                            descripcion: _descripcion.text,
                                            stock: int.parse(_stock.text),
                                            tipo: selectedTipo!,
                                            idRestaurante: widget
                                                .inventario!.idRestaurante,
                                          );

                                          await tryCrearMovimientoInventario(
                                              movimientoInventario);
                                        } else {
                                          MovimientoInventarioModelo
                                              movimientoInventario =
                                              MovimientoInventarioModelo(
                                            id: widget.movimientoModelo!.id,
                                            createdAt: widget
                                                .movimientoModelo!.createdAt,
                                            idInventario: widget
                                                .movimientoModelo!.idInventario,
                                            descripcion: _descripcion.text,
                                            stock: int.parse(_stock.text),
                                            tipo: selectedTipo!,
                                            idRestaurante: widget
                                                .movimientoModelo!
                                                .idRestaurante,
                                          );

                                          await tryUpdateMovimientoInventario(
                                              movimientoInventario);
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
                        '${widget.titulo} movimiento',
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
                          await tryDeleteMovimientoInventario(
                              widget.movimientoModelo!);
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

  Future<void> tryCrearMovimientoInventario(
      MovimientoInventarioModelo movimientoInventario) async {
    setState(() => _isSendingData = true);
    final supabase = ref.read(supabaseManagementProvider.notifier);

    String mensaje =
        await supabase.addMovimientoInventario(movimientoInventario);

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

  Future<void> tryUpdateMovimientoInventario(
      MovimientoInventarioModelo movimientoInventario) async {
    setState(() => _isSendingData = true);
    final supabase = ref.read(supabaseManagementProvider.notifier);

    String mensaje =
        await supabase.actualizarMovimientoInventario(movimientoInventario);

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

  Future<void> tryDeleteMovimientoInventario(
      MovimientoInventarioModelo movimientoInventario) async {
    setState(() => _isSendingData = true);
    final supabase = ref.read(supabaseManagementProvider.notifier);

    String mensaje =
        await supabase.borrarMovimientoInventario(movimientoInventario);

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
