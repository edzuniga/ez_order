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
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      uuidPedido: json["uuid_pedido"],
      idRestaurante: json["id_restaurante"],
      descuento: double.tryParse(json["descuento"].toString())!,
      impuestos: double.tryParse(json["impuestos"].toString())!,
      subtotal: double.tryParse(json["subtotal"].toString())!,
      total: double.tryParse(json["total"].toString())!,
      notaAdicional: json["nota_adicional"],
      importeExonerado: double.tryParse(json["importe_Exonerado"].toString())!,
      importeExento: double.tryParse(json["importe_Exento"].toString())!,
      importeGravado: double.tryParse(json["importe_gravado"].toString())!,
      isvAplicado: json["isv_aplicado"],
      orden: json["orden"],
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
      "importe_Exonerado": importeExonerado,
      "importe_Exento": importeExento,
      "importe_gravado": importeGravado,
      "isv_aplicado": isvAplicado,
      "orden": orden,
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
    );
  }
}
