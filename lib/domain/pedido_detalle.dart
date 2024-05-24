abstract class PedidoDetalle {
  PedidoDetalle({
    this.idPedidosItem,
    this.uuidPedido,
    required this.idMenu,
    required this.cantidad,
  });

  final int? idPedidosItem;
  final String? uuidPedido;
  final int idMenu;
  int cantidad;
}
