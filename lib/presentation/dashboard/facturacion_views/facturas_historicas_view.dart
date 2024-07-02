import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:ez_order_ezr/data/factura_modelo.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/view_factura_modal.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';

class FacturasHistoricasView extends ConsumerStatefulWidget {
  const FacturasHistoricasView({super.key});

  @override
  ConsumerState<FacturasHistoricasView> createState() =>
      _FacturasHistoricasViewState();
}

class _FacturasHistoricasViewState
    extends ConsumerState<FacturasHistoricasView> {
  final GlobalKey<FormState> _facturasHistoricasFormKey =
      GlobalKey<FormState>();
  final TextEditingController _fecha = TextEditingController();
  DateTime? _fechaSelecta;
  bool _tieneCargadasFechasHistoricas = false;

  @override
  Widget build(BuildContext context) {
    final getListadoFacturasPorFecha = _tieneCargadasFechasHistoricas
        ? ref
            .read(supabaseManagementProvider.notifier)
            .getFacturasYDetallesPorFecha(_fechaSelecta!)
        : null;
    return SizedBox(
      width: double.infinity,
      child: Form(
        key: _facturasHistoricasFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 15,
              runSpacing: 10,
              children: [
                IconButton(
                  onPressed: () async {
                    DateTime hoy = DateTime.now();
                    DateTime ayer = DateTime(hoy.year, hoy.month, hoy.day - 1);

                    // Ajusta el cálculo de "ayer" para manejar correctamente los cambios de mes
                    if (hoy.day == 1) {
                      int previousMonth = hoy.month - 1;
                      if (previousMonth == 0) {
                        previousMonth = 12;
                        ayer = DateTime(hoy.year - 1, previousMonth,
                            DateTime(hoy.year - 1, previousMonth + 1, 0).day);
                      } else {
                        ayer = DateTime(hoy.year, previousMonth,
                            DateTime(hoy.year, previousMonth + 1, 0).day);
                      }
                    }

                    DateTime firstDate =
                        DateTime(ayer.year - 10, ayer.month, ayer.day);

                    await showDatePicker(
                      context: context,
                      firstDate: firstDate,
                      lastDate: ayer,
                    ).then((value) {
                      if (value != null) {
                        _fecha.text = value.toString().substring(0, 10);
                        _fechaSelecta = value;
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.kGeneralPrimaryOrange,
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: TextFormField(
                    enabled: false,
                    controller: _fecha,
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(
                      labelText: 'Seleccione fecha',
                      labelStyle: GoogleFonts.inter(
                        color: AppColors.kTextPrimaryBlack,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFe0e3e7),
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
                    style: GoogleFonts.inter(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obligatorio';
                      }

                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_facturasHistoricasFormKey.currentState!.validate()) {
                        setState(() => _tieneCargadasFechasHistoricas = true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kGeneralPrimaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Listar facturas',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            ),
            _tieneCargadasFechasHistoricas
                ? Expanded(
                    child: FutureBuilder(
                      future: getListadoFacturasPorFecha,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<FacturaModelo>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  Text('Cargando datos, por favor espere.'),
                                ],
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Expanded(
                            child: Center(
                              child: Text(
                                  'Ocurrió un error al querer cargar los datos!!'),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Expanded(
                            child: Center(
                              child: Text(
                                  'No se encontraron facturas en esta fecha!!'),
                            ),
                          );
                        } else {
                          List<FacturaModelo> listadoFacturas = snapshot.data!;
                          return RefreshIndicator(
                            onRefresh: () async {
                              await Future.delayed(const Duration(seconds: 2))
                                  .then((value) => setState(() {}));
                            },
                            child: ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              itemCount: listadoFacturas.length,
                              itemBuilder: (ctx, index) {
                                FacturaModelo factura = listadoFacturas[index];
                                //Format date
                                String formattedDate = DateFormat.yMMMEd('es')
                                    .format(factura.fechaFactura);
                                String formattedTime = DateFormat('h:mm a')
                                    .format(factura.fechaFactura);
                                return Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: const Color(0xFFE0E3E7),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          //Imagen genérica de pedido
                                          const Icon(
                                            Icons.receipt,
                                            color:
                                                AppColors.kGeneralPrimaryOrange,
                                          ),
                                          const Gap(10),
                                          //Fecha y hora
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Factura # ${factura.numFactura}',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: Text(
                                                    'Fecha y hora: $formattedDate | $formattedTime',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          //Cliente y total
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Cliente: ${factura.nombreCliente}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                    'Total: L. ${factura.total}'),
                                              ],
                                            ),
                                          ),
                                          const Gap(15),
                                          //VER
                                          IconButton(
                                            onPressed: () {
                                              _viewFacturaModal(factura);
                                            },
                                            tooltip: 'Ver',
                                            style: IconButton.styleFrom(
                                              backgroundColor: AppColors
                                                  .kGeneralPrimaryOrange,
                                            ),
                                            icon: const Icon(
                                              Icons.remove_red_eye_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Gap(8),
                                  ],
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  void _viewFacturaModal(FacturaModelo factura) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: ViewFacturaModal(
          factura: factura,
        ),
      ),
    );
  }
}
