import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ez_order_ezr/data/pedido_model.dart';
part 'pedidos_entregados.g.dart';

@Riverpod(keepAlive: true)
class PedidosEntregados extends _$PedidosEntregados {
  @override
  List<PedidoModel> build() {
    return [];
  }

  void addPedido(PedidoModel pedido) {
    state = [...state, pedido];
  }
}
