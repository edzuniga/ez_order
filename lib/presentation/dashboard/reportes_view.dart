import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final restauranteActual = ref.watch(restauranteSeleccionadoProvider);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            //Selector de restaurantes del DUEÑO
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
                itemAsString: (RestauranteModelo r) => r.restauranteAsString(),
                onChanged: (RestauranteModelo? data) {
                  if (data != null) {
                    //Asignar el restaurante selecto al provider
                    ref
                        .read(restauranteSeleccionadoProvider.notifier)
                        .setRestauranteSeleccionado(data);
                  }
                },
                selectedItem: restauranteActual,
              ),
            ),
            const Gap(15),
            //Containers con estadísticas senciilas del día
            const Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                EstadisticaContainer(
                  estadistica: '1000',
                  descripcion: 'Productos en catálogo',
                  icono: Icons.restaurant_outlined,
                ),
                EstadisticaContainer(
                  estadistica: '1000',
                  descripcion: 'Pedidos en este día',
                  icono: Icons.shopping_bag_outlined,
                ),
                EstadisticaContainer(
                  estadistica: 'L 10,000',
                  descripcion: 'Ingreso del día de hoy',
                  icono: Icons.money,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
