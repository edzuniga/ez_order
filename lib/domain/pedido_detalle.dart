abstract class PedidoDetalle {
  PedidoDetalle({
    this.idPedidosItem,
    this.uuidPedido,
    required this.idMenu,
    required this.cantidad,
    required this.importeCobrado,
    this.nombreMenuItem,
  });

  final int? idPedidosItem;
  final String? uuidPedido;
  final int idMenu;
  int cantidad;
  double importeCobrado;
  String? nombreMenuItem;
}
