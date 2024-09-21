abstract class RegistroCaja {
  RegistroCaja({
    this.id,
    required this.createdAt,
    required this.restauranteId,
    this.ingreso,
    this.egreso,
    this.proveedor,
    this.descripcion,
    this.uuidPedido,
  });

  final int? id;
  final DateTime createdAt;
  final int restauranteId;
  final double? ingreso;
  final double? egreso;
  final String? proveedor;
  final String? descripcion;
  final String? uuidPedido;
}
