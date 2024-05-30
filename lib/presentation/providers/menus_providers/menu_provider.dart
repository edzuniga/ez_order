import 'package:ez_order_ezr/presentation/providers/menus_providers/cliente_actual_provider.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/descuento_provider.dart';
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
    //Obtener el cliente actual
    final clienteActual = ref.read(clientePedidoActualProvider);
    //Efectuar operaciones para actualizar info general del pedido actual
    //sumar los precios, es la operación más básica
    if (state.isNotEmpty) {
      double sumaPrecios = state.map((e) {
        //Obtener la cantidad seleccionada por cada ítem del menú
        final pediDeta =
            detallesPedido.where((element) => element.idMenu == e.idMenu).first;
        if (e.precioIncluyeIsv == false) {
          return e.precioSinIsv * pediDeta.cantidad;
        } else {
          return (e.precioSinIsv / 1.15) * pediDeta.cantidad;
        }
      }).reduce((value, element) => value + element);

      //!Obtención de los cálculos finales
      double subTotal = double.parse(sumaPrecios.toStringAsFixed(2));
      double impuestos = double.parse((sumaPrecios * 0.15).toStringAsFixed(2));
      double descuentoActual = ref.read(descuentoPedidoActualProvider);
      double total = subTotal + impuestos - descuentoActual;
      double importeExonerado = 0.0;
      double importeExento = 0.0;
      double importeGravado = 0.0;

      //condición general de exoneración del cliente
      if (clienteActual.exonerado) {
        importeExonerado = subTotal;
        impuestos = 0.0;
      } else {
        importeGravado = subTotal;
      }

      //!Obtención de los cálculos finales

      //Actualizar datos del pedido actual
      ref.read(pedidoActualProvider.notifier).actualizarInfo(
            subtotl: subTotal,
            isv: impuestos,
            importeExonerado: importeExonerado,
            importeExento: importeExento,
            importeGravado: importeGravado,
            descuento: descuentoActual,
            total: total,
            idCliente: clienteActual.idCliente!,
          );
    } else {
      ref.read(pedidoActualProvider.notifier).actualizarInfo(
            subtotl: 0,
            isv: 0,
            importeExonerado: 0,
            importeExento: 0,
            importeGravado: 0,
            descuento: 0,
            total: 0,
            idCliente: 1,
          );
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
