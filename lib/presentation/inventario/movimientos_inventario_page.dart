import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/data/movimiento_inventario_modelo.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/datatables/movimientos_inventario_dts.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';

class MovimientosInventarioPage extends ConsumerStatefulWidget {
  const MovimientosInventarioPage({super.key});

  @override
  ConsumerState<MovimientosInventarioPage> createState() =>
      _MovimientosInventarioPageState();
}

class _MovimientosInventarioPageState
    extends ConsumerState<MovimientosInventarioPage> {
  final estiloTitulos =
      GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16);
  late final int idRes;

  @override
  void initState() {
    super.initState();
    setState(() {
      idRes = int.parse(
          ref.read(userPublicDataProvider)['id_restaurante'].toString());
    });
  }

  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: AppColors.kGeneralPrimaryOrange,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: const Text(
          'Movimientos de Inventario',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: screenSize.width * 0.8,
          child: FutureBuilder(
            future: ref
                .read(supabaseManagementProvider.notifier)
                .obtenerMovimientosInventarioPorIdRest(idRes),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text('Por favor espere'),
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
                      Icon(
                        Icons.warning,
                        color: Colors.yellow,
                      ),
                      Text('Ocurrió un error!!'),
                    ],
                  ),
                );
              }

              List<MovimientoInventarioModelo> movimientos = snapshot.data!;
              if (movimientos.isEmpty) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.amber[700],
                      ),
                      const Gap(5),
                      const Text('No hay movimientos aún!!'),
                      const Gap(5),
                    ],
                  ),
                );
              } else {
                return SingleChildScrollView(
                  child: PaginatedDataTable(
                    headingRowColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                      return AppColors.kGeneralPrimaryOrange.withOpacity(0.05);
                    }),
                    showFirstLastButtons: true,
                    header: const Text('Tabla de Movimientos'),
                    columns: [
                      DataColumn(
                        numeric: true,
                        label: Text('#', style: estiloTitulos),
                      ),
                      DataColumn(
                        label: Text('Fecha', style: estiloTitulos),
                      ),
                      DataColumn(
                        label: Text('Producto', style: estiloTitulos),
                      ),
                      DataColumn(
                        label: Text('Tipo', style: estiloTitulos),
                      ),
                      DataColumn(
                        label: Text('Cantidad', style: estiloTitulos),
                      ),
                      DataColumn(
                        label: Text('Descripción', style: estiloTitulos),
                      ),
                      DataColumn(
                        label: Text('Acciones', style: estiloTitulos),
                      ),
                    ],
                    source: MovimientosInventarioDts(
                        ref, movimientos, context, _updateState),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
