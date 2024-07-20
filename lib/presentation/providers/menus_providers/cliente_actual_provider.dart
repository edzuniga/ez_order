import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ez_order_ezr/data/cliente_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/menu_provider.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
part 'cliente_actual_provider.g.dart';

@Riverpod(keepAlive: true)
class ClientePedidoActual extends _$ClientePedidoActual {
  @override
  ClienteModelo build() {
    final datosUsuario = ref.read(userPublicDataProvider);
    int idRes = int.parse(datosUsuario['id_restaurante'].toString());
    return ClienteModelo(
      idCliente: 1,
      rtnCliente: '',
      nombreCliente: 'Consumidor final',
      correoCliente: '',
      descuentoCliente: 0.0,
      idRestaurante: idRes,
      exonerado: false,
    );
  }

  //Actualizar la info del cliente ACTUAL
  void actualizarInfoCliente({
    required int idCliente,
    required String rtnCliente,
    required String nombreCliente,
    required String correoCliente,
    required double descuentoCliente,
    required bool exonerado,
  }) {
    state = state.copyWith(
      idCliente: idCliente,
      rtnCliente: rtnCliente,
      nombreCliente: nombreCliente,
      correoCliente: correoCliente,
      descuentoCliente: descuentoCliente,
      exonerado: exonerado,
    );
    ref.read(menuItemPedidoListProvider.notifier).hacerCalculosDelPedido();
  }

  void resetClienteOriginal() {
    final datosUsuario = ref.read(userPublicDataProvider);
    int idRes = int.parse(datosUsuario['id_restaurante'].toString());
    state = ClienteModelo(
      idCliente: 1,
      rtnCliente: '',
      nombreCliente: 'Consumidor final',
      correoCliente: '',
      descuentoCliente: 0.0,
      idRestaurante: idRes,
      exonerado: false,
    );
  }
}
