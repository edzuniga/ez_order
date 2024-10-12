import 'package:ez_order_ezr/domain/menu_inventario.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/modales/menu_inventario_modal.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/widgets/modal_purpose_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MenuInventarioDts extends DataTableSource {
  MenuInventarioDts({
    required this.listado,
    required this.ref,
    required this.context,
    required this.actualizarEstado,
  });
  final List<MenuInventario> listado;
  final WidgetRef ref;
  final BuildContext context;
  final Function actualizarEstado;

  @override
  DataRow? getRow(int index) {
    int num = index + 1;
    MenuInventario menuInventario = listado[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        //Número
        DataCell(Text('$num')),
        //Producto del inventario
        DataCell(
          FutureBuilder(
            future: ref
                .read(supabaseManagementProvider.notifier)
                .nombreInventario(menuInventario.idInventario),
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
        //Cantidad asociada
        DataCell(Text(menuInventario.cantidadStock.toString())),
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
                  await _deleteMenuInventarioModal(menuInventario);
                },
              ),
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
                onPressed: () async {
                  await _updateMenuInventarioModal(menuInventario);
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
  int get rowCount => listado.length;

  @override
  int get selectedRowCount => 0;

  Future<void> _updateMenuInventarioModal(MenuInventario menuInventario) async {
    bool res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: MenuInventarioModal(
          titulo: 'Editar',
          modalPurpose: ModalPurpose.update,
          menuInventario: menuInventario,
          idMenu: menuInventario.idMenu,
          idRest: menuInventario.idRestaurante,
        ),
      ),
    );

    if (res) {
      actualizarEstado();
    }
  }

  Future<void> _deleteMenuInventarioModal(MenuInventario menuInventario) async {
    bool res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: MenuInventarioModal(
          titulo: 'Borrar',
          modalPurpose: ModalPurpose.delete,
          menuInventario: menuInventario,
          idMenu: menuInventario.idMenu,
          idRest: menuInventario.idRestaurante,
        ),
      ),
    );

    if (res) {
      actualizarEstado();
    }
  }
}
