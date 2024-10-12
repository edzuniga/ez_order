import 'package:ez_order_ezr/domain/movimiento_inventario.dart';

class MovimientoInventarioModelo extends MovimientoInventario {
  MovimientoInventarioModelo({
    super.id,
    required super.createdAt,
    required super.idInventario,
    required super.descripcion,
    required super.stock,
    required super.tipo,
    required super.idRestaurante,
  });

  factory MovimientoInventarioModelo.fromJson(Map<String, dynamic> json) =>
      MovimientoInventarioModelo(
        id: json['id'] is int ? json['id'] : int.parse(json['id']),
        createdAt: DateTime.parse(json['created_at']),
        idInventario: json['id_inventario'] is int
            ? json['id_inventario']
            : int.parse(json['id_inventario']),
        descripcion: json['descripcion'],
        stock: json['stock'] is int ? json['stock'] : int.parse(json['stock']),
        tipo: json['tipo'] is int ? json['tipo'] : int.parse(json['tipo']),
        idRestaurante: json['id_restaurante'] is int
            ? json['id_restaurante']
            : int.parse(json['id_restaurante']),
      );

  Map<String, dynamic> toJson() => {
        'created_at': createdAt.toIso8601String(),
        'id_inventario': idInventario,
        'descripcion': descripcion,
        'stock': stock,
        'tipo': tipo,
        'id_restaurante': idRestaurante,
      };
}
