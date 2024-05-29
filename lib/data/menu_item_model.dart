import 'package:ez_order_ezr/domain/menu_item.dart';

class MenuItemModel extends MenuItem {
  MenuItemModel({
    super.idMenu,
    required super.numMenu,
    required super.descripcion,
    required super.otraInfo,
    super.img,
    required super.precioSinIsv,
    required super.precioConIsv,
    required super.nombreItem,
    required super.idRestaurante,
    required super.precioIncluyeIsv,
    required super.vaParaCocina,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      idMenu: json["id_menu"],
      numMenu: json["num_menu"],
      descripcion: json["descripcion"],
      otraInfo: json["otra_info"],
      img: json["img"],
      precioSinIsv: double.tryParse(json["precio_sin_isv"].toString())!,
      precioConIsv: double.tryParse(json["precio_con_isv"].toString())!,
      nombreItem: json["nombre_item"],
      idRestaurante: json["id_restaurante"],
      precioIncluyeIsv: json["precio_incluye_isv"],
      vaParaCocina: json["va_para_cocina"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "num_menu": numMenu,
      "descripcion": descripcion,
      "otra_info": otraInfo,
      "img": img,
      "precio_sin_isv": precioSinIsv,
      "precio_con_isv": precioConIsv,
      "nombre_item": nombreItem,
      "id_restaurante": idRestaurante,
      "precio_incluye_isv": precioIncluyeIsv,
      "va_para_cocina": vaParaCocina,
    };
  }

  MenuItemModel copyWith({
    int? idMenu,
    String? numMenu,
    String? descripcion,
    String? otraInfo,
    String? img,
    double? precioSinIsv,
    double? precioConIsv,
    String? nombreItem,
    int? idRestaurante,
    bool? precioIncluyeIsv,
    bool? vaParaCocina,
  }) {
    return MenuItemModel(
      idMenu: idMenu ?? this.idMenu,
      numMenu: numMenu ?? this.numMenu,
      descripcion: descripcion ?? this.descripcion,
      otraInfo: otraInfo ?? this.otraInfo,
      img: img ?? this.img,
      precioSinIsv: precioSinIsv ?? this.precioSinIsv,
      precioConIsv: precioConIsv ?? this.precioConIsv,
      nombreItem: nombreItem ?? this.nombreItem,
      idRestaurante: idRestaurante ?? this.idRestaurante,
      precioIncluyeIsv: precioIncluyeIsv ?? this.precioIncluyeIsv,
      vaParaCocina: vaParaCocina ?? this.vaParaCocina,
    );
  }
}
