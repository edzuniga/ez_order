import 'package:ez_order_ezr/data/datos_grafico_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/reportes/puntos_grafico.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'datos_grafico_comparativo_ingresos.g.dart';

@Riverpod(keepAlive: true)
class DatosGraficoIngresos extends _$DatosGraficoIngresos {
  @override
  DatosGraficoModelo build() {
    return DatosGraficoModelo(
      xDates: [],
      xValues: [],
      xLabels: [],
      yValues: [],
      maxX: 0,
      maxY: 0,
    );
  }

  void setValoresDatosGrafico({
    required List<DateTime> xDates,
    required List<double> yValues,
  }) {
    List<int> xValues = [];
    List<String> xLabels = [];

    //Lógica para obtener los datos del gráfico
    for (int i = 0; i < xDates.length; i++) {
      xLabels.add('${xDates[i].day}');
      xValues.add(i);
    }

    double maxValue =
        yValues.isEmpty ? 0 : yValues.reduce((a, b) => a > b ? a : b);

    //Guardar el nuevo estado
    state = state.copyWith(
      xDates: xDates,
      xValues: xValues,
      xLabels: xLabels,
      yValues: yValues,
      maxX: xDates.length - 1,
      maxY: maxValue,
    );

    ref
        .read(puntosGraficoProvider.notifier)
        .setPuntosGraficos(xValues, yValues);
  }

  void resetState() {
    state = DatosGraficoModelo(
      xDates: [],
      xValues: [],
      xLabels: [],
      yValues: [],
      maxX: 0,
      maxY: 0,
    );
  }
}
