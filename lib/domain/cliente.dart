abstract class Cliente {
  Cliente({
    this.idCliente,
    this.rtnCliente,
    required this.nombreCliente,
    this.correoCliente,
    this.descuentoCliente,
    required this.idRestaurante,
    required this.exonerado,
  });

  final int? idCliente;
  final String? rtnCliente;
  final String nombreCliente;
  final String? correoCliente;
  final double? descuentoCliente;
  final int idRestaurante;
  final bool exonerado;
}
