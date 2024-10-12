abstract class MenuInventario {
  MenuInventario({
    this.id,
    required this.createdAt,
    required this.idRestaurante,
    required this.idMenu,
    required this.idInventario,
    required this.cantidadStock,
  });
  final int? id;
  final DateTime createdAt;
  final int idRestaurante;
  final int idMenu;
  final int idInventario;
  final int cantidadStock;
}
