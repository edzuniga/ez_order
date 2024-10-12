import 'package:ez_order_ezr/domain/menu_inventario.dart';
import 'package:ez_order_ezr/presentation/datatables/menu_inventario_dts.dart';
import 'package:ez_order_ezr/presentation/modales/menu_inventario_modal.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/widgets/modal_purpose_enum.dart';
import 'package:flutter/material.dart';

import 'package:ez_order_ezr/domain/menu_item.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class AsociarMenuInventarioPage extends ConsumerStatefulWidget {
  const AsociarMenuInventarioPage({
    required this.menuItem,
    super.key,
  });

  final MenuItem menuItem;

  @override
  ConsumerState<AsociarMenuInventarioPage> createState() =>
      _AsociarMenuInventarioPageState();
}

class _AsociarMenuInventarioPageState
    extends ConsumerState<AsociarMenuInventarioPage> {
  final estiloTitulos =
      GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16);

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
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: const Text(
          'Gestión del Inventario',
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
                .obtenerMenuInventarioPorItemMenu(
                    widget.menuItem.idRestaurante, widget.menuItem.idMenu!),
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
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.amber[700],
                      ),
                      const Text('Ocurrió un error!!'),
                    ],
                  ),
                );
              }

              List<MenuInventario> listado = snapshot.data!;
              if (listado.isEmpty) {
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
                      const Text('No hay asociaciones aún!!'),
                      const Gap(5),
                      ElevatedButton(
                        onPressed: () async {
                          await _addMenuInventarioModal();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kGeneralPrimaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Asociar inventario',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Column(
                  children: [
                    const Gap(20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFFFF1EC),
                      ),
                      child: Text(
                        'Asociaciones del inventario para el Ítem del Menú: ${widget.menuItem.nombreItem}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Gap(20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: PaginatedDataTable(
                            headingRowColor:
                                WidgetStateProperty.resolveWith<Color>(
                                    (Set<WidgetState> states) {
                              return AppColors.kGeneralPrimaryOrange
                                  .withOpacity(0.05);
                            }),
                            showFirstLastButtons: true,
                            header: const Text('Control de asociaciones'),
                            actions: [
                              ElevatedButton(
                                onPressed: () async {
                                  await _addMenuInventarioModal();
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    )),
                                child: const Text(
                                  'Asociar inventario',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                            columns: [
                              DataColumn(
                                numeric: true,
                                label: Text('#', style: estiloTitulos),
                              ),
                              DataColumn(
                                label: Text('Producto del inventario',
                                    style: estiloTitulos),
                              ),
                              DataColumn(
                                label: Text('Cantidad asociada',
                                    style: estiloTitulos),
                              ),
                              DataColumn(
                                label: Text('Acciones', style: estiloTitulos),
                              ),
                            ],
                            source: MenuInventarioDts(
                                listado: listado,
                                ref: ref,
                                context: context,
                                actualizarEstado: _updateState),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _addMenuInventarioModal() async {
    bool res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: MenuInventarioModal(
          titulo: 'Agregar',
          modalPurpose: ModalPurpose.add,
          idMenu: widget.menuItem.idMenu!,
          idRest: widget.menuItem.idRestaurante,
        ),
      ),
    );

    if (res) {
      setState(() {});
    }
  }
}
