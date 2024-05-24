import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:random_string/random_string.dart';
import 'package:ez_order_ezr/data/pedido_model.dart';
part 'pedido_actual_provider.g.dart';

@riverpod
class PedidoActual extends _$PedidoActual {
  @override
  PedidoModel build() {
    return PedidoModel(
      idRestaurante: 1,
      descuento: 0.0,
      impuestos: 0.0,
      subtotal: 0.0,
      total: 0.0,
      importeExonerado: 0.0,
      importeExento: 0.0,
      importeGravado: 0.0,
      isvAplicado: '15%',
      orden: randomNumeric(15),
    );
  }

  //Actualizar la info del pedido actual
  void actualizarInfo(double subtotl, double isv) {
    state = state.copyWith(
      subtotal: subtotl,
      impuestos: isv,
    );
  }
}
