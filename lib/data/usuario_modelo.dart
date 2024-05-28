import 'package:ez_order_ezr/domain/usuario.dart';

class UsuarioModelo extends Usuario {
  UsuarioModelo({
    super.uuidUsuario,
    required super.email,
    required super.nombre,
    required super.rol,
    required super.idRestaurante,
  });

  factory UsuarioModelo.fromJson(Map<String, dynamic> json) {
    return UsuarioModelo(
      uuidUsuario: json["uuid_usuario"],
      email: json["email"],
      nombre: json["nombre"],
      rol: json["rol"],
      idRestaurante: json["id_restaurante"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uuid_usuario": uuidUsuario,
      "email": email,
      "nombre": nombre,
      "rol": rol,
      "id_restaurante": idRestaurante,
    };
  }

  UsuarioModelo copyWith(
    String? uuidUsuario,
    String? email,
    String? nombre,
    int? rol,
    int? idRestaurante,
  ) {
    return UsuarioModelo(
      uuidUsuario: uuidUsuario ?? this.uuidUsuario,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      idRestaurante: idRestaurante ?? this.idRestaurante,
    );
  }
}
