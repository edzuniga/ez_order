import 'package:fl_chart/fl_chart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'puntos_grafico.g.dart';

@Riverpod(keepAlive: true)
class PuntosGrafico extends _$PuntosGrafico {
  @override
  List<FlSpot> build() {
    return [];
  }

  void setPuntosGraficos(List<int> xValues, List<double> yValues) {
    for (int i = 0; i < xValues.length; i++) {
      state.add(FlSpot(xValues[i].toDouble(), yValues[i]));
    }
  }
}
