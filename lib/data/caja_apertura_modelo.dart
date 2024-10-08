import 'package:ez_order_ezr/domain/caja_apertura.dart';

class CajaAperturaModelo extends CajaApertura {
  CajaAperturaModelo({
    super.id,
    required super.restauranteUid,
    required super.createdAt,
    required super.cantidad,
    super.cantidadCierre,
    super.totalEfectivo,
    super.totalTarjeta,
    super.totalTransferencia,
    super.totalGastos,
    super.cierreCaja,
  });

  factory CajaAperturaModelo.fromJson(Map<String, dynamic> json) =>
      CajaAperturaModelo(
        id: json['id'],
        restauranteUid: json['restaurante_uid'],
        createdAt: DateTime.parse(json['created_at']),
        cantidad: double.parse(json['cantidad'].toString()),
        cantidadCierre: double.tryParse(json['cantidad_cierre'].toString()),
        totalEfectivo: double.tryParse(json['total_efectivo'].toString()),
        totalTarjeta: double.tryParse(json['total_tarjeta'].toString()),
        totalTransferencia:
            double.tryParse(json['total_transferencia'].toString()),
        totalGastos: double.tryParse(json['total_gastos'].toString()),
        cierreCaja: double.tryParse(json['cierre_caja'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'restaurante_uid': restauranteUid,
        'created_at': createdAt.toIso8601String(),
        'cantidad': cantidad,
        'cantidad_cierre': cantidadCierre,
        'total_efectivo': totalEfectivo,
        'total_tarjeta': totalTarjeta,
        'total_transferencia': totalTransferencia,
        'total_gastos': totalGastos,
        'cierre_caja': cierreCaja,
      };

  CajaAperturaModelo copyWith({
    int? id,
    int? restauranteUid,
    DateTime? createdAt,
    double? cantidad,
    double? cantidadCierre,
    double? totalEfectivo,
    double? totalTarjeta,
    double? totalTransferencia,
    double? totalGastos,
    double? cierreCaja,
  }) =>
      CajaAperturaModelo(
        id: id ?? this.id,
        restauranteUid: restauranteUid ?? this.restauranteUid,
        createdAt: createdAt ?? this.createdAt,
        cantidad: cantidad ?? this.cantidad,
        cantidadCierre: cantidadCierre ?? this.cantidadCierre,
        totalEfectivo: totalEfectivo ?? this.totalEfectivo,
        totalTarjeta: totalTarjeta ?? this.totalTarjeta,
        totalTransferencia: totalTransferencia ?? this.totalTransferencia,
        totalGastos: totalGastos ?? this.totalGastos,
        cierreCaja: cierreCaja ?? this.cierreCaja,
      );
}
