abstract class MovimientoInventario {
  MovimientoInventario({
    this.id,
    required this.createdAt,
    required this.idInventario,
    required this.descripcion,
    required this.stock,
    required this.tipo,
    required this.idRestaurante,
  });

  final int? id;
  final DateTime createdAt;
  final int idInventario;
  final String descripcion;
  final int stock;
  final int tipo;
  final int idRestaurante;
}
