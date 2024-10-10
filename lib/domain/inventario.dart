abstract class Inventario {
  Inventario({
    this.id,
    required this.createdAt,
    required this.idRestaurante,
    this.codigo,
    required this.nombre,
    this.descripcion,
    required this.precioCosto,
    required this.stock,
    this.proveedor,
  });

  final int? id;
  final DateTime createdAt;
  final int idRestaurante;
  final String? codigo;
  final String nombre;
  final String? descripcion;
  final double precioCosto;
  final int stock;
  final String? proveedor;
}
