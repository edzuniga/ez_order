import 'package:ez_order_ezr/data/pedido_detalle_model.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'detalles_pedido_para_view.g.dart';

@Riverpod(keepAlive: true)
class DetallesParaPedidoView extends _$DetallesParaPedidoView {
  @override
  List<PedidoDetalleModel> build() {
    return [];
  }

  void setListado(List<PedidoDetalleModel> listado) {
    state = [...listado];
  }

  Future<void> getYSetListado(String uuidPedido) async {
    //Obtener el listado completo
    List<PedidoDetalleModel> listadoProvi = [];
    listadoProvi = await ref
        .read(supabaseManagementProvider.notifier)
        .getDetallesPedido(uuidPedido);
    //Obtener el nombre de cada menú item
    // Crear una lista temporal para almacenar los elementos actualizados
    List<PedidoDetalleModel> updatedListadoProvi = [];

    for (var element in listadoProvi) {
      String nombreMenuItem = await ref
          .read(supabaseManagementProvider.notifier)
          .getNombreMenuItem(element.idMenu);
      // Actualizar el elemento con el nombre del menú item
      var updatedElement = element.copyWith(nombreMenuItem: nombreMenuItem);
      updatedListadoProvi.add(updatedElement);
    }
    state = updatedListadoProvi;
  }

  void resetListado() {
    state = [];
  }
}
