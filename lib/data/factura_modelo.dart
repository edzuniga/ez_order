import 'package:ez_order_ezr/domain/factura.dart';

class FacturaModelo extends Factura {
  FacturaModelo({
    required super.idFactura,
    required super.idRestaurante,
    required super.uuidPedido,
    super.rtn,
    super.direccion,
    super.correo,
    super.telefono,
    super.cai,
    super.numFactura,
    required super.fechaFactura,
    super.idCliente,
    super.total,
    super.nombreCliente,
  });

  factory FacturaModelo.fromJson(Map<String, dynamic> json) => FacturaModelo(
        idFactura: json['id_factura'],
        idRestaurante: json['id_restaurante'],
        uuidPedido: json['uuid_pedido'],
        rtn: json['rtn'],
        direccion: json['direccion'],
        correo: json['correo'],
        telefono: json['telefono'],
        cai: json['cai'],
        numFactura: json['num_factura'],
        fechaFactura: DateTime.parse(json['fecha_factura']),
        idCliente: json['id_cliente'],
        total: double.tryParse(json['total'].toString())!,
      );

  Map<String, dynamic> toJson() => {
        //"id_Factura": idFactura,
        "id_restaurante": idRestaurante,
        "uuid_pedido": uuidPedido,
        "rtn": rtn,
        "direccion": direccion,
        "correo": correo,
        "telefono": telefono,
        "cai": cai,
        "num_factura": numFactura,
        "fecha_factura": fechaFactura.toIso8601String(),
        "id_cliente": idCliente,
        "total": total,
      };

  FacturaModelo copyWith({
    int? idFactura,
    int? idRestaurante,
    String? uuidPedido,
    String? rtn,
    String? direccion,
    String? correo,
    String? telefono,
    String? cai,
    int? numFactura,
    DateTime? fechaFactura,
    int? idCliente,
    double? total,
    String? nombreCliente,
  }) =>
      FacturaModelo(
        idFactura: idFactura ?? this.idFactura,
        idRestaurante: idRestaurante ?? this.idRestaurante,
        uuidPedido: uuidPedido ?? this.uuidPedido,
        rtn: rtn ?? this.rtn,
        direccion: direccion ?? this.direccion,
        correo: correo ?? this.correo,
        telefono: telefono ?? this.telefono,
        cai: cai ?? this.cai,
        numFactura: numFactura ?? this.numFactura,
        fechaFactura: fechaFactura ?? this.fechaFactura,
        idCliente: idCliente ?? this.idCliente,
        total: total ?? this.total,
        nombreCliente: nombreCliente ?? this.nombreCliente,
      );
}
