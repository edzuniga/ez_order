import 'package:ez_order_ezr/domain/restaurant.dart';

class RestauranteModelo extends Restaurante {
  RestauranteModelo({
    super.idRestaurante,
    required super.createdAt,
    required super.nombreRestaurante,
    super.direccion,
    super.lat,
    super.lon,
    super.img,
  });

  factory RestauranteModelo.fromJson(Map<String, dynamic> json) {
    return RestauranteModelo(
      idRestaurante: json['id_restaurante'],
      createdAt: DateTime.parse(json['created_at']),
      nombreRestaurante: json['nombre_restaurante'],
      direccion: json['direccion'],
      lat: json['lat'],
      lon: json['lon'],
      img: json['img'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_restaurante": idRestaurante,
      "created_at": createdAt.toIso8601String(),
      "nombre_restaurante": nombreRestaurante,
      "direccion": direccion,
      "lat": lat,
      "lon": lon,
      "img": img,
    };
  }

  RestauranteModelo copyWith({
    int? idRestaurante,
    DateTime? createdAt,
    String? nombreRestaurante,
    String? direccion,
    String? lat,
    String? lon,
    String? img,
  }) {
    return RestauranteModelo(
      idRestaurante: idRestaurante ?? this.idRestaurante,
      createdAt: createdAt ?? this.createdAt,
      nombreRestaurante: nombreRestaurante ?? this.nombreRestaurante,
      direccion: direccion ?? this.direccion,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      img: img ?? this.img,
    );
  }

  //this method will prevent the override of toString
  String restauranteAsString() {
    return nombreRestaurante;
  }
}
