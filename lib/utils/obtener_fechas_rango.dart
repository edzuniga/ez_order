List<DateTime> obtenerFechasEntre(DateTime fechaInicial, DateTime fechaFinal) {
  List<DateTime> fechas = [];
  DateTime fechaActual = fechaInicial;

  while (fechaActual.isBefore(fechaFinal) ||
      fechaActual.isAtSameMomentAs(fechaFinal)) {
    fechas.add(fechaActual);
    fechaActual = fechaActual.add(Duration(days: 1));
  }
  return fechas;
}
