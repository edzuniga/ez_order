import 'package:ez_order_ezr/presentation/dashboard/modals/view_factura_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/data/factura_modelo.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:intl/intl.dart';

class FacturasDeHoyView extends ConsumerStatefulWidget {
  const FacturasDeHoyView({super.key});

  @override
  ConsumerState<FacturasDeHoyView> createState() => _FacturasDeHoyViewState();
}

class _FacturasDeHoyViewState extends ConsumerState<FacturasDeHoyView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final getListadoFacturas =
        ref.read(supabaseManagementProvider.notifier).getFacturasYDetalles();
    return FutureBuilder(
        future: getListadoFacturas,
        builder: (BuildContext context,
            AsyncSnapshot<List<FacturaModelo>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text('Cargando datos, por favor espere.'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Ocurrió un error al querer cargar los datos!!'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aún no hay facturas!!'),
            );
          } else {
            List<FacturaModelo> listadoFacturas = snapshot.data!;
            return ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: listadoFacturas.length,
              itemBuilder: (ctx, index) {
                FacturaModelo factura = listadoFacturas[index];
                //Format date
                String formattedDate =
                    DateFormat.yMMMEd('es').format(factura.fechaFactura);
                String formattedTime =
                    DateFormat('h:mm a').format(factura.fechaFactura);
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
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
                            color: AppColors.kGeneralPrimaryOrange,
                          ),
                          const Gap(10),
                          //Fecha y hora
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //Cliente y total
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cliente: ${factura.nombreCliente}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text('Total: L. ${factura.total}'),
                              ],
                            ),
                          ),
                          const Gap(15),
                          //VER
                          IconButton(
                            onPressed: () {
                              _viewFacturaModal();
                            },
                            tooltip: 'Ver',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.kGeneralOrangeBg,
                            ),
                            icon: const Icon(
                              Icons.remove_red_eye_outlined,
                              color: Colors.white,
                            ),
                          ),
                          //ENVIAR
                          IconButton(
                            onPressed: () {},
                            tooltip: 'Compartir',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.kGeneralPrimaryOrange,
                            ),
                            icon: const Icon(
                              Icons.share,
                              color: Colors.white,
                            ),
                          ),
                          //IMPRIMIR
                          IconButton(
                            onPressed: () {},
                            tooltip: 'Imprimir',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            icon: const Icon(
                              Icons.print,
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
            );
          }
        });
  }

  void _viewFacturaModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(0),
      builder: (_) => const Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: ViewFacturaModal(),
      ),
    );
  }
}
