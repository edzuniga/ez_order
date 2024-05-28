abstract class MenuItem {
  MenuItem({
    this.idMenu,
    required this.numMenu,
    required this.descripcion,
    required this.otraInfo,
    this.img,
    required this.precio,
    required this.nombreItem,
    required this.idRestaurante,
    required this.precioIncluyeIsv,
    required this.vaParaCocina,
  });

  final int? idMenu;
  final String numMenu;
  final String descripcion;
  final String otraInfo;
  final String? img;
  final double precio;
  final String nombreItem;
  final int idRestaurante;
  final bool precioIncluyeIsv;
  final bool vaParaCocina;
}
