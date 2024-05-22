import 'package:ez_order_ezr/domain/menu_item.dart';

class MenuItemModel extends MenuItem {
  MenuItemModel({
    super.idMenu,
    required super.numMenu,
    required super.descripcion,
    required super.otraInfo,
    super.img,
    required super.precio,
    required super.nombreItem,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      idMenu: json["id_menu"],
      numMenu: json["num_menu"],
      descripcion: json["descripcion"],
      otraInfo: json["otra_info"],
      img: json["img"],
      precio: json["precio"],
      nombreItem: json["nombre_item"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "num_menu": numMenu,
      "descripcion": descripcion,
      "otra_info": otraInfo,
      "img": img,
      "precio": precio,
      "nombre_item": nombreItem,
    };
  }

  MenuItemModel copyWith({
    String? idMenu,
    String? numMenu,
    String? descripcion,
    String? otraInfo,
    String? img,
    double? precio,
    String? nombreItem,
  }) {
    return MenuItemModel(
      idMenu: idMenu ?? this.idMenu,
      numMenu: numMenu ?? this.numMenu,
      descripcion: descripcion ?? this.descripcion,
      otraInfo: otraInfo ?? this.otraInfo,
      precio: precio ?? this.precio,
      nombreItem: nombreItem ?? this.nombreItem,
    );
  }
}
