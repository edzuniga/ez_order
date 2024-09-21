import 'package:ez_order_ezr/domain/caja_apertura.dart';

class CajaAperturaModelo extends CajaApertura {
  CajaAperturaModelo({
    super.id,
    required super.restauranteUid,
    required super.createdAt,
    required super.cantidad,
    super.cantidadCierre,
  });

  factory CajaAperturaModelo.fromJson(Map<String, dynamic> json) =>
      CajaAperturaModelo(
        id: json['id'],
        restauranteUid: json['restaurante_uid'],
        createdAt: DateTime.parse(json['created_at']),
        cantidad: double.parse(json['cantidad'].toString()),
        cantidadCierre: double.tryParse(json['cantidad_cierre'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'restaurante_uid': restauranteUid,
        'created_at': createdAt.toIso8601String(),
        'cantidad': cantidad,
        'cantidad_cierre': cantidadCierre,
      };

  CajaAperturaModelo copyWith({
    int? id,
    int? restauranteUid,
    DateTime? createdAt,
    double? cantidad,
    double? cantidadCierre,
  }) =>
      CajaAperturaModelo(
        id: id ?? this.id,
        restauranteUid: restauranteUid ?? this.restauranteUid,
        createdAt: createdAt ?? this.createdAt,
        cantidad: cantidad ?? this.cantidad,
        cantidadCierre: cantidadCierre ?? this.cantidadCierre,
      );
}
