import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'num_pedido_actual.g.dart';

@Riverpod(keepAlive: true)
class NumeroPedidoActual extends _$NumeroPedidoActual {
  @override
  int build() {
    return 1;
  }

  void increment() => state++;
  void decrement() => state--;
  void resetNumeroPedidoActual() => state = 1;

  void setCustomNumeroPedido(int newValue) {
    state = newValue;
  }
}
