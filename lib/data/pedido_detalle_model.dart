import 'package:ez_order_ezr/domain/pedido_detalle.dart';

class PedidoDetalleModel extends PedidoDetalle {
  PedidoDetalleModel({
    super.idPedidosItem,
    super.uuidPedido,
    required super.idMenu,
    required super.cantidad,
  });

  factory PedidoDetalleModel.fromJson(Map<String, dynamic> json) {
    return PedidoDetalleModel(
      idPedidosItem: json["id_pedidos_item"],
      uuidPedido: json["uuid_pedido"],
      idMenu: json["id_menu"],
      cantidad: json["cantidad"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uuid_pedido": uuidPedido,
      "id_menu": idMenu,
      "cantidad": cantidad,
    };
  }

  PedidoDetalleModel copyWith({
    int? idPedidosItem,
    String? uuidPedido,
    int? idMenu,
    int? cantidad,
  }) {
    return PedidoDetalleModel(
      idPedidosItem: idPedidosItem ?? this.idPedidosItem,
      uuidPedido: uuidPedido ?? this.uuidPedido,
      idMenu: idMenu ?? this.idMenu,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}
