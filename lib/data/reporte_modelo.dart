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
    required super.cantEfectivo,
    required super.cantTarjeta,
    required super.cantTransferencia,
  });

  ReporteModelo copyWith({
    int? cantMenu,
    int? cantPedidosDiarios,
    double? ingresosDiarios,
    int? clientes,
    double? totalEfectivo,
    double? totalTarjeta,
    double? totalTransferencia,
    int? cantEfectivo,
    int? cantTarjeta,
    int? cantTransferencia,
  }) {
    return ReporteModelo(
      cantMenu: cantMenu ?? this.cantMenu,
      cantPedidosDiarios: cantPedidosDiarios ?? this.cantPedidosDiarios,
      ingresosDiarios: ingresosDiarios ?? this.ingresosDiarios,
      clientes: clientes ?? this.clientes,
      totalEfectivo: totalEfectivo ?? this.totalEfectivo,
      totalTarjeta: totalTarjeta ?? this.totalTarjeta,
      totalTransferencia: totalTransferencia ?? this.totalTransferencia,
      cantEfectivo: cantEfectivo ?? this.cantEfectivo,
      cantTarjeta: cantTarjeta ?? this.cantTarjeta,
      cantTransferencia: cantTransferencia ?? this.cantTransferencia,
    );
  }
}
