import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ez_order_ezr/data/pedido_model.dart';
part 'pedidos_provider.g.dart';

@Riverpod(keepAlive: true)
class PedidosManager extends _$PedidosManager {
  @override
  List<PedidoModel> build() {
    return [];
  }

  //Agregar un pedido
  void addPedido(PedidoModel pedido) {
    state = [...state, pedido];
  }

  //Remover un pedido
  void removePedido(PedidoModel modelo) {
    state.removeWhere((element) => element.uuidPedido == modelo.uuidPedido);
  }

  //Resetear todos los pedidos
  void resetPedidos() {
    state.clear();
  }
}
