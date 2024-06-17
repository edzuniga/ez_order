import 'package:ez_order_ezr/domain/datos_factura.dart';

class DatosFacturaModelo extends DatosFactura {
  DatosFacturaModelo({
    required super.idDatosFactura,
    required super.idRestaurante,
    required super.nombreNegocio,
    required super.rtn,
    required super.direccion,
    required super.correo,
    required super.telefono,
    required super.cai,
    required super.rangoInicial,
    required super.rangoFinal,
    required super.fechaLimite,
  });

  factory DatosFacturaModelo.fromJson(Map<String, dynamic> json) =>
      DatosFacturaModelo(
        idDatosFactura: json['id_datos_factura'],
        idRestaurante: json['id_restaurante'],
        nombreNegocio: json['nombre_negocio'],
        rtn: json['rtn'],
        direccion: json['direccion'],
        correo: json['correo'],
        telefono: json['telefono'],
        cai: json['cai'],
        rangoInicial: json['rango_inicial'],
        rangoFinal: json['rango_final'],
        fechaLimite: DateTime.parse(json['fecha_limite']),
      );

  Map<String, dynamic> toJson() => {
        //'id_datos_factura': idDatosFactura,
        'id_restaurante': idRestaurante,
        'nombre_negocio': nombreNegocio,
        'rtn': rtn,
        'direccion': direccion,
        'correo': correo,
        'telefono': telefono,
        'cai': cai,
        'rango_inicial': rangoInicial,
        'rango_final': rangoFinal,
        'fecha_limite': fechaLimite.toIso8601String(),
      };

  DatosFacturaModelo copyWith({
    required int? idDatosFactura,
    required int? idRestaurante,
    required String? nombreNegocio,
    required String? rtn,
    required String? direccion,
    required String? correo,
    required String? telefono,
    required String? cai,
    required int? rangoInicial,
    required int? rangoFinal,
    required DateTime? fechaLimite,
  }) =>
      DatosFacturaModelo(
        idDatosFactura: idDatosFactura ?? this.idDatosFactura,
        idRestaurante: idRestaurante ?? this.idRestaurante,
        nombreNegocio: nombreNegocio ?? this.nombreNegocio,
        rtn: rtn ?? this.rtn,
        direccion: direccion ?? this.direccion,
        correo: correo ?? this.correo,
        telefono: telefono ?? this.telefono,
        cai: cai ?? this.cai,
        rangoInicial: rangoInicial ?? this.rangoInicial,
        rangoFinal: rangoFinal ?? this.rangoFinal,
        fechaLimite: fechaLimite ?? this.fechaLimite,
      );
}
