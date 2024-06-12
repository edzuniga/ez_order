import 'package:ez_order_ezr/domain/categoria.dart';

class CategoriaModelo extends Categoria {
  CategoriaModelo({
    super.idCategoria,
    required super.nombreCategoria,
    required super.idRestaurante,
    required super.activo,
  });

  factory CategoriaModelo.fromJson(Map<String, dynamic> json) =>
      CategoriaModelo(
        idCategoria: json['id_categoria'],
        nombreCategoria: json['nombre_categoria'],
        idRestaurante: json['id_restaurante'],
        activo: json['activo'],
      );

  Map<String, dynamic> toJson() => {
        //'id_categoria': idCategoria,
        'nombre_categoria': nombreCategoria,
        'id_restaurante': idRestaurante,
        'activo': activo,
      };

  CategoriaModelo copyWith({
    required int? idCategoria,
    required String? nombreCategoria,
    required int? idRestaurante,
    required bool? activo,
  }) =>
      CategoriaModelo(
        idCategoria: idCategoria ?? this.idCategoria,
        nombreCategoria: nombreCategoria ?? this.nombreCategoria,
        idRestaurante: idRestaurante ?? this.idRestaurante,
        activo: activo ?? this.activo,
      );

  //Method to prevent toString override
  String categoriaAsString() => nombreCategoria;
}
