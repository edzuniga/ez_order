import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/data/reporte_modelo.dart';
import 'package:ez_order_ezr/data/caja_apertura_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/duenos_restaurantes/reportes_valores_provider.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class CerrarCajaModal extends ConsumerStatefulWidget {
  const CerrarCajaModal({required this.cajaApertura, super.key});
  final CajaAperturaModelo cajaApertura;

  @override
  ConsumerState<CerrarCajaModal> createState() => _CerrarCajaModalState();
}

class _CerrarCajaModalState extends ConsumerState<CerrarCajaModal> {
  bool _isSendingData = false;
  double gastosTotales = 0.0;
  double cierreCajavalor = 0.0;
  double cierreTotalCaja = 0.0;

  @override
  void initState() {
    super.initState();
    hacerCalculosDeCierre();
  }

  Future<void> hacerCalculosDeCierre() async {
    setState(() => _isSendingData = true);
    int userIdRestaurante = int.parse(
        ref.read(userPublicDataProvider)['id_restaurante'].toString());

    //Obtener el último caja aperturaModelo
    List<CajaAperturaModelo> listCajaAperturas = await ref
        .read(supabaseManagementProvider.notifier)
        .getCajaAperturasPorRestaurante(userIdRestaurante);
    CajaAperturaModelo ultimaCajaApertura = listCajaAperturas.first;

    DateTime ultimaFecha = ultimaCajaApertura.createdAt;

    await ref.read(valoresReportesProvider.notifier).hacerCalculosReporte(
        userIdRestaurante,
        fechaCierreAnterior: ultimaFecha);

    ReporteModelo valoresProvi = ref.read(valoresReportesProvider);

    final gastosDelDia = await ref
        .read(supabaseManagementProvider.notifier)
        .getGastosCajaPorRestaurante(userIdRestaurante,
            fechaCierreAnterior: ultimaFecha);

    //Calcular el valor que debe estar en caja
    cierreCajavalor = await ref
        .read(supabaseManagementProvider.notifier)
        .calcularTotalCierreCaja(widget.cajaApertura.restauranteUid);

    for (var element in gastosDelDia) {
      if (element.egreso != null) {
        gastosTotales += element.egreso!;
      }
    }

    //CIERRE DE CAJA (DE ACUERDO AL CLIENTE)
    cierreTotalCaja = valoresProvi.totalEfectivo +
        valoresProvi.totalTarjeta +
        valoresProvi.totalTransferencia -
        gastosTotales;

    setState(() => _isSendingData = false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valoresReporte = ref.watch(valoresReportesProvider);
    return Container(
      width: 350,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(
          width: 5,
          color: const Color(0xFFDFE3E7),
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: !_isSendingData
            ? Column(
                children: [
                  //Título
                  const Text(
                    '¿Está seguro de cerrar la caja?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(15),
                  Text('Aperturó caja: L ${widget.cajaApertura.cantidad}'),
                  Text('Efectivo que debe haber en caja: L $cierreCajavalor'),
                  Text('Ventas en efectivo: L ${valoresReporte.totalEfectivo}'),
                  Text('Ventas en POS: L ${valoresReporte.totalTarjeta}'),
                  Text(
                      'Ventas por transferencia: L ${valoresReporte.totalTransferencia}'),
                  Text('Total de VENTAS: L ${valoresReporte.ingresosDiarios}'),
                  Text('Total de gastos: L $gastosTotales'),
                  Text(
                      'Cierre de caja (total de ventas - gastos): L $cierreTotalCaja'),
                  const Gap(25),

                  //Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Gap(8),
                      ElevatedButton(
                        onPressed: _isSendingData
                            ? () {}
                            : () async {
                                setState(() => _isSendingData = true);

                                //Actualizar el valor de caja
                                CajaAperturaModelo modelo =
                                    widget.cajaApertura.copyWith(
                                  cantidadCierre: cierreCajavalor,
                                  totalEfectivo: valoresReporte.totalEfectivo,
                                  totalTarjeta: valoresReporte.totalTarjeta,
                                  totalTransferencia:
                                      valoresReporte.totalTransferencia,
                                  totalGastos: gastosTotales,
                                  cierreCaja: cierreTotalCaja,
                                );
                                await ref
                                    .read(supabaseManagementProvider.notifier)
                                    .actualizarCajaApertura(modelo);
                                //Cambiar el estado de la CAJA (abierta/cerrada)
                                ref
                                    .read(supabaseManagementProvider.notifier)
                                    .statusCaja(
                                        widget.cajaApertura.restauranteUid,
                                        false);
                                //refrescar el estado local del status de la caja
                                /*ref
                                    .read(cajaAbiertaProvider.notifier)
                                    .refresh(); */
                                setState(() => _isSendingData = false);
                                if (!context.mounted) return;
                                Navigator.of(context).pop(true);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kGeneralPrimaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSendingData
                            ? SpinPerfect(
                                infinite: true,
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Cerrar',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const Gap(15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
