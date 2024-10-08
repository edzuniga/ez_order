import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ez_order_ezr/data/pedido_detalle_model.dart';
import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
part 'table_rows.g.dart';

@Riverpod(keepAlive: true)
class PedidosTableRows extends _$PedidosTableRows {
  @override
  List<DataRow> build() {
    return [];
  }

  Future<void> addDataRows(List<Map<String, dynamic>> pedidosMap) async {
    double totalDeTodo = 0.0;
    for (var element in pedidosMap) {
      PedidoModel pedido = PedidoModel.fromJson(element);
      String formattedDate = DateFormat.yMMMd('es').format(pedido.createdAt);
      String metodoPago = 'Efectivo';

      switch (pedido.idMetodoPago) {
        case 2:
          metodoPago = 'Tarjeta';
          break;

        case 3:
          metodoPago = 'Transferencia';
          break;
      }

      //Obtener el detalle del pedido - está en una función en el provider
      //de supabase
      final List<PedidoDetalleModel> detalles = await ref
          .read(supabaseManagementProvider.notifier)
          .getDetallesPedido(pedido.uuidPedido!);

      //Crear el string del detalle
      String detalleDelPedido = '';
      for (var element in detalles) {
        String menuItemName = await ref
            .read(supabaseManagementProvider.notifier)
            .getNombreMenuItem(element.idMenu);
        detalleDelPedido += '${element.cantidad} de $menuItemName\n';
      }

      // Eliminar el espacio final (salto de línea)
      detalleDelPedido = detalleDelPedido.trim();

      //Ir sumando el TOTAL de todo
      totalDeTodo += pedido.total;

      state.add(
        DataRow(
          cells: [
            DataCell(Text(pedido.numPedido.toString())),
            DataCell(Text(detalleDelPedido)),
            DataCell(Text('L ${pedido.total.toStringAsFixed(2)}')),
            DataCell(Text(formattedDate)),
            DataCell(Text(metodoPago)),
          ],
        ),
      );
    }

    //Agregar el último row con el TOTAL de todo
    state.add(
      DataRow(
        cells: [
          const DataCell(Text('')),
          const DataCell(Text('TOTAL')),
          DataCell(Text('L ${totalDeTodo.toStringAsFixed(2)}')),
          const DataCell(Text('')),
          const DataCell(Text('')),
        ],
      ),
    );
  }

  void clearTableRows() {
    state = [];
  }
}
