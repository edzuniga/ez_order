import 'package:ez_order_ezr/domain/menu_inventario.dart';

class MenuInventarioModelo extends MenuInventario {
  MenuInventarioModelo({
    super.id,
    required super.createdAt,
    required super.idRestaurante,
    required super.idMenu,
    required super.idInventario,
    required super.cantidadStock,
  });

  factory MenuInventarioModelo.fromJson(Map<String, dynamic> json) =>
      MenuInventarioModelo(
        id: json['id'] is int ? json['id'] : int.parse(json['id']),
        createdAt: DateTime.parse(json['created_at']),
        idRestaurante: json['id_restaurante'] is int
            ? json['id_restaurante']
            : int.parse(json['id_restaurante']),
        idMenu: json['id_menu'] is int
            ? json['id_menu']
            : int.parse(json['id_menu']),
        idInventario: json['id_inventario'] is int
            ? json['id_inventario']
            : int.parse(json['id_inventario']),
        cantidadStock: json['cantidad_stock'] is int
            ? json['cantidad_stock']
            : int.parse(json['cantidad_stock']),
      );

  Map<String, dynamic> toJson() => {
        'created_at': createdAt.toIso8601String(),
        'id_restaurante': idRestaurante,
        'id_menu': idMenu,
        'id_inventario': idInventario,
        'cantidad_stock': cantidadStock,
      };

  MenuInventarioModelo copyWith({
    int? id,
    DateTime? createdAt,
    int? idRestaurante,
    int? idMenu,
    int? idInventario,
    int? cantidadStock,
  }) =>
      MenuInventarioModelo(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        idRestaurante: idRestaurante ?? this.idRestaurante,
        idMenu: idMenu ?? this.idMenu,
        idInventario: idInventario ?? this.idInventario,
        cantidadStock: cantidadStock ?? this.cantidadStock,
      );
}
