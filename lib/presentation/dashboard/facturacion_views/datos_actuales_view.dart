import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/add_datos_facturacion_modal.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/update_datos_facturacion_modal.dart';
import 'package:ez_order_ezr/presentation/providers/facturacion/datos_factura_provider.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class DatosActualesFacturaView extends ConsumerStatefulWidget {
  const DatosActualesFacturaView({super.key});

  @override
  ConsumerState<DatosActualesFacturaView> createState() =>
      _DatosActualesFacturaViewState();
}

class _DatosActualesFacturaViewState
    extends ConsumerState<DatosActualesFacturaView> {
  bool _negocioTieneDatosFactura = false;

  @override
  void initState() {
    super.initState();
    _getDatosFacturaData();
  }

  Future<void> _getDatosFacturaData() async {
    await ref.read(supabaseManagementProvider.notifier).getDatosFactura();
  }

  @override
  Widget build(BuildContext context) {
    final datosFactura = ref.watch(datosFacturaManagerProvider);
    String rangoInicialString = '';
    String rangoFinalString = '';

    //Revisión si el negocio tiene datos de factura ingresados
    if (datosFactura.idDatosFactura != 0) {
      setState(() => _negocioTieneDatosFactura = true);
      //Crear los strings para los rangos (inicial y final)
      int cantidadDeDigitosRangoInicial =
          datosFactura.rangoInicial.toString().length;
      int cantidadDeDigitosRangoFinal =
          datosFactura.rangoFinal.toString().length;
      for (int i = 1; i <= 8 - cantidadDeDigitosRangoInicial; i++) {
        rangoInicialString += '0';
      }
      for (int i = 1; i <= 8 - cantidadDeDigitosRangoFinal; i++) {
        rangoFinalString += '0';
      }
      rangoInicialString += datosFactura.rangoInicial.toString();
      rangoFinalString += datosFactura.rangoFinal.toString();
    } else {
      setState(() => _negocioTieneDatosFactura = false);
    }

    //Trimear la fecha
    String fechaLimiteTrimeada = datosFactura.fechaLimite != null
        ? datosFactura.fechaLimite.toString().substring(0, 10)
        : '';

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 25,
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    _negocioTieneDatosFactura
                        ? _actualizarDatosFacturaModal()
                        : _addDatosFacturaModal();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _negocioTieneDatosFactura
                        ? 'Actualizar datos'
                        : 'Agregar datos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const Gap(10),
              Text(
                'Datos de facturación actuales',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const Gap(15),
              //Nombre del negocio
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 10,
                children: [
                  const Text(
                    'Nombre del negocio:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    child: Text(!_negocioTieneDatosFactura
                        ? 'NO HA INGRESADO'
                        : datosFactura.nombreNegocio),
                  ),
                ],
              ),
              const Gap(10),
              //RTN
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.start,
                children: [
                  const Text(
                    'RTN:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    child: Text(!_negocioTieneDatosFactura
                        ? 'NO HA INGRESADO'
                        : datosFactura.rtn),
                  ),
                ],
              ),
              const Gap(10),
              //Dirección
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.start,
                children: [
                  const Text(
                    'Dirección:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    child: Text(!_negocioTieneDatosFactura
                        ? 'NO HA INGRESADO'
                        : datosFactura.direccion),
                  ),
                ],
              ),
              const Gap(10),
              //Correo
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.start,
                children: [
                  const Text(
                    'Correo:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    child: Text(!_negocioTieneDatosFactura
                        ? 'NO HA INGRESADO'
                        : datosFactura.correo),
                  ),
                ],
              ),
              const Gap(10),
              //Teléfono
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.start,
                children: [
                  const Text(
                    'Teléfono:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    child: Text(!_negocioTieneDatosFactura
                        ? 'NO HA INGRESADO'
                        : datosFactura.telefono),
                  ),
                ],
              ),
              const Gap(10),
              const Divider(
                color: AppColors.kGeneralFadedGray,
              ),
              const Gap(10),
              //CAI
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.start,
                children: [
                  const Text(
                    'CAI:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    child: Text(!_negocioTieneDatosFactura
                        ? 'NO HA INGRESADO'
                        : datosFactura.cai),
                  ),
                ],
              ),
              const Gap(10),
              //Rango inicial
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.start,
                children: [
                  const Text(
                    'Rango Inicial:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    child: Text(!_negocioTieneDatosFactura
                        ? 'NO HA INGRESADO'
                        : rangoInicialString),
                  ),
                ],
              ),
              const Gap(10),
              //Rango final
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.start,
                children: [
                  const Text(
                    'Rango final:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    child: Text(!_negocioTieneDatosFactura
                        ? 'NO HA INGRESADO'
                        : rangoFinalString),
                  ),
                ],
              ),
              const Gap(10),
              //Fecha límite de emisión
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.start,
                children: [
                  const Text(
                    'Fecha límite de emisión:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    child: Text(!_negocioTieneDatosFactura
                        ? 'NO HA INGRESADO'
                        : fechaLimiteTrimeada),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _actualizarDatosFacturaModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: UpdateDatosFacturacionModal(),
      ),
    );
  }

  void _addDatosFacturaModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: AddDatosFacturacionModal(),
      ),
    );
  }
}
