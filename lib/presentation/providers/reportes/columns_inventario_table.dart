import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'columns_inventario_table.g.dart';

@Riverpod(keepAlive: true)
class ColumnsMovimientosInventarioTable
    extends _$ColumnsMovimientosInventarioTable {
  @override
  List<DataColumn> build() {
    return const <DataColumn>[
      DataColumn(
        label: Expanded(
          child: Text(
            'Producto',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Tipo',
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Descripción',
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Stock',
          ),
        ),
      ),
    ];
  }
}
