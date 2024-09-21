import 'package:ez_order_ezr/domain/registro_caja.dart';

class RegistroCajaModelo extends RegistroCaja {
  RegistroCajaModelo({
    super.id,
    required super.createdAt,
    required super.restauranteId,
    super.ingreso,
    super.egreso,
    super.proveedor,
    super.descripcion,
    super.uuidPedido,
  });

  factory RegistroCajaModelo.fromJson(Map<String, dynamic> json) =>
      RegistroCajaModelo(
          id: json['id'],
          createdAt: DateTime.parse(json['created_at']),
          restauranteId: json['restaurante_id'],
          ingreso: double.tryParse(json['ingreso'].toString()),
          egreso: double.tryParse(json['egreso'].toString()),
          proveedor: json['proveedor'],
          descripcion: json['descripcion'],
          uuidPedido: json['uuid_pedido']);

  Map<String, dynamic> toJson() => {
        "created_at": createdAt.toIso8601String(),
        "restaurante_id": restauranteId,
        "ingreso": ingreso,
        "egreso": egreso,
        "proveedor": proveedor,
        "descripcion": descripcion,
        "uuid_pedido": uuidPedido,
      };

  RegistroCajaModelo copyWith({
    final int? id,
    final DateTime? createdAt,
    final int? restauranteId,
    final double? ingreso,
    final double? egreso,
    final String? proveedor,
    final String? descripcion,
    final String? uuidPedido,
  }) =>
      RegistroCajaModelo(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        restauranteId: restauranteId ?? this.restauranteId,
        ingreso: ingreso ?? this.ingreso,
        egreso: egreso ?? this.egreso,
        proveedor: proveedor ?? this.proveedor,
        descripcion: descripcion ?? this.descripcion,
        uuidPedido: uuidPedido ?? this.uuidPedido,
      );
}
