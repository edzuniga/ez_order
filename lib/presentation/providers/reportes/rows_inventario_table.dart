import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ez_order_ezr/data/movimiento_inventario_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';

part 'rows_inventario_table.g.dart';

@riverpod
class RowsMovimientosInventario extends _$RowsMovimientosInventario {
  @override
  List<DataRow> build() {
    return [];
  }

  Future<void> addDataRows(List<Map<String, dynamic>> rowsMap) async {
    state.clear();

    for (var element in rowsMap) {
      MovimientoInventarioModelo movimiento =
          MovimientoInventarioModelo.fromJson(element);

      String tipo = movimiento.tipo == 1 ? 'Entrada' : 'Salida';

      String nombreInventario = await ref
          .read(supabaseManagementProvider.notifier)
          .nombreInventario(movimiento.idInventario);

      state.add(
        DataRow(
          cells: [
            DataCell(Text(nombreInventario)),
            DataCell(Text(tipo)),
            DataCell(Text(movimiento.descripcion)),
            DataCell(Text(movimiento.stock.toString())),
          ],
        ),
      );
    }
  }

  void clearTableRows() {
    state = [];
  }
}
