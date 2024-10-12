import 'package:flutter/material.dart';

import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/modales/inventario_modal.dart';
import 'package:ez_order_ezr/presentation/modales/movimientos_modal.dart';
import 'package:ez_order_ezr/presentation/widgets/modal_purpose_enum.dart';
import 'package:ez_order_ezr/domain/inventario.dart';

class InventarioTableSource extends DataTableSource {
  InventarioTableSource(this.productos, this.context, this.actualizarEstado);
  final List<Inventario> productos;
  final BuildContext context;
  final Function actualizarEstado;

  @override
  DataRow? getRow(int index) {
    int num = index + 1;
    Inventario producto = productos[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        //Número
        DataCell(Text('$num')),
        //Código
        DataCell(Text(producto.codigo.toString())),
        //Nombre
        DataCell(Text(producto.nombre)),
        //Descripción
        DataCell(
          SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(
                  maxWidth: 200,
                  minHeight: 50), // Establecer ancho máximo y altura mínima
              child: Text(
                producto.descripcion.toString(),
                softWrap: true,
              ),
            ),
          ),
        ),
        //Precio de costo
        DataCell(Text('L ${producto.precioCosto}')),
        //Stock
        DataCell(
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: producto.stock < 10
                  ? Colors.red
                  : producto.stock < 40
                      ? Colors.amber[700]
                      : Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              producto.stock.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        //Proveedor
        DataCell(Text(producto.proveedor.toString())),
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
                  await _deleteInventarioModal(producto);
                },
              ),
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
                onPressed: () async {
                  await _updateInventarioModal(producto);
                },
              ),
              IconButton(
                tooltip: 'Movimientos',
                icon: const Icon(
                  Icons.compare_arrows,
                  color: AppColors.kGeneralPrimaryOrange,
                ),
                onPressed: () async {
                  await _movimientosModal(producto);
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
  int get rowCount => productos.length;

  @override
  int get selectedRowCount => 0;

  Future<void> _updateInventarioModal(Inventario inventario) async {
    bool res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: InventarioModal(
          titulo: 'Editar',
          modalPurpose: ModalPurpose.update,
          inventario: inventario,
        ),
      ),
    );

    if (res) {
      actualizarEstado();
    }
  }

  Future<void> _deleteInventarioModal(Inventario inventario) async {
    bool res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: InventarioModal(
          titulo: 'Borrar',
          modalPurpose: ModalPurpose.delete,
          inventario: inventario,
        ),
      ),
    );

    if (res) {
      actualizarEstado();
    }
  }

  Future<void> _movimientosModal(Inventario inventario) async {
    bool res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: MovimientosModal(
          modalPurpose: ModalPurpose.add,
          titulo: 'Agregar',
          inventario: inventario,
        ),
      ),
    );

    if (res) {
      actualizarEstado();
    }
  }
}
