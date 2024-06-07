import 'package:ez_order_ezr/domain/reporte.dart';

class ReporteModelo extends Reporte {
  ReporteModelo({
    required super.cantMenu,
    required super.cantPedidosDiarios,
    required super.ingresosDiarios,
    required super.clientes,
    required super.totalEfectivo,
    required super.totalTarjeta,
    required super.totalTransferencia,
  });

  ReporteModelo copyWith({
    int? cantMenu,
    int? cantPedidosDiarios,
    double? ingresosDiarios,
    int? clientes,
    double? totalEfectivo,
    double? totalTarjeta,
    double? totalTransferencia,
  }) {
    return ReporteModelo(
      cantMenu: cantMenu ?? this.cantMenu,
      cantPedidosDiarios: cantPedidosDiarios ?? this.cantPedidosDiarios,
      ingresosDiarios: ingresosDiarios ?? this.ingresosDiarios,
      clientes: clientes ?? this.clientes,
      totalEfectivo: totalEfectivo ?? this.totalEfectivo,
      totalTarjeta: totalTarjeta ?? this.totalTarjeta,
      totalTransferencia: totalTransferencia ?? this.totalTransferencia,
    );
  }
}
