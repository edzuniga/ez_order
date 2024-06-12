abstract class Categoria {
  Categoria({
    this.idCategoria,
    required this.nombreCategoria,
    required this.idRestaurante,
    required this.activo,
  });
  final int? idCategoria;
  final String nombreCategoria;
  final int idRestaurante;
  final bool activo;
}
