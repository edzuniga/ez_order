import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:ez_order_ezr/data/caja_apertura_modelo.dart';
import 'package:ez_order_ezr/data/restaurante_modelo.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/aperturar_caja_modal.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/cerrar_caja_modal.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/update_caja_modal.dart';
import 'package:ez_order_ezr/presentation/providers/caja/caja_abierta.dart';
import 'package:ez_order_ezr/presentation/providers/duenos_restaurantes/duenos_restaurantes_provider.dart';
import 'package:ez_order_ezr/presentation/providers/duenos_restaurantes/restaurante_caja_provider.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';

class CajaPage extends ConsumerStatefulWidget {
  const CajaPage({super.key});

  @override
  ConsumerState<CajaPage> createState() => _CajaPageState();
}

class _CajaPageState extends ConsumerState<CajaPage> {
  List<CajaAperturaModelo> _aperturas = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((v) {
      ref
          .read(cajaRestauranteSeleccionadoProvider.notifier)
          .resetRestauranteSeleccionado();
    });
  }

  Future<List<RestauranteModelo>> _obtenerRestaurantes() async {
    return await ref
        .read(duenosResManagerProvider.notifier)
        .obtenerRestaurantesPorDueno();
  }

  Future<List<CajaAperturaModelo>> _obtenerAperturasCaja() async {
    final restauranteSeleccionado =
        ref.read(cajaRestauranteSeleccionadoProvider);
    if (restauranteSeleccionado.nombreRestaurante != 'No ha seleccionado...') {
      return await ref
          .read(supabaseManagementProvider.notifier)
          .getCajaAperturasPorRestaurante(
              restauranteSeleccionado.idRestaurante!);
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    RestauranteModelo cajaRestauranteActual =
        ref.watch(cajaRestauranteSeleccionadoProvider);
    final cajaAbierta = ref.watch(cajaAbiertaProvider);
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
                  const Text('Seleccione restaurante'),
                  //Selector de restaurante
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
                                  cajaRestauranteSeleccionadoProvider.notifier)
                              .setRestauranteSeleccionado(data);

                          _aperturas = await _obtenerAperturasCaja();
                          ref.read(cajaAbiertaProvider.notifier).refresh();
                          setState(() {});
                        }
                      },
                      selectedItem: cajaRestauranteActual,
                    ),
                  ),
                  const Gap(20),
                  cajaRestauranteActual.nombreRestaurante !=
                          'No ha seleccionado...'
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            cajaAbierta.when(
                              data: (data) => data
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        if (kIsWeb) {
                                          await _cerrarCajaModal(
                                              cajaRestauranteActual
                                                  .idRestaurante!);
                                        } else {}
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                              cajaRestauranteActual
                                                  .idRestaurante!);
                                        } else {}
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Aperturar CAJA',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                              error: (error, stacktrace) => const Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Colors.yellow,
                                  ),
                                  Text('Ocurrió un error'),
                                ],
                              ),
                              loading: () => const CircularProgressIndicator(),
                            ),
                            const Gap(20),
                          ],
                        )
                      : const SizedBox(),
                  const Gap(20),
                  Expanded(
                    child: Container(
                      width: 400,
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
                                          'Cerró con saldo: L $cierreCantidad'),
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
                ],
              ),
            ),
            cajaRestauranteActual.nombreRestaurante != 'No ha seleccionado...'
                ? cajaAbierta.when(
                    data: (data) => Positioned(
                      right: 10,
                      top: 10,
                      child: Row(
                        children: [
                          data
                              ? const Icon(
                                  Icons.check_box,
                                  color: Colors.green,
                                )
                              : const Icon(
                                  Icons.indeterminate_check_box,
                                  color: Colors.red,
                                ),
                          Text(data
                              ? 'Caja ABIERTA actualmente'
                              : 'Caja CERRADA actualmente'),
                        ],
                      ),
                    ),
                    error: (error, stacktrace) => const Positioned(
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
                    ),
                    loading: () => const Positioned(
                      right: 10,
                      top: 10,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox(),
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
      await ref.read(cajaAbiertaProvider.notifier).refresh();
      Future.delayed(const Duration(milliseconds: 300))
          .whenComplete(() => setState(() {}));
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
      await ref.read(cajaAbiertaProvider.notifier).refresh();
      Future.delayed(const Duration(milliseconds: 300))
          .whenComplete(() => setState(() {}));
    }
  }
}
