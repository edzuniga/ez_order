import 'package:ez_order_ezr/domain/caja_abierta.dart';

class CajaAbiertaModelo extends CajaAbierta {
  CajaAbiertaModelo({
    super.id,
    required super.createdAt,
    required super.restauranteUid,
    required super.abierto,
  });

  factory CajaAbiertaModelo.fromJson(Map<String, dynamic> json) =>
      CajaAbiertaModelo(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        restauranteUid: json['restaurante_uid'],
        abierto: json['abierto'],
      );

  Map<String, dynamic> toJson() => {
        'created_At': createdAt,
        'restaurante_uid': restauranteUid,
        'abierto': abierto,
      };

  CajaAbiertaModelo copyWith({
    int? id,
    DateTime? createdAt,
    int? restauranteUid,
    bool? abierto,
  }) =>
      CajaAbiertaModelo(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        restauranteUid: restauranteUid ?? this.restauranteUid,
        abierto: abierto ?? this.abierto,
      );
}
