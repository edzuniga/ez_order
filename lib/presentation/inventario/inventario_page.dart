import 'package:ez_order_ezr/domain/inventario.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/datatables/inventario_dts.dart';
import 'package:ez_order_ezr/presentation/modales/inventario_modal.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:ez_order_ezr/presentation/widgets/modal_purpose_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class InventarioPage extends ConsumerStatefulWidget {
  const InventarioPage({super.key});

  @override
  ConsumerState<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends ConsumerState<InventarioPage> {
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
                .obtenerInventarioPorRestaurante(idRes),
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
                String mensaje = snapshot.error.toString();
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning,
                        color: Colors.yellow,
                      ),
                      const Text('Ocurrió un error!!'),
                      Text(mensaje),
                    ],
                  ),
                );
              }

              List<Inventario> productos = snapshot.data!;
              if (productos.isEmpty) {
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
                      const Text('No hay productos aún!!'),
                      const Gap(5),
                      ElevatedButton(
                        onPressed: () async {
                          await _addInventarioModal();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kGeneralPrimaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Agregar producto',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
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
                    header: const Text('Control de inventario'),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          await _addInventarioModal();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                        child: const Text(
                          'Agregar producto',
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
                        label: Text('Código', style: estiloTitulos),
                      ),
                      DataColumn(
                        label: Text('Nombre', style: estiloTitulos),
                      ),
                      DataColumn(
                        label: Text('Descripción', style: estiloTitulos),
                      ),
                      DataColumn(
                        label: Text('Precio de costo', style: estiloTitulos),
                      ),
                      DataColumn(
                        label: Text('Stock', style: estiloTitulos),
                      ),
                      DataColumn(
                        label: Text('Proveedor', style: estiloTitulos),
                      ),
                      DataColumn(
                        label: Text('Acciones', style: estiloTitulos),
                      ),
                    ],
                    source:
                        InventarioTableSource(productos, context, _updateState),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _addInventarioModal() async {
    bool res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: InventarioModal(
          titulo: 'Agregar',
          modalPurpose: ModalPurpose.add,
        ),
      ),
    );

    if (res) {
      setState(() {});
    }
  }
}
