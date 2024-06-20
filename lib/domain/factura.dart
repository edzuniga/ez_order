abstract class Factura {
  Factura({
    required this.idFactura,
    required this.idRestaurante,
    required this.uuidPedido,
    this.rtn,
    this.direccion,
    this.correo,
    this.telefono,
    this.cai,
    this.numFactura,
    required this.fechaFactura,
    this.idCliente,
    this.total,
    this.nombreCliente,
    this.rtnCliente,
  });
  final int idFactura;
  final int idRestaurante;
  final String uuidPedido;
  final String? rtn;
  final String? direccion;
  final String? correo;
  final String? telefono;
  final String? cai;
  final int? numFactura;
  final DateTime fechaFactura;
  final int? idCliente;
  final double? total;
  final String? nombreCliente;
  final String? rtnCliente;
}
