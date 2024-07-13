import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/borrar_pedido_modal.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';

class EnPreparacionPage extends ConsumerStatefulWidget {
  const EnPreparacionPage({super.key});

  @override
  ConsumerState<EnPreparacionPage> createState() => _EnPreparacionPageState();
}

class _EnPreparacionPageState extends ConsumerState<EnPreparacionPage> {
  late SupabaseClient _supabase;
  late Stream<List<Map<String, dynamic>>> _stream;
  late Stream<List<Map<String, dynamic>>> _pedidosStreamPorEntregar;

  @override
  void initState() {
    super.initState();
    if (ref.read(userPublicDataProvider)['id_restaurante'] != null) {
      int userIdRestaurante = int.parse(
          ref.read(userPublicDataProvider)['id_restaurante'].toString());
      _supabase = ref.read(supabaseManagementProvider);
      //Stream general filtrado por el id del restaurante
      _stream = _supabase
          .from('pedidos')
          .stream(primaryKey: ['uuid_pedido'])
          .eq('id_restaurante', userIdRestaurante)
          .order('created_at', ascending: false);
    } else {
      _stream = const Stream.empty();
    }

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    //Filtración interna del stream general, condicionado por fecha (solo fecha de hoy)
    _pedidosStreamPorEntregar = _stream.map((data) {
      return data.where((pedido) {
        final createdAt = DateTime.parse(pedido['created_at']);
        return createdAt.isAfter(startOfDay) &&
            createdAt.isBefore(endOfDay) &&
            pedido['en_preparacion'] == true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.kGeneralPrimaryOrange,
          title: const Text(
            'En Preparación',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder(
          stream: _pedidosStreamPorEntregar,
          builder: (BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text('Cargando datos, por favor espere.'),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Ocurrió un error al querer cargar los datos!!'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Aún no hay pedidos!!'),
              );
            } else {
              List<Map<String, dynamic>> listadoMap = snapshot.data!;
              List<PedidoModel> listadoPedidos = [];
              for (var element in listadoMap) {
                listadoPedidos.add(PedidoModel.fromJson(element));
              }
              return ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: listadoPedidos.length,
                itemBuilder: (ctx, index) {
                  PedidoModel pedido = listadoPedidos[index];
                  return FutureBuilder(
                    future: _obtenerNombreCliente(pedido.idCliente),
                    builder: (BuildContext ctx, AsyncSnapshot<String> s) {
                      if (s.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (s.hasError) {
                        return const Center(
                          child: Text('Ocurrió un error!!'),
                        );
                      }

                      if (!s.hasData) {
                        return const Center(
                          child: Text('Sin datos!!'),
                        );
                      } else {
                        String nombreCliente = s.data!;
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              //height: 91.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: const Color(0xFFE0E3E7),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  //Imagen del pedido
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 100.0,
                                      height: 81.0,
                                      child: Image.asset(
                                        'assets/images/pedidos.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const Gap(5),
                                  //Información del pedido
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '# ${pedido.numPedido}',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Total: L ${pedido.total}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Gap(10),
                                        RichText(
                                          text: TextSpan(
                                            text: 'Orden: ',
                                            style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 8.0,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: pedido.orden,
                                                style: GoogleFonts.inter(
                                                  color: Colors.grey,
                                                  fontSize: 8.0,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '\nCliente: ',
                                                style: GoogleFonts.inter(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 8.0,
                                                ),
                                              ),
                                              TextSpan(
                                                text: nombreCliente,
                                                style: GoogleFonts.inter(
                                                  color: Colors.grey,
                                                  fontSize: 8.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.circle,
                                                size: 10,
                                                color: (pedido.enPreparacion)
                                                    ? AppColors
                                                        .kGeneralPrimaryOrange
                                                    : Colors.green),
                                            const Gap(8),
                                            const Text(
                                              'En preparación',
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  //Botón para las acciones del pedido
                                  Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          await _tryChangePedidoStatus(
                                              pedido.uuidPedido!);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          elevation: 0.0,
                                          backgroundColor:
                                              AppColors.kGeneralPrimaryOrange,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                        ),
                                        child: Text(
                                          'Entregar',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const Gap(10),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await _tryBorrarPedido(
                                              pedido.uuidPedido!);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          elevation: 0.0,
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                        ),
                                        child: Text(
                                          'Cancelar',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Gap(8),
                          ],
                        );
                      }
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<String> _obtenerNombreCliente(int clienteId) async {
    return await ref
        .read(supabaseManagementProvider.notifier)
        .getClienteName(clienteId);
  }

  Future<void> _tryBorrarPedido(String uuIdPedido) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: BorrarPedidoModal(uuIdPedido: uuIdPedido),
      ),
    );
  }

  Future<void> _tryChangePedidoStatus(String uuIdPedido) async {
    await ref
        .read(supabaseManagementProvider.notifier)
        .changePedidoStatus(uuIdPedido)
        .then((message) {
      if (message != 'success') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Ocurrió un error al intentar entregar la orden -> $message',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ));
      } else {
        if (kIsWeb) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Pedido entregado exitosamente!!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ));
        } else {
          Fluttertoast.cancel();
          Fluttertoast.showToast(
            msg: 'Pedido entregado exitosamente!!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
            webPosition: 'center',
            webBgColor: 'green',
          );
        }
      }
    });
  }
}
