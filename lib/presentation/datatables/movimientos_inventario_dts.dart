import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ez_order_ezr/presentation/modales/movimientos_modal.dart';
import 'package:ez_order_ezr/presentation/widgets/modal_purpose_enum.dart';
import 'package:ez_order_ezr/data/movimiento_inventario_modelo.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';

class MovimientosInventarioDts extends DataTableSource {
  MovimientosInventarioDts(
      this.ref, this.movimientos, this.context, this.actualizarEstado);
  final WidgetRef ref;
  final List<MovimientoInventarioModelo> movimientos;
  final BuildContext context;
  final Function actualizarEstado;

  @override
  DataRow? getRow(int index) {
    int num = index + 1;
    MovimientoInventarioModelo movimiento = movimientos[index];

    String formattedDate =
        DateFormat.yMMMMEEEEd('es_ES').add_Hm().format(movimiento.createdAt);
    if (movimiento.createdAt.hour > 12) {
      formattedDate += ' pm';
    } else {
      formattedDate += ' am';
    }
    Container tipoWidget = Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: movimiento.tipo == 1
            ? Colors.green
            : AppColors.kGeneralPrimaryOrange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        movimiento.tipo == 1 ? 'Entrada' : 'Salida',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

    return DataRow.byIndex(
      index: index,
      cells: [
        //Número
        DataCell(Text('$num')),
        //Fecha
        DataCell(Text(formattedDate)),
        //Producto
        DataCell(
          FutureBuilder(
            future: ref
                .read(supabaseManagementProvider.notifier)
                .nombreInventario(movimiento.idInventario),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Error: No se pudo obtener el nombre del producto!!',
                    style: TextStyle(
                      color: AppColors.kGeneralPrimaryOrange,
                    ),
                  ),
                );
              }

              String nombreProducto = snapshot.data!;
              return Text(nombreProducto);
            },
          ),
        ),
        //Tipo
        DataCell(tipoWidget),
        //Cantidad
        DataCell(Text(movimiento.stock.toString())),
        //Descripcion
        DataCell(
          SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(
                  maxWidth: 200,
                  minHeight: 50), // Establecer ancho máximo y altura mínima
              child: Text(
                movimiento.descripcion.toString(),
                softWrap: true,
              ),
            ),
          ),
        ),
        //Acciones
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: 'Borrar',
                icon: const Icon(
                  Icons.delete_forever_outlined,
                  color: AppColors.kGeneralErrorColor,
                ),
                onPressed: () async {
                  await _deleteMovimientoModal(movimiento);
                },
              ),
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
                onPressed: () async {
                  await _updateMovimientoModal(movimiento);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => movimientos.length;

  @override
  int get selectedRowCount => 0;

  Future<void> _updateMovimientoModal(
      MovimientoInventarioModelo movimiento) async {
    bool res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: MovimientosModal(
          titulo: 'Editar',
          modalPurpose: ModalPurpose.update,
          movimientoModelo: movimiento,
        ),
      ),
    );

    if (res) {
      actualizarEstado();
    }
  }

  Future<void> _deleteMovimientoModal(
      MovimientoInventarioModelo movimiento) async {
    bool res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: MovimientosModal(
          titulo: 'Borrar',
          modalPurpose: ModalPurpose.delete,
          movimientoModelo: movimiento,
        ),
      ),
    );

    if (res) {
      actualizarEstado();
    }
  }
}
