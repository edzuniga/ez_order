abstract class Pedido {
  Pedido({
    this.uuidPedido,
    required this.idRestaurante,
    required this.descuento,
    required this.impuestos,
    required this.subtotal,
    required this.total,
    this.notaAdicional,
    this.importeExonerado,
    this.importeExento,
    this.importeGravado,
    this.isvAplicado,
    required this.orden,
    required this.idCliente,
    required this.numPedido,
    required this.idMetodoPago,
    required this.enPreparacion,
  });

  final String? uuidPedido;
  final int idRestaurante;
  final double descuento;
  final double impuestos;
  final double subtotal;
  final double total;
  final String? notaAdicional;
  final double? importeExonerado;
  final double? importeExento;
  final double? importeGravado;
  final String? isvAplicado;
  final String orden;
  final int idCliente;
  final int numPedido;
  final int idMetodoPago;
  final bool enPreparacion;
}
