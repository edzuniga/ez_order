import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'pedido_para_view.g.dart';

@Riverpod(keepAlive: true)
class PedidoParaView extends _$PedidoParaView {
  @override
  PedidoModel build() {
    int idRes = int.parse(
        ref.read(userPublicDataProvider)['id_restaurante'].toString());
    return PedidoModel(
      idRestaurante: idRes,
      descuento: 0,
      impuestos: 0,
      subtotal: 0,
      total: 0,
      orden: '0',
      idCliente: 0,
      numPedido: 0,
      idMetodoPago: 0,
      enPreparacion: false,
      createdAt: DateTime.now(),
    );
  }

  void setPedidoParaView(PedidoModel modelo) {
    state = modelo;
  }

  void resetPedidoParaView() {
    int idRes = int.parse(
        ref.read(userPublicDataProvider)['id_restaurante'].toString());
    state = PedidoModel(
      idRestaurante: idRes,
      descuento: 0,
      impuestos: 0,
      subtotal: 0,
      total: 0,
      orden: '0',
      idCliente: 0,
      numPedido: 0,
      idMetodoPago: 0,
      enPreparacion: false,
      createdAt: DateTime.now(),
    );
  }
}
