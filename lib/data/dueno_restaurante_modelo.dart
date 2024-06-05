import 'package:ez_order_ezr/domain/dueno_restaurante.dart';

class DuenoRestauranteModelo extends DuenoRestaurante {
  DuenoRestauranteModelo({
    required super.id,
    required super.uuidDueno,
    required super.idRestaurante,
  });

  factory DuenoRestauranteModelo.fromJson(Map<String, dynamic> json) {
    return DuenoRestauranteModelo(
      id: json['id'],
      uuidDueno: json['uuid_dueno'],
      idRestaurante: json['id_restaurante'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uuid_dueno": uuidDueno,
      "id_restaurante": idRestaurante,
    };
  }

  DuenoRestauranteModelo copyWith({
    int? id,
    String? uuidDueno,
    int? idRestaurante,
  }) {
    return DuenoRestauranteModelo(
      id: id ?? this.id,
      uuidDueno: uuidDueno ?? this.uuidDueno,
      idRestaurante: idRestaurante ?? this.idRestaurante,
    );
  }
}
