abstract class CajaAbierta {
  CajaAbierta({
    this.id,
    required this.createdAt,
    required this.restauranteUid,
    required this.abierto,
  });

  final int? id;
  final DateTime createdAt;
  final int restauranteUid;
  final bool abierto;
}
