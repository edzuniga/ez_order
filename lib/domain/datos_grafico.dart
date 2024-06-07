abstract class DatosGrafico {
  DatosGrafico({
    required this.xDates,
    required this.xValues,
    required this.xLabels,
    required this.yValues,
    required this.maxX,
    required this.maxY,
  });

  final List<DateTime> xDates;
  final List<int> xValues;
  final List<String> xLabels;
  final List<double> yValues;
  final double maxX;
  final double maxY;
}
