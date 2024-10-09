import 'package:ez_order_ezr/data/pedido_detalle_model.dart';
import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rows_ventas_por_producto.g.dart';

@riverpod
class RowsVentasPorProducto extends _$RowsVentasPorProducto {
  @override
  List<DataRow> build() {
    return [];
  }

  Future<void> addDataRows(List<Map<String, dynamic>> rowsMap) async {
    state.clear();
    List<int> idMenuItemsEncontrados = [];
    List<int> cantidadPorItem = [];
    List<double> totalesVentasPorItem = [];

    for (var element in rowsMap) {
      PedidoModel pedido = PedidoModel.fromJson(element);

      //Obtener el detalle del pedido
      final List<PedidoDetalleModel> detalles = await ref
          .read(supabaseManagementProvider.notifier)
          .getDetallesPedido(pedido.uuidPedido!);

      for (var det in detalles) {
        //Lo que se hace si NO ha sido agregado
        if (!idMenuItemsEncontrados.contains(det.idMenu)) {
          idMenuItemsEncontrados.add(det.idMenu);
          cantidadPorItem.add(det.cantidad);
          totalesVentasPorItem.add(det.importeCobrado * 1.15);
        } else {
          //Cuando YA Existe
          int index = idMenuItemsEncontrados.indexOf(det.idMenu);
          cantidadPorItem[index] += det.cantidad;
          totalesVentasPorItem[index] += (det.importeCobrado * 1.15);
        }
      }
    }
    // Crear una lista de índices para ordenar por cantidad vendida
    List<int> indices = List.generate(idMenuItemsEncontrados.length, (i) => i);

    // Ordenar los índices de acuerdo a las cantidades en orden descendiente
    indices.sort((a, b) => cantidadPorItem[b].compareTo(cantidadPorItem[a]));

    // Generar los DataRows ordenados por la cantidad vendida
    for (int i in indices) {
      int e = idMenuItemsEncontrados[i];
      String nombre = await ref
          .read(supabaseManagementProvider.notifier)
          .getNombreMenuItem(e);
      state.add(
        DataRow(
          cells: [
            DataCell(Text(nombre)),
            DataCell(Text(cantidadPorItem[i].toString())),
            DataCell(Text('L ${totalesVentasPorItem[i].toStringAsFixed(2)}')),
          ],
        ),
      );
    }

    /* for (int i = 0; i < idMenuItemsEncontrados.length; i++) {
      int e = idMenuItemsEncontrados[i];
      String nombre = await ref
          .read(supabaseManagementProvider.notifier)
          .getNombreMenuItem(e);
      state.add(
        DataRow(
          cells: [
            DataCell(Text(nombre)),
            DataCell(Text(cantidadPorItem[i].toString())),
            DataCell(Text('L ${totalesVentasPorItem[i].toStringAsFixed(2)}')),
          ],
        ),
      );
    } */
  }

  void clearTableRows() {
    state = [];
  }
}
