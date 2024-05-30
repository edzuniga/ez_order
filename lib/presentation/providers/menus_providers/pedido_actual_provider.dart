import 'package:ez_order_ezr/presentation/providers/menus_providers/metodo_pago_actual.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/num_pedido_actual.dart';
import 'package:ez_order_ezr/utils/metodo_pago_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:random_string/random_string.dart';
import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
part 'pedido_actual_provider.g.dart';

@Riverpod(keepAlive: true)
class PedidoActual extends _$PedidoActual {
  @override
  PedidoModel build() {
    //Obtener el id restaurante del usuario
    int idRes = int.parse(
        ref.read(userPublicDataProvider)['id_restaurante'].toString());
    int numPedidoActual = ref.read(numeroPedidoActualProvider);
    //Metodo de pago del pedido actual
    final metodoPagoActual = ref.read(metodoPagoActualProvider);
    int metPagoInt = 0;
    switch (metodoPagoActual) {
      case MetodoDePagoEnum.efectivo:
        metPagoInt = 1;
        break;
      case MetodoDePagoEnum.tarjeta:
        metPagoInt = 2;
        break;
      case MetodoDePagoEnum.transferencia:
        metPagoInt = 3;
        break;
    }

    return PedidoModel(
      idRestaurante: idRes,
      descuento: 0.00,
      impuestos: 0.00,
      subtotal: 0.00,
      total: 0.00,
      importeExonerado: 0.00,
      importeExento: 0.00,
      importeGravado: 0.00,
      isvAplicado: '15%',
      orden: randomNumeric(15),
      idCliente: 1,
      numPedido: numPedidoActual,
      idMetodoPago: metPagoInt,
    );
  }

  //Actualizar la info del pedido actual
  void actualizarInfo({
    required double subtotl,
    required double isv,
    required double descuento,
    required double total,
    required double importeExonerado,
    required double importeExento,
    required double importeGravado,
    required int idCliente,
    required int numPedido,
    required int idMetodoPago,
  }) {
    state = state.copyWith(
      subtotal: subtotl,
      impuestos: isv,
      descuento: descuento,
      importeExonerado: importeExonerado,
      importeExento: importeExento,
      importeGravado: importeGravado,
      total: total,
      idCliente: idCliente,
      numPedido: numPedido,
      idMetodoPago: idMetodoPago,
    );
  }

  void resetearPedidoActual() {
    //Obtener el id restaurante del usuario
    int idRes = int.parse(
        ref.read(userPublicDataProvider)['id_restaurante'].toString());

    //Incrementar el número del pedido
    ref.read(numeroPedidoActualProvider.notifier).increment();
    int numPedidoActual = ref.read(numeroPedidoActualProvider);

    //Metodo de pago del pedido actual
    final metodoPagoActual = ref.read(metodoPagoActualProvider);
    int metPagoInt = 0;
    switch (metodoPagoActual) {
      case MetodoDePagoEnum.efectivo:
        metPagoInt = 1;
        break;
      case MetodoDePagoEnum.tarjeta:
        metPagoInt = 2;
        break;
      case MetodoDePagoEnum.transferencia:
        metPagoInt = 3;
        break;
    }

    state = PedidoModel(
      idRestaurante: idRes,
      descuento: 0.00,
      impuestos: 0.00,
      subtotal: 0.00,
      total: 0.00,
      importeExonerado: 0.00,
      importeExento: 0.00,
      importeGravado: 0.00,
      isvAplicado: '15%',
      orden: randomNumeric(15),
      idCliente: 1,
      numPedido: numPedidoActual,
      idMetodoPago: metPagoInt,
    );
  }
}
