abstract class CajaApertura {
  CajaApertura({
    this.id,
    required this.restauranteUid,
    required this.createdAt,
    required this.cantidad,
    this.cantidadCierre,
  });

  final int? id;
  final int restauranteUid;
  final DateTime createdAt;
  final double cantidad;
  final double? cantidadCierre;
}
