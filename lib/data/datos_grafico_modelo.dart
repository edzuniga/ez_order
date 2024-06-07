import 'package:ez_order_ezr/domain/datos_grafico.dart';

class DatosGraficoModelo extends DatosGrafico {
  DatosGraficoModelo({
    required super.xDates,
    required super.xValues,
    required super.xLabels,
    required super.yValues,
    required super.maxX,
    required super.maxY,
  });

  DatosGraficoModelo copyWith({
    List<DateTime>? xDates,
    List<int>? xValues,
    List<String>? xLabels,
    List<double>? yValues,
    double? maxX,
    double? maxY,
  }) {
    return DatosGraficoModelo(
      xDates: xDates ?? this.xDates,
      xValues: xValues ?? this.xValues,
      xLabels: xLabels ?? this.xLabels,
      yValues: yValues ?? this.yValues,
      maxX: maxX ?? this.maxX,
      maxY: maxY ?? this.maxY,
    );
  }
}
