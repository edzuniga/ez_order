import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'table_rows.g.dart';

@Riverpod(keepAlive: true)
class PedidosTableRows extends _$PedidosTableRows {
  @override
  List<DataRow> build() {
    return [];
  }

  void addDataRows(List<Map<String, dynamic>> pedidosMap) {
    for (var element in pedidosMap) {
      PedidoModel pedido = PedidoModel.fromJson(element);
      String formattedDate = DateFormat.yMMMd('es').format(pedido.createdAt);
      state.add(
        DataRow(
          cells: [
            DataCell(Text(pedido.numPedido.toString())),
            const DataCell(Text('detalle del pedido')),
            DataCell(Text('L ${pedido.total.toString()}')),
            DataCell(Text(formattedDate)),
            DataCell(Text(pedido.idMetodoPago.toString())),
          ],
        ),
      );
    }
  }
}
