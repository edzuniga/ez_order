import 'package:ez_order_ezr/domain/Reporte.dart';

class ReporteModelo extends Reporte {
  ReporteModelo({
    required super.cantMenu,
    required super.cantPedidosDiarios,
    required super.ingresosDiarios,
  });

  ReporteModelo copyWith({
    int? cantMenu,
    int? cantPedidosDiarios,
    double? ingresosDiarios,
  }) {
    return ReporteModelo(
      cantMenu: cantMenu ?? this.cantMenu,
      cantPedidosDiarios: cantPedidosDiarios ?? this.cantPedidosDiarios,
      ingresosDiarios: ingresosDiarios ?? this.ingresosDiarios,
    );
  }
}
