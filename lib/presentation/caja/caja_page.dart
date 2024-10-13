import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:ez_order_ezr/data/caja_apertura_modelo.dart';
import 'package:ez_order_ezr/data/restaurante_modelo.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/aperturar_caja_modal.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/cerrar_caja_modal.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/update_caja_modal.dart';
import 'package:ez_order_ezr/presentation/providers/duenos_restaurantes/restaurante_caja_provider.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';

class CajaPage extends ConsumerStatefulWidget {
  const CajaPage({super.key});

  @override
  ConsumerState<CajaPage> createState() => _CajaPageState();
}

class _CajaPageState extends ConsumerState<CajaPage> {
  List<CajaAperturaModelo> _aperturas = [];
  late int userIdRestaurante;

  @override
  void initState() {
    super.initState();

    setState(() {
      userIdRestaurante = int.parse(
          ref.read(userPublicDataProvider)['id_restaurante'].toString());
    });
    WidgetsBinding.instance.addPostFrameCallback((v) {
      setRestauranteActual();
    });
  }

  Future<void> setRestauranteActual() async {
    RestauranteModelo rest = await ref
        .read(supabaseManagementProvider.notifier)
        .obtenerRestaurantePorId(userIdRestaurante);
    ref
        .read(cajaRestauranteSeleccionadoProvider.notifier)
        .setRestauranteSeleccionado(rest);

    _aperturas = await _obtenerAperturasCaja();
    setState(() {});
  }

  Future<List<CajaAperturaModelo>> _obtenerAperturasCaja() async {
    final datosPublicos = ref.watch(userPublicDataProvider);
    return await ref
        .read(supabaseManagementProvider.notifier)
        .getCajaAperturasPorRestaurante(
            int.parse(datosPublicos['id_restaurante']!));
  }

  @override
  Widget build(BuildContext context) {
    RestauranteModelo cajaRestauranteActual =
        ref.watch(cajaRestauranteSeleccionadoProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: AppColors.kGeneralPrimaryOrange,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: const Text(
          'Administración de Caja',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Gap(20),
                  FutureBuilder(
                    future: ref
                        .read(supabaseManagementProvider.notifier)
                        .getCajaAbierta(userIdRestaurante),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.yellow,
                              ),
                              Text('Ocurrió un error'),
                            ],
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      bool estaAbierta = snapshot.data!.abierto;
                      return estaAbierta
                          ? ElevatedButton(
                              onPressed: () async {
                                if (kIsWeb) {
                                  await _cerrarCajaModal(
                                      cajaRestauranteActual.idRestaurante!);
                                } else {}
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Cerrar CAJA',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                if (kIsWeb) {
                                  await _aperturarCajaModal(
                                      cajaRestauranteActual.idRestaurante!);
                                } else {}
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Aperturar CAJA',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                    },
                  ),
                  const Gap(20),
                  Expanded(
                    child: Container(
                      width: 800,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.02),
                      ),
                      child: Column(
                        children: [
                          const Gap(15),
                          const Text(
                            'Histórico de aperturas',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: _aperturas.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                final apertura = _aperturas[index];
                                String formattedDate =
                                    DateFormat.yMMMMEEEEd('es_ES')
                                        .add_Hm()
                                        .format(apertura.createdAt);
                                String cierreCantidad =
                                    apertura.cantidadCierre != null
                                        ? apertura.cantidadCierre.toString()
                                        : 'N/A';
                                String totalEfectivo =
                                    apertura.totalEfectivo != null
                                        ? apertura.totalEfectivo.toString()
                                        : 'N/A';
                                String totalTarjeta =
                                    apertura.totalTarjeta != null
                                        ? apertura.totalTarjeta.toString()
                                        : 'N/A';
                                String totalTransferencia =
                                    apertura.totalTransferencia != null
                                        ? apertura.totalTransferencia.toString()
                                        : 'N/A';
                                double ingresosTotales = 0.0;
                                apertura.totalEfectivo != null
                                    ? ingresosTotales += apertura.totalEfectivo!
                                    : null;
                                apertura.totalTarjeta != null
                                    ? ingresosTotales += apertura.totalTarjeta!
                                    : null;
                                apertura.totalTransferencia != null
                                    ? ingresosTotales +=
                                        apertura.totalTransferencia!
                                    : null;
                                String totalGastos =
                                    apertura.totalGastos != null
                                        ? apertura.totalGastos.toString()
                                        : 'N/A';
                                String totalIngresosDelDia = '';
                                totalIngresosDelDia =
                                    ingresosTotales.toString();
                                String cierreCaja = apertura.cierreCaja != null
                                    ? apertura.cierreCaja.toString()
                                    : 'N/A';

                                return ListTile(
                                  leading: const Icon(
                                    Icons.check_box,
                                    color: Colors.green,
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Aperturó con saldo: L ${apertura.cantidad}'),
                                      Text(
                                          'Persona en caja: ${apertura.personaEnCaja}'),
                                      Text(
                                          'Efectivo que debe haber en caja: L $cierreCantidad'),
                                      Text(
                                          'Ventas en efectivo: L $totalEfectivo'),
                                      Text('Ventas en POS: L $totalTarjeta'),
                                      Text(
                                          'Ventas por transferencia: L $totalTransferencia'),
                                      Text(
                                          'Total de VENTAS: L $totalIngresosDelDia'),
                                      Text('Total de gastos: L $totalGastos'),
                                      Text(
                                          'Cierre de caja (total de ventas - gastos): L $cierreCaja'),
                                    ],
                                  ),
                                  subtitle: Text('Fecha: $formattedDate'),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      await _editarCajaModal(apertura.id!);
                                    },
                                    icon: const Icon(Icons.edit),
                                    color: Colors.blue,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(20),
                ],
              ),
            ),

            //Mensaje si está o no abierta la caja
            FutureBuilder(
              future: ref
                  .read(supabaseManagementProvider.notifier)
                  .getCajaAbierta(userIdRestaurante),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Positioned(
                    right: 10,
                    top: 10,
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.yellow,
                        ),
                        Text('Error al querer cargar el dato!!'),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Positioned(
                    right: 10,
                    top: 10,
                    child: CircularProgressIndicator(),
                  );
                }

                bool estaAbierta = snapshot.data!.abierto;
                return Positioned(
                  right: 10,
                  top: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      estaAbierta
                          ? const Icon(
                              Icons.check_box,
                              color: Colors.green,
                            )
                          : const Icon(
                              Icons.indeterminate_check_box,
                              color: Colors.red,
                            ),
                      Text(estaAbierta
                          ? 'Caja ABIERTA actualmente'
                          : 'Caja CERRADA actualmente'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _aperturarCajaModal(int restauranteId) async {
    bool? res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: AperturarCajaModal(
          restauranteId: restauranteId,
        ),
      ),
    );

    if (res != null && res == true) {
      _aperturas = await _obtenerAperturasCaja();
      setState(() {});
    }
  }

  Future<void> _editarCajaModal(int id) async {
    bool? res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: UpdateCajaModal(
          id: id,
        ),
      ),
    );

    if (res != null && res == true) {
      _aperturas = await _obtenerAperturasCaja();
      setState(() {});
    }
  }

  Future<void> _cerrarCajaModal(int restauranteId) async {
    //Obtener la última apertura de caja
    List<CajaAperturaModelo> cajaAperturaList = await ref
        .read(supabaseManagementProvider.notifier)
        .getCajaAperturasPorRestaurante(restauranteId);

    CajaAperturaModelo modelo = cajaAperturaList.first;

    if (!mounted) return;
    bool? res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: CerrarCajaModal(
          cajaApertura: modelo,
        ),
      ),
    );

    if (res != null && res == true) {
      _aperturas = await _obtenerAperturasCaja();
      setState(() {});
    }
  }
}
