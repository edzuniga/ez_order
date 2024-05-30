import 'package:ez_order_ezr/presentation/providers/menus_providers/menu_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ez_order_ezr/data/pedido_detalle_model.dart';
part 'pedido_detalles_provider.g.dart';

@Riverpod(keepAlive: true)
class PedidoDetallesManagement extends _$PedidoDetallesManagement {
  @override
  List<PedidoDetalleModel> build() {
    return [];
  }

  //Agregar un detalles para el pedido
  void addPedidoDetalle(PedidoDetalleModel modelo) {
    state = [...state, modelo];
  }

  //Borrar el pedido detalles del listado
  void removePedidoDetalle(int menuId) {
    state.removeWhere((element) => element.idMenu == menuId);
  }

  //Resetear el listado de detalles del pedido actual
  void resetPedidosDetallesList() {
    state = [];
  }

  //INCREMENTAR la cantidad en una instancia en específico
  void incrementarCantidad(int menuId) {
    for (var element in state) {
      if (element.idMenu == menuId) {
        element.cantidad += 1;
        //actualizar los cálculos del pedido general
        ref.read(menuItemPedidoListProvider.notifier).hacerCalculosDelPedido();
        break;
      }
    }
  }

  //INCREMENTAR la cantidad en una instancia en específico
  void decrementarCantidad(int menuId) {
    for (var element in state) {
      if (element.idMenu == menuId) {
        element.cantidad -= 1;
        //actualizar los cálculos del pedido general
        ref.read(menuItemPedidoListProvider.notifier).hacerCalculosDelPedido();
        break;
      }
    }
  }
}
