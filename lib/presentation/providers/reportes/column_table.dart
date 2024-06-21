import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'column_table.g.dart';

@Riverpod(keepAlive: true)
class PedidosTableColumns extends _$PedidosTableColumns {
  @override
  List<DataColumn> build() {
    return const <DataColumn>[
      DataColumn(
        label: Expanded(
          child: Text(
            '# orden',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Detalle pedido',
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
      DataColumn(
        label: Expanded(
          child: Text(
            'Fecha',
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Método de pago',
          ),
        ),
      ),
    ];
  }
}
