import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:ez_order_ezr/presentation/providers/reportes/table_rows.dart';
import 'package:ez_order_ezr/data/datos_grafico_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/reportes/datos_grafico_comparativo_ingresos.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/utils/obtener_fechas_rango.dart';
import 'package:ez_order_ezr/data/reporte_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/duenos_restaurantes/reportes_valores_provider.dart';
import 'package:ez_order_ezr/presentation/providers/duenos_restaurantes/restaurante_seleccionado_provider.dart';
import 'package:ez_order_ezr/data/restaurante_modelo.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/duenos_restaurantes/duenos_restaurantes_provider.dart';
import 'package:ez_order_ezr/presentation/widgets/pedidos_widgets/estadistica_sencilla_widget.dart';

class ReportesView extends ConsumerStatefulWidget {
  const ReportesView({super.key});

  @override
  ConsumerState<ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends ConsumerState<ReportesView> {
  final GlobalKey<FormState> _reporteFormKey = GlobalKey<FormState>();
  String? _fechaInicial;
  String? _fechaFinal;
  DateTime? _initialDate;
  DateTime? _finalDate;
  DateTime hoy = DateTime.now();
  bool _isShowingReport = false;
  bool _isUpdatingDatosDiarios = false;
  bool _isRetrievingGraphData = false;

  @override
  void initState() {
    super.initState();
    //Poblar dropdown de restaurantes
    _obtenerRestaurantes();
  }

  Future<List<RestauranteModelo>> _obtenerRestaurantes() async {
    return await ref
        .read(duenosResManagerProvider.notifier)
        .obtenerRestaurantesPorDueno();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Provider de datos del gráfico ingresos
    DatosGraficoModelo datosGrafico = ref.watch(datosGraficoIngresosProvider);
    RestauranteModelo restauranteActual =
        ref.watch(restauranteSeleccionadoProvider);
    ReporteModelo valoresReporte = ref.watch(valoresReportesProvider);
    List<DataRow> rowsTable = ref.watch(pedidosTableRowsProvider);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _reporteFormKey,
            child: Column(
              children: [
                //Selector de restaurantes del DUEÑO
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        height: 48,
                        width: 350,
                        child: DropdownSearch<RestauranteModelo>(
                          asyncItems: (filter) async {
                            return await _obtenerRestaurantes();
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              hintText: 'Seleccione restaurante',
                              hintStyle: GoogleFonts.inter(
                                color: AppColors.kTextSecondaryGray,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.kGeneralPrimaryOrange,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.kGeneralErrorColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.kGeneralErrorColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: AppColors.kInputLiteGray,
                            ),
                          ),
                          itemAsString: (RestauranteModelo r) =>
                              r.restauranteAsString(),
                          onChanged: (RestauranteModelo? data) async {
                            if (data != null) {
                              //Asignar el restaurante selecto al provider
                              ref
                                  .read(
                                      restauranteSeleccionadoProvider.notifier)
                                  .setRestauranteSeleccionado(data);
                              await _hacerCalculosReportesDiarios();
                            }
                          },
                          selectedItem: restauranteActual,
                        ),
                      ),
                      const Gap(15),
                      ElevatedButton.icon(
                        onPressed: _isUpdatingDatosDiarios
                            ? null
                            : () async {
                                if (restauranteActual.nombreRestaurante !=
                                    'No ha seleccionado...') {
                                  await _hacerCalculosReportesDiarios();
                                } else {
                                  Fluttertoast.cancel();
                                  Fluttertoast.showToast(
                                    msg: 'Debe seleccionar restaurante!!',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 5,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                    webPosition: 'center',
                                    webBgColor: 'red',
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                        icon: _isUpdatingDatosDiarios
                            ? SpinPerfect(
                                infinite: true,
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                        label: Text(
                          'Actualizar datos diarios',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //const Gap(5),
                //Containers con estadísticas senciilas del día
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      EstadisticaContainer(
                        estadistica: '${valoresReporte.cantMenu}',
                        descripcion: 'Productos en catálogo',
                        icono: Icons.restaurant_outlined,
                      ),
                      EstadisticaContainer(
                        estadistica: '${valoresReporte.cantPedidosDiarios}',
                        descripcion: 'Pedidos en este día',
                        icono: Icons.shopping_bag_outlined,
                      ),
                      EstadisticaContainer(
                        estadistica: '${valoresReporte.clientes}',
                        descripcion: '# de Clientes ingresados',
                        icono: Icons.group,
                      ),
                      EstadisticaContainer(
                        estadistica: 'L ${valoresReporte.ingresosDiarios}',
                        descripcion: 'Ingreso del día de hoy',
                        icono: Icons.money,
                      ),
                      EstadisticaContainer(
                        estadistica: '${valoresReporte.totalEfectivo}',
                        descripcion: 'Ingreso en efectivo (hoy)',
                        icono: Icons.money,
                        includesRibbon: true,
                        cantidad: '${valoresReporte.cantEfectivo}',
                      ),
                      EstadisticaContainer(
                        estadistica: '${valoresReporte.totalTarjeta}',
                        descripcion: 'Ingreso por tarjeta (hoy)',
                        icono: Icons.credit_card,
                        includesRibbon: true,
                        cantidad: '${valoresReporte.cantTarjeta}',
                      ),
                      EstadisticaContainer(
                        estadistica: '${valoresReporte.totalTransferencia}',
                        descripcion: 'Ingreso por transferencias',
                        icono: Icons.system_security_update_good_outlined,
                        includesRibbon: true,
                        cantidad: '${valoresReporte.cantTransferencia}',
                      ),
                    ],
                  ),
                ),
                //Inputs de fechas y botón de Generar Reporte
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 480,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              width: 130,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFfce8e0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _fechaInicial != null
                                    ? _fechaInicial!.substring(0, 10)
                                    : 'Fecha inicial',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const Gap(5),
                            Container(
                              width: 130,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFfce8e0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _fechaFinal != null
                                    ? _fechaFinal!.substring(0, 10)
                                    : 'Fecha final',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const Gap(5),
                            SizedBox(
                              height: 38,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2024, 1, 1),
                                    lastDate: DateTime.now(),
                                  ).then((selectedRange) {
                                    if (selectedRange != null) {
                                      setState(() {
                                        _initialDate = selectedRange.start;
                                        _finalDate = selectedRange.end;
                                        _fechaInicial =
                                            selectedRange.start.toString();
                                        _fechaFinal =
                                            selectedRange.end.toString();
                                      });
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                label: const Text(
                                  'Elegir fechas',
                                  style: TextStyle(color: Colors.white),
                                ),
                                icon: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Botón de generar reporte
                      SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_fechaInicial != null &&
                                _fechaFinal != null &&
                                restauranteActual.nombreRestaurante !=
                                    'No ha seleccionado...') {
                              //Hacer los respectivos cálculos con el restaurante seleccionado
                              await _hacerCalculosGenerales();
                            } else {
                              Fluttertoast.cancel();
                              Fluttertoast.showToast(
                                msg:
                                    'Debe seleccionar restaurante y rango de fechas!!',
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 5,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                                webPosition: 'center',
                                webBgColor: 'red',
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kGeneralPrimaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Generar reporte',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                //ÁREA PARA GRÁFICOS Y OTRAS ESTADÍSTICAS DEL REPORTE FILTRADO
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      width: 450,
                      height: 400,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black12,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isShowingReport
                          ? _isRetrievingGraphData
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : LineChart(
                                  LineChartData(
                                    lineTouchData: LineTouchData(
                                      handleBuiltInTouches: true,
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipColor: (touchedSpot) =>
                                            Colors.white,
                                      ),
                                    ),
                                    gridData: const FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        axisNameWidget: const Text(
                                          'Ingresos totales diarios',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 32,
                                            interval: 1,
                                            getTitlesWidget:
                                                bottomTitleWidgets),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          getTitlesWidget: leftTitleWidgets,
                                          showTitles: true,
                                          interval: 1,
                                          reservedSize: 60,
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: const Border(
                                        bottom: BorderSide(
                                            color: Colors.black12, width: 1),
                                        left: BorderSide(
                                            color: Colors.transparent),
                                        right: BorderSide(
                                            color: Colors.transparent),
                                        top: BorderSide(
                                            color: Colors.transparent),
                                      ),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        color: AppColors.kGeneralPrimaryOrange,
                                        barWidth: 1,
                                        isStrokeCapRound: true,
                                        dotData: const FlDotData(show: true),
                                        belowBarData: BarAreaData(
                                            show: true,
                                            color: AppColors.kGeneralOrangeBg
                                                .withOpacity(0.3)),
                                        spots: datosGrafico.puntos,
                                      ),
                                    ],
                                    minX: 0,
                                    minY: 0,
                                    maxX: datosGrafico.maxX,
                                    maxY: datosGrafico.maxY,
                                  ),
                                  duration: const Duration(milliseconds: 250),
                                )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.black87,
                                    size: 30,
                                  ),
                                  const Gap(10),
                                  Text(
                                    'Haga click en Generar reporte\npara mostrar datos!!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ),
                    const Gap(5),
                    Container(
                      width: 650,
                      height: 400,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.5,
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isShowingReport
                          ? _isRetrievingGraphData
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : SingleChildScrollView(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: FittedBox(
                                          child: DataTable(
                                            dataRowMaxHeight: double.infinity,
                                            columns: const <DataColumn>[
                                              DataColumn(
                                                label: Expanded(
                                                  child: Text(
                                                    '# orden',
                                                    style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Expanded(
                                                  child: Text(
                                                    'Detalle pedido',
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Expanded(
                                                  child: Text(
                                                    'Total (L)',
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Expanded(
                                                  child: Text(
                                                    'Fecha',
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Expanded(
                                                  child: Text(
                                                    'Método de pago',
                                                  ),
                                                ),
                                              ),
                                            ],
                                            rows: rowsTable,
                                            headingTextStyle: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.black87,
                                    size: 30,
                                  ),
                                  const Gap(10),
                                  Text(
                                    'Haga click en Generar reporte\npara mostrar datos!!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _hacerCalculosReportesDiarios() async {
    setState(() => _isUpdatingDatosDiarios = true);
    int idRes = ref.read(restauranteSeleccionadoProvider).idRestaurante!;
    await ref
        .read(valoresReportesProvider.notifier)
        .hacerCalculosReporte(idRes);
    setState(() => _isUpdatingDatosDiarios = false);
  }

  Future<void> _hacerCalculosGenerales() async {
    setState(() {
      _isShowingReport = true;
      _isRetrievingGraphData = true;
    });
    RestauranteModelo restauranteActual =
        ref.watch(restauranteSeleccionadoProvider);

    //Obtener los datos de supabase
    List<DateTime> fechasSeleccionadas =
        obtenerFechasEntre(_initialDate!, _finalDate!);

    List<double> valoresY = await ref
        .read(supabaseManagementProvider.notifier)
        .obtenerIngresosTotalesEntreFechas(
            _initialDate!, _finalDate!, restauranteActual.idRestaurante!);

    ref
        .read(datosGraficoIngresosProvider.notifier)
        .setValoresDatosGrafico(xDates: fechasSeleccionadas, yValues: valoresY);
    setState(() => _isRetrievingGraphData = false);
  }

  //Funciones para el gráfico principal --------------------------------------
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    //Provider de datos del gráfico ingresos
    DatosGraficoModelo datosGrafico = ref.read(datosGraficoIngresosProvider);
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    int entero = value.toInt();

    //Caso para el primer label
    if (entero < datosGrafico.xLabels.length) {
      text = Text(datosGrafico.xLabels[entero], style: style);
    } else {
      text = const Text('', style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    //Provider con los datos del gráfico
    DatosGraficoModelo datosGrafico = ref.read(datosGraficoIngresosProvider);
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    String text = '';
    //Valor inicial
    if (value.toInt() == 0) {
      text = '0';
    }
    //Valor 1/4
    if (value.toInt() == (datosGrafico.maxY / 4).toInt()) {
      text = '${(datosGrafico.maxY * 0.25).toInt()}';
    }
    //Valor 1/2
    if (value.toInt() == (datosGrafico.maxY / 2).toInt()) {
      text = '${(datosGrafico.maxY / 2).toInt()}';
    }
    //Valor 3/4
    if (value.toInt() == (datosGrafico.maxY * .75).toInt()) {
      text = '${(datosGrafico.maxY * .75).toInt()}';
    }
    //Valor máximo
    if (value.toInt() == datosGrafico.maxY.toInt()) {
      text = '${datosGrafico.maxY.toInt()}';
    }

    if (text.isEmpty) {
      return Container();
    }

    text = value.toInt().toString();
    return Text(text, style: style, textAlign: TextAlign.center);
  }

//Funciones para el gráfico principal --------------------------------------

//--------------------------Función para crear un pdf
  Future<void> exportDataTableToPDF(
      List<DataRow> rows, List<DataColumn> columns) async {
    final pdf = pw.Document();

    final tableHeaders = columns.map((col) => col.label.toString()).toList();
    final tableData = rows.map((row) {
      return row.cells.map((cell) => cell.child.toString()).toList();
    }).toList();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.TableHelper.fromTextArray(
            headers: tableHeaders,
            data: tableData,
          );
        },
      ),
    );

    // Guardar el archivo PDF en el directorio temporal
    final output = await getTemporaryDirectory();

    final file = File("${output.path}/tabla${DateTime.now()}.pdf");
    await file.writeAsBytes(await pdf.save());

    // Compartir el archivo PDF usando XFile
    final xFile = XFile(file.path);
    await Share.shareXFiles([xFile], text: 'Aquí está tu tabla en PDF');
  }
//--------------------------Función para crear un pdf
}
