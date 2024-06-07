import 'package:fl_chart/fl_chart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ez_order_ezr/data/datos_grafico_modelo.dart';
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
      puntos: [],
    );
  }

  void setValoresDatosGrafico({
    required List<DateTime> xDates,
    required List<double> yValues,
  }) {
    List<int> xValues = [];
    List<String> xLabels = [];
    List<FlSpot> listadoPuntos = [];

    //Lógica para obtener los datos del gráfico
    for (int i = 0; i < xDates.length; i++) {
      xLabels.add('${xDates[i].day}');
      xValues.add(i);
    }

    double maxValue =
        yValues.isEmpty ? 0 : yValues.reduce((a, b) => a > b ? a : b);

    //Crear los puntos para el gráfico
    for (int i = 0; i < xValues.length; i++) {
      listadoPuntos.add(FlSpot(xValues[i].toDouble(), yValues[i]));
    }

    //Guardar el nuevo estado
    state = state.copyWith(
      xDates: xDates,
      xValues: xValues,
      xLabels: xLabels,
      yValues: yValues,
      maxX: xDates.length - 1,
      maxY: maxValue,
      puntos: listadoPuntos,
    );
  }

  void resetState() {
    state = DatosGraficoModelo(
      xDates: [],
      xValues: [],
      xLabels: [],
      yValues: [],
      maxX: 0,
      maxY: 0,
      puntos: [],
    );
  }
}
