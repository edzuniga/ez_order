import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:ez_order_ezr/presentation/dashboard/facturacion_views/datos_actuales_view.dart';
import 'package:ez_order_ezr/presentation/dashboard/facturacion_views/facturas_historicas_view.dart';
import 'package:ez_order_ezr/presentation/dashboard/facturacion_views/facturas_hoy_view.dart';
import 'package:ez_order_ezr/presentation/dashboard/facturacion_views/mensaje_estatus_view.dart';

class FacturacionView extends ConsumerStatefulWidget {
  const FacturacionView({super.key});

  @override
  ConsumerState<FacturacionView> createState() => _AdminViewState();
}

class _AdminViewState extends ConsumerState<FacturacionView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //LISTADO DE FACTURAS Y OPCIONES DE FILTRO PARA HISTÓRICO DE FACTURAS
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 15,
            ),
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: const DefaultTabController(
              initialIndex: 0,
              length: 2,
              child: Column(
                children: [
                  SizedBox(
                    height: 60,
                    child: TabBar(
                      tabs: [
                        Tab(
                          icon: Icon(Icons.receipt_long_rounded),
                          text: 'Facturas de hoy',
                        ),
                        Tab(
                          icon: Icon(Icons.history_rounded),
                          text: 'Histórico',
                        ),
                      ],
                    ),
                  ),
                  Gap(10),
                  Expanded(
                    child: TabBarView(
                      children: [
                        //FACTURAS DE HOY
                        FacturasDeHoyView(),
                        //FACTURAS HISTÓRICAS
                        FacturasHistoricasView(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Gap(10),
        //DATOS DE FACTURACIÓN Y MENSAJE DE ESTATUS
        const Expanded(
          flex: 1,
          child: SizedBox(
            height: double.infinity,
            child: Column(
              children: [
                //Datos de factura actual
                DatosActualesFacturaView(),
                Gap(10),
                //Mensaje del status de los datos de factura
                MensajeStatusView(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
