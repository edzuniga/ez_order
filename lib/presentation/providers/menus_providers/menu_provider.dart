import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ez_order_ezr/data/menu_item_model.dart';
import 'package:ez_order_ezr/data/pedido_detalle_model.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/pedido_actual_provider.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/pedido_detalles_provider.dart';
part 'menu_provider.g.dart';

@Riverpod(keepAlive: true)
class MenuItemPedidoList extends _$MenuItemPedidoList {
  @override
  List<MenuItemModel> build() {
    return [];
  }

  void hacerCalculosDelPedido() {
    //Primero obtener el provider de los detalles del pedido
    final detallesPedido = ref.read(pedidoDetallesManagementProvider);
    //Efectuar operaciones para actualizar info general del pedido actual
    //sumar los precios, es la operación más básica
    if (state.isNotEmpty) {
      double sumaPrecios = state.map((e) {
        //Obtener la cantidad seleccionada por cada ítem del menú
        final pediDeta =
            detallesPedido.where((element) => element.idMenu == e.idMenu).first;
        return e.precio * pediDeta.cantidad;
      }).reduce((value, element) => value + element);
      double impuestos = double.parse((sumaPrecios * 0.15).toStringAsFixed(2));
      ref
          .read(pedidoActualProvider.notifier)
          .actualizarInfo(sumaPrecios, impuestos);
    } else {
      ref.read(pedidoActualProvider.notifier).actualizarInfo(0, 0);
    }
  }

  //poblar el listado con lo que viene de supa
  void addMenuItem(MenuItemModel modelo) {
    //Crear el PedidoDetallesModel necesario para cada elemento de menú
    //agregado al pedido actual
    PedidoDetalleModel pedidoDetalleProvi =
        PedidoDetalleModel(idMenu: modelo.idMenu!, cantidad: 1);
    state = [...state, modelo];
    //Ahora agregar una instancia de PedidoDetallesModelo a su provider
    ref
        .read(pedidoDetallesManagementProvider.notifier)
        .addPedidoDetalle(pedidoDetalleProvi);
    hacerCalculosDelPedido();
  }

  //Remover del listado
  void removeMenuItem(MenuItemModel modelo) {
    state.removeWhere((element) => element.idMenu == modelo.idMenu);
    //También remover la instancia en el provider de detalles
    ref
        .read(pedidoDetallesManagementProvider.notifier)
        .removePedidoDetalle(modelo.idMenu!);
    hacerCalculosDelPedido();
  }

  //Resetear todo el menú
  void resetMenuItem() {
    state.clear();
    //También resetearlo en provider de detalles del pedido
    ref
        .read(pedidoDetallesManagementProvider.notifier)
        .resetPedidosDetallesList();
    hacerCalculosDelPedido();
  }
}
