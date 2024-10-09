import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'columns_ventas_por_producto.g.dart';

@riverpod
class ColumnsVentasPorProducto extends _$ColumnsVentasPorProducto {
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
            'Cantidad',
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Total (L)',
          ),
        ),
      ),
    ];
  }
}
