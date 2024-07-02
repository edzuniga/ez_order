import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/data/pedido_detalle_model.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/widgets/cocina/app_bar_cocina.dart';

class CocinaPage extends ConsumerStatefulWidget {
  const CocinaPage({super.key});

  @override
  ConsumerState<CocinaPage> createState() => _CocinaPageState();
}

class _CocinaPageState extends ConsumerState<CocinaPage> {
  late SupabaseClient _supabase;
  late Stream<List<Map<String, dynamic>>> _stream;
  late Stream<List<Map<String, dynamic>>> _pedidosStream;

  @override
  void initState() {
    super.initState();
    int userIdRestaurante = int.parse(
        ref.read(userPublicDataProvider)['id_restaurante'].toString());
    _supabase = ref.read(supabaseManagementProvider);
    //Stream general filtrado por el id del restaurante
    _stream = _supabase
        .from('pedidos')
        .stream(primaryKey: ['uuid_pedido'])
        .eq('id_restaurante', userIdRestaurante)
        .order('created_at', ascending: true);

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    //Filtración interna del stream general, condicionado por fecha (solo fecha de hoy)
    _pedidosStream = _stream.map((data) {
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.kGeneralOrangeBg, AppColors.kGeneralFadedOrange],
          stops: [0.0, 1.0],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                //Custom Appbar para la cocina
                const CocinaAppBar(),
                const Gap(8),
                //listado de pedidos pendientes
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: StreamBuilder(
                      stream: _pedidosStream,
                      builder: (BuildContext ctx,
                          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                            child: Text(
                                'Ocurrió un error al querer cargar los datos!!'),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('Aún no hay pedidos!!'),
                          );
                        } else {
                          //Obtener listado de pedidos
                          List<PedidoModel> listadoPedidos = snapshot.data!
                              .map((pedido) => PedidoModel.fromJson(pedido))
                              .toList();
                          return ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            itemCount: listadoPedidos.length,
                            itemBuilder: (ctx, index) {
                              PedidoModel pedido = listadoPedidos[index];
                              return FutureBuilder(
                                future: Future.wait([
                                  _obtenerDetallePedidoConNombreMenu(
                                      pedido.uuidPedido!),
                                  _obtenerNombreCliente(pedido.idCliente)
                                ]),
                                builder: (_, AsyncSnapshot<dynamic> s) {
                                  if (s.connectionState ==
                                      ConnectionState.waiting) {
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
                                    List<Map<String, dynamic>>
                                        detallesConNombreMenu = s.data[0];
                                    String nombreCliente = s.data[1];
                                    String textoDetallePedido =
                                        detallesConNombreMenu.map((detalleMap) {
                                      PedidoDetalleModel detalle =
                                          detalleMap['detalle'];
                                      String nombreMenu =
                                          detalleMap['nombreMenu'];
                                      if (nombreMenu != '') {
                                        return '${detalle.cantidad} $nombreMenu';
                                      } else {
                                        return '';
                                      }
                                    }).join(' / ');
                                    return textoDetallePedido != ''
                                        ? Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                //height: 91.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  border: Border.all(
                                                    color:
                                                        const Color(0xFFE0E3E7),
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    //Imagen genérica de pedido
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
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
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            '# ${pedido.numPedido} -> Nombre del cliente: $nombreCliente',
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 14,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child: Text(
                                                              textoDetallePedido,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 12,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        height: 80,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        decoration:
                                                            BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .black26,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Nota adicional',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            Text((pedido.notaAdicional !=
                                                                        null) &&
                                                                    pedido.notaAdicional !=
                                                                        'null'
                                                                ? '${pedido.notaAdicional}'
                                                                : 'sin nota adicional'),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const Gap(15),
                                                    //Botón de opciones
                                                    SizedBox(
                                                      height: 80,
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          await _tryChangePedidoStatus(
                                                              pedido
                                                                  .uuidPedido!);
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          tapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          elevation: 0.0,
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFFFFDFD0),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Entregar',
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: Colors.black,
                                                            fontSize: 12.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Gap(8),
                                            ],
                                          )
                                        : const SizedBox();
                                  }
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _obtenerDetallePedidoConNombreMenu(
      String uuidPedido) async {
    List<PedidoDetalleModel> detalles = await ref
        .read(supabaseManagementProvider.notifier)
        .getDetallesPedido(uuidPedido);

    List<Future<Map<String, Object>>> detalleConNombreMenu =
        detalles.map((detalle) async {
      String nombreMenu = await _obtenerNombreMenu(detalle.idMenu);
      return {
        'detalle': detalle,
        'nombreMenu': nombreMenu,
      };
    }).toList();

    return await Future.wait(detalleConNombreMenu);
  }

  Future<String> _obtenerNombreMenu(int idMenu) async {
    return await ref
        .read(supabaseManagementProvider.notifier)
        .getNombreMenuItemParaCocina(idMenu);
  }

  Future<String> _obtenerNombreCliente(int clienteId) async {
    return await ref
        .read(supabaseManagementProvider.notifier)
        .getClienteName(clienteId);
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
