import 'package:ez_order_ezr/domain/pedido.dart';

class PedidoModel extends Pedido {
  PedidoModel({
    super.uuidPedido,
    required super.idRestaurante,
    required super.descuento,
    required super.impuestos,
    required super.subtotal,
    required super.total,
    super.notaAdicional,
    super.importeExonerado,
    super.importeExento,
    super.importeGravado,
    super.isvAplicado,
    required super.orden,
    required super.idCliente,
    required super.numPedido,
    required super.idMetodoPago,
    required super.enPreparacion,
    required super.createdAt,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      uuidPedido: json["uuid_pedido"],
      idRestaurante: json["id_restaurante"],
      descuento: json["descuento"] != null
          ? double.tryParse(json["descuento"].toString())!
          : 0.0,
      impuestos: json["impuestos"] != null
          ? double.tryParse(json["impuestos"].toString())!
          : 0.0,
      subtotal: json["subtotal"] != null
          ? double.tryParse(json["subtotal"].toString())!
          : 0.0,
      total:
          json["total"] != 0 ? double.tryParse(json["total"].toString())! : 0.0,
      notaAdicional: json["nota_adicional"].toString(),
      importeExonerado: json["importe_exonerado"] != null
          ? double.tryParse(json["importe_exonerado"].toString())!
          : 0.0,
      importeExento: json["importe_exento"] != null
          ? double.tryParse(json["importe_exento"].toString())!
          : 0.0,
      importeGravado: json["importe_gravado"] != null
          ? double.tryParse(json["importe_gravado"].toString())!
          : 0.0,
      isvAplicado: json["isv_aplicado"],
      orden: json["orden"].toString(),
      idCliente: json["id_cliente"] ?? 0,
      numPedido: json["num_pedido"] ?? 0,
      idMetodoPago: json["id_metodo_pago"] ?? 0,
      enPreparacion: json["en_preparacion"] ?? false,
      createdAt: DateTime.parse(json["created_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_restaurante": idRestaurante,
      "descuento": descuento,
      "impuestos": impuestos,
      "subtotal": subtotal,
      "total": total,
      "nota_adicional": notaAdicional,
      "importe_exonerado": importeExonerado,
      "importe_exento": importeExento,
      "importe_gravado": importeGravado,
      "isv_aplicado": isvAplicado,
      "orden": orden,
      "id_cliente": idCliente,
      "num_pedido": numPedido,
      "id_metodo_pago": idMetodoPago,
      "en_preparacion": enPreparacion,
      "created_at": createdAt.toIso8601String(),
    };
  }

  PedidoModel copyWith({
    String? uuidPedido,
    int? idRestaurante,
    double? descuento,
    double? impuestos,
    double? subtotal,
    double? total,
    String? notaAdicional,
    double? importeExonerado,
    double? importeExento,
    double? importeGravado,
    String? isvAplicado,
    String? orden,
    int? idCliente,
    int? numPedido,
    int? idMetodoPago,
    bool? enPreparacion,
    DateTime? createdAt,
  }) {
    return PedidoModel(
      uuidPedido: uuidPedido ?? this.uuidPedido,
      idRestaurante: idRestaurante ?? this.idRestaurante,
      descuento: descuento ?? this.descuento,
      impuestos: impuestos ?? this.impuestos,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      notaAdicional: notaAdicional ?? this.notaAdicional,
      importeExonerado: importeExonerado ?? this.importeExonerado,
      importeExento: importeExento ?? this.importeExento,
      importeGravado: importeGravado ?? this.importeGravado,
      isvAplicado: isvAplicado ?? this.isvAplicado,
      orden: orden ?? this.orden,
      idCliente: idCliente ?? this.idCliente,
      numPedido: numPedido ?? this.numPedido,
      idMetodoPago: idMetodoPago ?? this.idMetodoPago,
      enPreparacion: enPreparacion ?? this.enPreparacion,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
