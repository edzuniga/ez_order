import 'package:ez_order_ezr/domain/inventario.dart';

class InventarioModelo extends Inventario {
  InventarioModelo({
    super.id,
    required super.createdAt,
    required super.idRestaurante,
    super.codigo,
    required super.nombre,
    super.descripcion,
    required super.precioCosto,
    required super.stock,
    super.proveedor,
  });

  factory InventarioModelo.fromJson(Map<String, dynamic> json) =>
      InventarioModelo(
        id: json['id'] is int ? json['id'] : int.parse(json['id']),
        createdAt: DateTime.parse(json['created_at']),
        idRestaurante: json['id_restaurante'] is int
            ? json['id_restaurante']
            : int.parse(json['id_restaurante']),
        codigo: json['codigo'],
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        precioCosto: double.parse(json['precio_costo'].toString()),
        stock: json['stock'] is int
            ? json['stock']
            : int.parse(json['stock'].toString()),
        proveedor: json['proveedor'],
      );

  Map<String, dynamic> toJson() => {
        'created_at': createdAt.toIso8601String(),
        'id_restaurante': idRestaurante,
        'codigo': codigo,
        'nombre': nombre,
        'descripcion': descripcion,
        'precio_costo': precioCosto,
        'stock': stock,
        'proveedor': proveedor,
      };

  InventarioModelo copyWith({
    int? id,
    DateTime? createdAt,
    int? idRestaurante,
    String? codigo,
    String? nombre,
    String? descripcion,
    double? precioCosto,
    int? stock,
    String? proveedor,
  }) =>
      InventarioModelo(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        idRestaurante: idRestaurante ?? this.idRestaurante,
        codigo: codigo ?? this.codigo,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion ?? this.descripcion,
        precioCosto: precioCosto ?? this.precioCosto,
        stock: stock ?? this.stock,
        proveedor: proveedor ?? this.proveedor,
      );
}
