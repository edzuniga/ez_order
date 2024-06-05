abstract class Restaurante {
  Restaurante({
    this.idRestaurante,
    required this.createdAt,
    required this.nombreRestaurante,
    this.direccion,
    this.lat,
    this.lon,
    this.img,
  });

  final int? idRestaurante;
  final DateTime createdAt;
  final String nombreRestaurante;
  final String? direccion;
  final String? lat;
  final String? lon;
  final String? img;
}
