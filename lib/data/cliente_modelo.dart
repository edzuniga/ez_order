import 'package:ez_order_ezr/domain/cliente.dart';

class ClienteModelo extends Cliente {
  ClienteModelo({
    super.idCliente,
    super.rtnCliente,
    required super.nombreCliente,
    super.correoCliente,
    super.descuentoCliente,
    required super.idRestaurante,
    required super.exonerado,
  });

  factory ClienteModelo.fromJson(Map<String, dynamic> json) {
    return ClienteModelo(
      idCliente: json["id_cliente"],
      rtnCliente: json["rtn_cliente"],
      nombreCliente: json["nombre_cliente"],
      correoCliente: json["correo_cliente"],
      descuentoCliente: json["descuento_cliente"] != null
          ? double.tryParse(json["descuento_cliente"].toString())
          : 0.0,
      idRestaurante: json["id_restaurante"],
      exonerado: json["exonerado"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "rtn_cliente": rtnCliente,
      "nombre_cliente": nombreCliente,
      "correo_cliente": correoCliente,
      "descuento_cliente": descuentoCliente,
      "id_restaurante": idRestaurante,
      "exonerado": exonerado,
    };
  }

  ClienteModelo copyWith({
    int? idCliente,
    String? rtnCliente,
    String? nombreCliente,
    String? correoCliente,
    double? descuentoCliente,
    int? idRestaurante,
    bool? exonerado,
  }) {
    return ClienteModelo(
      idCliente: idCliente ?? this.idCliente,
      rtnCliente: rtnCliente ?? this.rtnCliente,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      correoCliente: correoCliente ?? this.correoCliente,
      descuentoCliente: descuentoCliente ?? this.descuentoCliente,
      idRestaurante: idRestaurante ?? this.idRestaurante,
      exonerado: exonerado ?? this.exonerado,
    );
  }

  //this method will prevent the override of toString
  String clienteAsString() {
    return nombreCliente;
  }
}
