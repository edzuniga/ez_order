abstract class CajaApertura {
  CajaApertura({
    this.id,
    required this.restauranteUid,
    required this.createdAt,
    required this.cantidad,
    this.cantidadCierre,
    this.totalEfectivo,
    this.totalTarjeta,
    this.totalTransferencia,
    this.totalGastos,
    this.cierreCaja,
    this.personaEnCaja,
  });

  final int? id;
  final int restauranteUid;
  final DateTime createdAt;
  final double cantidad;
  final double? cantidadCierre;
  final double? totalEfectivo;
  final double? totalTarjeta;
  final double? totalTransferencia;
  final double? totalGastos;
  final double? cierreCaja;
  final String? personaEnCaja;
}
