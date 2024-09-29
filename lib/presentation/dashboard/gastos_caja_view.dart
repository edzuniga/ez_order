import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:ez_order_ezr/data/registro_caja_modelo.dart';
import 'package:ez_order_ezr/data/restaurante_modelo.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/borrar_gasto_caja_modal.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/update_gasto_caja_modal.dart';
import 'package:ez_order_ezr/presentation/providers/duenos_restaurantes/duenos_restaurantes_provider.dart';
import 'package:ez_order_ezr/presentation/providers/duenos_restaurantes/restaurante_gastos_caja.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/add_gasto_caja_modal.dart';

class GastosCajaView extends ConsumerStatefulWidget {
  const GastosCajaView({super.key});

  @override
  ConsumerState<GastosCajaView> createState() => _GastosCajaViewState();
}

class _GastosCajaViewState extends ConsumerState<GastosCajaView> {
  int userIdRestaurante = 0;
  List<RegistroCajaModelo> listadoRegistros = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      userIdRestaurante = int.parse(
          ref.read(userPublicDataProvider)['id_restaurante'].toString());
    });
  }

  Future<List<RestauranteModelo>> _obtenerRestaurantes() async {
    return await ref
        .read(duenosResManagerProvider.notifier)
        .obtenerRestaurantesPorDueno();
  }

  Future<List<RegistroCajaModelo>> obtenerRegistrosDeCaja() async {
    RestauranteModelo cajaRestauranteActual =
        ref.watch(restauranteSeleccionadoGastosCajaProvider);

    final datosPublicos = ref.watch(userPublicDataProvider);

    if (datosPublicos['rol'] == '1' || datosPublicos['rol'] == '2') {
      if (cajaRestauranteActual.nombreRestaurante != 'No ha seleccionado...') {
        return await ref
            .read(supabaseManagementProvider.notifier)
            .getGastosCajaPorRestaurante(
                int.parse(cajaRestauranteActual.idRestaurante.toString()));
      } else {
        return [];
      }
    } else {
      return await ref
          .read(supabaseManagementProvider.notifier)
          .getGastosCajaPorRestaurante(
              int.parse(datosPublicos['id_restaurante']!));
    }
  }

  @override
  Widget build(BuildContext context) {
    RestauranteModelo cajaRestauranteActual =
        ref.watch(restauranteSeleccionadoGastosCajaProvider);

    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: ref
                .read(supabaseManagementProvider.notifier)
                .cajaCerradaoAbierta(userIdRestaurante),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Por favor espere.'),
                      CircularProgressIndicator(),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('Ocurrió un error!!'),
                );
              }

              if (snapshot.data!) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        await _addGastoCajaModal();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kGeneralPrimaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Agregar gasto',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )),
                );
              } else {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red,
                    child: const Text(
                      'Caja está cerrada',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }
            },
          ),
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
                            .read(restauranteSeleccionadoGastosCajaProvider
                                .notifier)
                            .setRestauranteSeleccionado(data);
                      }
                    },
                    selectedItem: cajaRestauranteActual,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: obtenerRegistrosDeCaja(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Cargando datos!!'),
                        CircularProgressIndicator(
                          color: AppColors.kGeneralPrimaryOrange,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Ocurrió un error!!'),
                        CircularProgressIndicator(
                          color: AppColors.kGeneralPrimaryOrange,
                        ),
                      ],
                    ),
                  );
                }

                List<RegistroCajaModelo> listado = snapshot.data!;
                return ListView.separated(
                    itemBuilder: (context, index) {
                      RegistroCajaModelo registro = listado[index];
                      String formattedDate = DateFormat.yMMMMEEEEd('es_ES')
                          .add_Hm()
                          .format(registro.createdAt);
                      if (registro.egreso != null) {
                        return ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.red,
                          ),
                          title: Text(
                              'Cantidad: L ${registro.egreso}\nProveedor: ${registro.proveedor}'),
                          subtitle: Text(
                              'Fecha y Hora: $formattedDate\nDescripción: ${registro.descripcion}'),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    await _actualizarGastoCajaModal(registro);
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  tooltip: 'Editar',
                                ),
                                const Gap(5),
                                IconButton(
                                  onPressed: () async {
                                    await _borrarGastoCajaModal(registro.id!);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Borrar',
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        title: Text('Cantidad: L ${registro.ingreso}'),
                        subtitle: Text(
                            'Fecha y Hora: $formattedDate\nDescripción: ${registro.descripcion}'),
                      );
                    },
                    separatorBuilder: (_, index) => const Divider(),
                    itemCount: listado.length);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addGastoCajaModal() async {
    bool? res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: AddGastoModal(),
      ),
    );

    if (res != null) {
      setState(() {});
    }
  }

  Future<void> _actualizarGastoCajaModal(
      RegistroCajaModelo registroCaja) async {
    bool? res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: UpdateGastoCajaModal(registroCaja: registroCaja),
      ),
    );

    if (res != null) {
      setState(() {});
    }
  }

  Future<void> _borrarGastoCajaModal(int id) async {
    bool? res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: BorrarGastoCajaModal(
          idGastoCaja: id,
        ),
      ),
    );

    if (res != null) {
      setState(() {});
    }
  }
}
