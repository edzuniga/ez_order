import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ez_order_ezr/presentation/widgets/pedidos_widgets/estadistica_minimalista_mobile_widget.dart';
import 'package:ez_order_ezr/presentation/widgets/pedidos_widgets/estadistica_container_mobile_widget.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/borrar_pedido_modal.dart';
import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/config/routes.dart';
import 'package:ez_order_ezr/presentation/providers/dashboard_page_index.dart';
import 'package:ez_order_ezr/presentation/widgets/pedidos_widgets/estadistica_minimalista_widget.dart';
import 'package:ez_order_ezr/presentation/widgets/pedidos_widgets/estadistica_sencilla_widget.dart';

class PedidosView extends ConsumerStatefulWidget {
  const PedidosView({super.key});

  @override
  ConsumerState<PedidosView> createState() => _PedidosViewState();
}

class _PedidosViewState extends ConsumerState<PedidosView> {
  bool _isDisposed = false;
  late SupabaseClient _supabase;
  late Stream<List<Map<String, dynamic>>> _stream;
  late Stream<List<Map<String, dynamic>>> _pedidosStreamPorEntregar;
  late Stream<List<Map<String, dynamic>>> _pedidosStreamEntregados;
  int _countPedidos = 0;
  int _countMenu = 0;
  int _countClientes = 0;
  int _countPedidosEnPreparacion = 0;
  int _countPedidosEntregados = 0;
  late List<GlobalKey> _buttonKeys;

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
    //final endOfDay = startOfDay.add(const Duration(days: 1));

    //Filtración interna del stream general, condicionado por fecha (solo fecha de hoy)
    _pedidosStreamPorEntregar = _stream.map((data) {
      return data.where((pedido) {
        final createdAt = DateTime.parse(pedido['created_at']);
        return createdAt.isAfter(startOfDay) &&
            pedido['en_preparacion'] == true;
      }).toList();
    });

    _pedidosStreamEntregados = _stream.map((data) {
      return data.where((pedido) {
        final createdAt = DateTime.parse(pedido['created_at']);
        return createdAt.isAfter(startOfDay) &&
            pedido['en_preparacion'] == false;
      }).toList();
    });
    countMenuSimpleStatistics();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> countMenuSimpleStatistics() async {
    if (_isDisposed || !mounted) return;
    _countMenu =
        await ref.read(supabaseManagementProvider.notifier).countMenuItems();
    if (_isDisposed || !mounted) return;
    _countPedidos = await ref
        .read(supabaseManagementProvider.notifier)
        .countPedidosDelDia();
    if (_isDisposed || !mounted) return;
    _countClientes =
        await ref.read(supabaseManagementProvider.notifier).countClientes();
    if (_isDisposed || !mounted) return;
    _countPedidosEnPreparacion = await ref
        .read(supabaseManagementProvider.notifier)
        .countPedidosDelDiaEnPreparacion();
    if (_isDisposed || !mounted) return;
    _countPedidosEntregados = await ref
        .read(supabaseManagementProvider.notifier)
        .countPedidosDelDiaEntregados();
    if (!_isDisposed && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    // Obtener la orientación actual del dispositivo
    Orientation orientation = MediaQuery.of(context).orientation;

    //lógica para WEB
    if (kIsWeb) {
      if (screenSize.width <= 850) {
        return portraitWebView(context);
      }
      return landscapeWebView(context);
    } else {
      //lógica para Dispositivos móviles
      if (orientation == Orientation.portrait) {
        return portraitMobileView(context);
      }
      return landscapeMobileView(context);
    }
  }

  //View horizontal desde 850 hacia arriba para WEB
  Widget landscapeWebView(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        //Área de resumen diario y opciones de soporte
        Expanded(
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Containers con estadísticas sencillas del día
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        EstadisticaContainer(
                          estadistica: '$_countMenu',
                          descripcion: 'Productos en catálogo',
                          icono: Icons.restaurant_outlined,
                        ),
                        EstadisticaContainer(
                          estadistica: '$_countPedidos',
                          descripcion: 'Número de pedidos',
                          icono: Icons.shopping_bag_outlined,
                        ),
                        EstadisticaContainer(
                          estadistica: '$_countClientes',
                          descripcion: 'Clientes registrados',
                          icono: Icons.group,
                        ),
                      ],
                    ),
                    const Gap(10),
                    const Divider(
                      thickness: 1.0,
                      color: Color(0xFFE0E3E7),
                    ),
                    const Gap(10),
                    //Botones centrales
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: const Color(0xFFC6C6C6),
                          width: 0.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(
                                  color: AppColors.kGeneralPrimaryOrange,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8))),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'AGREGAR PEDIDO',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                ref
                                    .read(dashboardPageIndexProvider.notifier)
                                    .changePageIndex(1);
                                context.goNamed(Routes.agregarPedido);
                              },
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: const BoxDecoration(
                                    color: Color(0xFFF6F6F6),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8))),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.shopping_bag_outlined),
                                    Text(
                                      'Click Aquí',
                                      style: GoogleFonts.inter(
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(10),
                    const Divider(
                      thickness: 1.0,
                      color: Color(0xFFE0E3E7),
                    ),
                    const Gap(10),
                    //Containers para ayuda y soporte
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              await _launchUrlWeb();
                            },
                            child: const EstadisticaContainerMinimalista(
                              descripcion: 'Ayuda',
                              icono: Icons.help_outline_rounded,
                            ),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              await _launchURL();
                            },
                            child: const EstadisticaContainerMinimalista(
                              descripcion: 'Soporte',
                              icono: Icons.record_voice_over_outlined,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Gap(8),
        //Área de ordenes entregadas del día
        Expanded(
          child: Column(
            children: [
              //Pedidos por entregar
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          'EN PREPARACIÓN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder(
                          stream: _pedidosStreamPorEntregar,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Map<String, dynamic>>>
                                  snapshot) {
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
                              List<Map<String, dynamic>> listadoMap =
                                  snapshot.data!;
                              List<PedidoModel> listadoPedidos = [];
                              for (var element in listadoMap) {
                                listadoPedidos
                                    .add(PedidoModel.fromJson(element));
                              }
                              _buttonKeys = List.generate(listadoPedidos.length,
                                  (index) => GlobalKey());
                              return ListView.builder(
                                physics: const ClampingScrollPhysics(),
                                itemCount: listadoPedidos.length,
                                itemBuilder: (ctx, index) {
                                  PedidoModel pedido = listadoPedidos[index];
                                  return FutureBuilder(
                                    future:
                                        _obtenerNombreCliente(pedido.idCliente),
                                    builder: (BuildContext ctx,
                                        AsyncSnapshot<String> s) {
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
                                        String nombreCliente = s.data!;
                                        return Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              //height: 91.0,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFFE0E3E7),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  //Imagen del pedido
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
                                                  //Información del pedido
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
                                                          '# ${pedido.numPedido}',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 14,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Total: L ${pedido.total}',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 12,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const Gap(10),
                                                        RichText(
                                                          text: TextSpan(
                                                            text: 'Orden: ',
                                                            style: GoogleFonts
                                                                .inter(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 8.0,
                                                            ),
                                                            children: [
                                                              TextSpan(
                                                                text: pedido
                                                                    .orden,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 8.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    '\nCliente: ',
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 8.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    nombreCliente,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 8.0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Icon(Icons.circle,
                                                                size: 10,
                                                                color: (pedido
                                                                        .enPreparacion)
                                                                    ? AppColors
                                                                        .kGeneralPrimaryOrange
                                                                    : Colors
                                                                        .green),
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
                                                        key: _buttonKeys[index],
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
                                                          backgroundColor: AppColors
                                                              .kGeneralPrimaryOrange,
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
                                                            color: Colors.white,
                                                            fontSize: 12.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                      const Gap(10),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          await _tryBorrarPedido(
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
                                                              Colors.black,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Cancelar',
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: Colors.white,
                                                            fontSize: 12.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w700,
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
                    ],
                  ),
                ),
              ),
              const Gap(8),
              //Pedidos entregados
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'ENTREGADOS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder(
                          stream: _pedidosStreamEntregados,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Map<String, dynamic>>>
                                  snapshot) {
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
                              List<Map<String, dynamic>> listadoMap =
                                  snapshot.data!;
                              List<PedidoModel> listadoPedidos = [];
                              for (var element in listadoMap) {
                                listadoPedidos
                                    .add(PedidoModel.fromJson(element));
                              }

                              return ListView.builder(
                                physics: const ClampingScrollPhysics(),
                                itemCount: listadoPedidos.length,
                                itemBuilder: (ctx, index) {
                                  PedidoModel pedido = listadoPedidos[index];
                                  return FutureBuilder(
                                    future:
                                        _obtenerNombreCliente(pedido.idCliente),
                                    builder: (BuildContext ctx,
                                        AsyncSnapshot<String> s) {
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
                                        String nombreCliente = s.data!;
                                        return Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              //height: 91.0,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFFE0E3E7),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  //Imagen del pedido
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
                                                  //Información del pedido
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
                                                          '# ${pedido.numPedido}',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 14,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Total: L ${pedido.total}',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 12,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const Gap(10),
                                                        RichText(
                                                          text: TextSpan(
                                                            text: 'Orden: ',
                                                            style: GoogleFonts
                                                                .inter(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 8.0,
                                                            ),
                                                            children: [
                                                              TextSpan(
                                                                text: pedido
                                                                    .orden,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 8.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    '\nCliente: ',
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 8.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    nombreCliente,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 8.0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Icon(Icons.circle,
                                                                size: 10,
                                                                color: (pedido
                                                                        .enPreparacion)
                                                                    ? AppColors
                                                                        .kGeneralPrimaryOrange
                                                                    : Colors
                                                                        .green),
                                                            const Gap(8),
                                                            const Text(
                                                              'Entregado',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //View horizontal para MÓVILES
  Widget landscapeMobileView(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        //Área de resumen diario y opciones de soporte
        Expanded(
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Containers con estadísticas sencillas del día
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        EstadisticaContainer(
                          estadistica: '$_countMenu',
                          descripcion: 'Productos en catálogo',
                          icono: Icons.restaurant_outlined,
                        ),
                        EstadisticaContainer(
                          estadistica: '$_countPedidos',
                          descripcion: 'Número de pedidos',
                          icono: Icons.shopping_bag_outlined,
                        ),
                        EstadisticaContainer(
                          estadistica: '$_countClientes',
                          descripcion: 'Clientes registrados',
                          icono: Icons.group,
                        ),
                      ],
                    ),
                    const Gap(10),
                    const Divider(
                      thickness: 1.0,
                      color: Color(0xFFE0E3E7),
                    ),
                    const Gap(10),
                    //Botones centrales
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: const Color(0xFFC6C6C6),
                          width: 0.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(
                                  color: AppColors.kGeneralPrimaryOrange,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8))),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'AGREGAR PEDIDO',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                ref
                                    .read(dashboardPageIndexProvider.notifier)
                                    .changePageIndex(1);
                                context.goNamed(Routes.agregarPedido);
                              },
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: const BoxDecoration(
                                    color: Color(0xFFF6F6F6),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8))),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.shopping_bag_outlined),
                                    Text(
                                      'Click Aquí',
                                      style: GoogleFonts.inter(
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(10),
                    const Divider(
                      thickness: 1.0,
                      color: Color(0xFFE0E3E7),
                    ),
                    const Gap(10),
                    //Containers para ayuda y soporte
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              await _launchUrlWeb();
                            },
                            child: const EstadisticaContainerMinimalista(
                              descripcion: 'Ayuda',
                              icono: Icons.help_outline_rounded,
                            ),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              await _launchURL();
                            },
                            child: const EstadisticaContainerMinimalista(
                              descripcion: 'Soporte',
                              icono: Icons.record_voice_over_outlined,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Gap(8),
        //Área de ordenes entregadas del día
        Expanded(
          child: Column(
            children: [
              //Pedidos por entregar
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          'EN PREPARACIÓN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder(
                          stream: _pedidosStreamPorEntregar,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Map<String, dynamic>>>
                                  snapshot) {
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
                              List<Map<String, dynamic>> listadoMap =
                                  snapshot.data!;
                              List<PedidoModel> listadoPedidos = [];
                              for (var element in listadoMap) {
                                listadoPedidos
                                    .add(PedidoModel.fromJson(element));
                              }
                              _buttonKeys = List.generate(listadoPedidos.length,
                                  (index) => GlobalKey());
                              return ListView.builder(
                                physics: const ClampingScrollPhysics(),
                                itemCount: listadoPedidos.length,
                                itemBuilder: (ctx, index) {
                                  PedidoModel pedido = listadoPedidos[index];
                                  return FutureBuilder(
                                    future:
                                        _obtenerNombreCliente(pedido.idCliente),
                                    builder: (BuildContext ctx,
                                        AsyncSnapshot<String> s) {
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
                                        String nombreCliente = s.data!;
                                        return Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              //height: 91.0,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFFE0E3E7),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  //Información del pedido
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
                                                          '# ${pedido.numPedido}',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 14,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Total: L ${pedido.total}',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 12,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const Gap(10),
                                                        RichText(
                                                          text: TextSpan(
                                                            text: 'Orden: ',
                                                            style: GoogleFonts
                                                                .inter(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 8.0,
                                                            ),
                                                            children: [
                                                              TextSpan(
                                                                text: pedido
                                                                    .orden,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 8.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    '\nCliente: ',
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 8.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    nombreCliente,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 8.0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Icon(Icons.circle,
                                                                size: 10,
                                                                color: (pedido
                                                                        .enPreparacion)
                                                                    ? AppColors
                                                                        .kGeneralPrimaryOrange
                                                                    : Colors
                                                                        .green),
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
                                                        key: _buttonKeys[index],
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
                                                          backgroundColor: AppColors
                                                              .kGeneralPrimaryOrange,
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
                                                            color: Colors.white,
                                                            fontSize: 12.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                      const Gap(10),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          await _tryBorrarPedido(
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
                                                              Colors.black,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Cancelar',
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: Colors.white,
                                                            fontSize: 12.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w700,
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
                    ],
                  ),
                ),
              ),
              const Gap(8),
              //Pedidos entregados
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'ENTREGADOS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder(
                          stream: _pedidosStreamEntregados,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Map<String, dynamic>>>
                                  snapshot) {
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
                              List<Map<String, dynamic>> listadoMap =
                                  snapshot.data!;
                              List<PedidoModel> listadoPedidos = [];
                              for (var element in listadoMap) {
                                listadoPedidos
                                    .add(PedidoModel.fromJson(element));
                              }

                              return ListView.builder(
                                physics: const ClampingScrollPhysics(),
                                itemCount: listadoPedidos.length,
                                itemBuilder: (ctx, index) {
                                  PedidoModel pedido = listadoPedidos[index];
                                  return FutureBuilder(
                                    future:
                                        _obtenerNombreCliente(pedido.idCliente),
                                    builder: (BuildContext ctx,
                                        AsyncSnapshot<String> s) {
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
                                        String nombreCliente = s.data!;
                                        return Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              //height: 91.0,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFFE0E3E7),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  //Imagen del pedido
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
                                                  //Información del pedido
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
                                                          '# ${pedido.numPedido}',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 14,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Total: L ${pedido.total}',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 12,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const Gap(10),
                                                        RichText(
                                                          text: TextSpan(
                                                            text: 'Orden: ',
                                                            style: GoogleFonts
                                                                .inter(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 8.0,
                                                            ),
                                                            children: [
                                                              TextSpan(
                                                                text: pedido
                                                                    .orden,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 8.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    '\nCliente: ',
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 8.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    nombreCliente,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 8.0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Icon(Icons.circle,
                                                                size: 10,
                                                                color: (pedido
                                                                        .enPreparacion)
                                                                    ? AppColors
                                                                        .kGeneralPrimaryOrange
                                                                    : Colors
                                                                        .green),
                                                            const Gap(8),
                                                            const Text(
                                                              'Entregado',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //View vertical para WEB desde 850 hacia abajo
  Widget portraitWebView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        //Área de resumen diario y opciones de soporte
        Expanded(
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Containers para ayuda y soporte
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              await _launchUrlWeb();
                            },
                            child: const EstadisticaContainerMinimalista(
                              descripcion: 'Ayuda',
                              icono: Icons.help_outline_rounded,
                            ),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              await _launchURL();
                            },
                            child: const EstadisticaContainerMinimalista(
                              descripcion: 'Soporte',
                              icono: Icons.record_voice_over_outlined,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Gap(8),
        //Área de ordenes entregadas del día
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'EN PREPARACIÓN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
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
                          child: Text(
                              'Ocurrió un error al querer cargar los datos!!'),
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
                        _buttonKeys = List.generate(
                            listadoPedidos.length, (index) => GlobalKey());
                        return ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          itemCount: listadoPedidos.length,
                          itemBuilder: (ctx, index) {
                            PedidoModel pedido = listadoPedidos[index];
                            return FutureBuilder(
                              future: _obtenerNombreCliente(pedido.idCliente),
                              builder:
                                  (BuildContext ctx, AsyncSnapshot<String> s) {
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
                                  String nombreCliente = s.data!;
                                  return Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        //height: 91.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Total: L ${pedido.total}',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const Gap(10),
                                                  RichText(
                                                    text: TextSpan(
                                                      text: 'Orden: ',
                                                      style: GoogleFonts.inter(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 8.0,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: pedido.orden,
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: Colors.grey,
                                                            fontSize: 8.0,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: '\nCliente: ',
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 8.0,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: nombreCliente,
                                                          style:
                                                              GoogleFonts.inter(
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
                                                          color: (pedido
                                                                  .enPreparacion)
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
                                                  key: _buttonKeys[index],
                                                  onPressed: () async {
                                                    await _tryChangePedidoStatus(
                                                        pedido.uuidPedido!);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    elevation: 0.0,
                                                    backgroundColor: AppColors
                                                        .kGeneralPrimaryOrange,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Entregar',
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                const Gap(10),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await _tryBorrarPedido(
                                                        pedido.uuidPedido!);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    elevation: 0.0,
                                                    backgroundColor:
                                                        Colors.black,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Cancelar',
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w700,
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
              ],
            ),
          ),
        ),
        const Gap(8),
        //Pedidos entregados
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'ENTREGADOS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: _pedidosStreamEntregados,
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
                          child: Text(
                              'Ocurrió un error al querer cargar los datos!!'),
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
                              builder:
                                  (BuildContext ctx, AsyncSnapshot<String> s) {
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
                                  String nombreCliente = s.data!;
                                  return Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        //height: 91.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Total: L ${pedido.total}',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const Gap(10),
                                                  RichText(
                                                    text: TextSpan(
                                                      text: 'Orden: ',
                                                      style: GoogleFonts.inter(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 8.0,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: pedido.orden,
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: Colors.grey,
                                                            fontSize: 8.0,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: '\nCliente: ',
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 8.0,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: nombreCliente,
                                                          style:
                                                              GoogleFonts.inter(
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
                                                          color: (pedido
                                                                  .enPreparacion)
                                                              ? AppColors
                                                                  .kGeneralPrimaryOrange
                                                              : Colors.green),
                                                      const Gap(8),
                                                      const Text(
                                                        'Entregado',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  //View vertical para MÓVILES
  Widget portraitMobileView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        //Área de resumen diario y opciones de soporte
        Expanded(
          child: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, AppColors.kGeneralFadedOrange],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: RefreshIndicator(
              onRefresh: () async => await countMenuSimpleStatistics()
                  .whenComplete(() => setState(() {})),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Área de estadísticas simples
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            EstadisticaMobileContainer(
                              estadistica: '$_countMenu',
                              descripcion: 'Productos en catálogo',
                              icono: Icons.restaurant_outlined,
                            ),
                            const Gap(10),
                            EstadisticaMobileContainer(
                              estadistica: '$_countPedidos',
                              descripcion: 'Número de pedidos',
                              icono: Icons.shopping_bag_outlined,
                            ),
                            const Gap(10),
                            EstadisticaMobileContainer(
                              estadistica: '$_countClientes',
                              descripcion: 'Clientes registrados',
                              icono: Icons.group,
                            ),
                          ],
                        ),
                      ),
                      const Gap(20),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          ref
                              .read(dashboardPageIndexProvider.notifier)
                              .changePageIndex(1);
                          context.goNamed(Routes.agregarPedido);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 136,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            color: AppColors.kGeneralPrimaryOrange,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/svg/bolsa-compras.svg'),
                              Text(
                                'AGREGAR PEDIDO',
                                style: GoogleFonts.inter(
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                              const Text(
                                'Click para realizar pedidos',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const Gap(15),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          context.pushNamed(Routes.cocina);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 136,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/svg/utensilios.svg'),
                              Text(
                                'COCINA',
                                style: GoogleFonts.inter(
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.kGeneralPrimaryOrange),
                              ),
                              const Text(
                                'Click para ver pedidos en cocina',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const Gap(20),
                      //Containers para ver En Preparación y Entregados
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                context.pushNamed(Routes.enPreparacion);
                              },
                              child: EstadisticaMobileMinimalista(
                                descripcion: 'En Preparación',
                                subDescripcion: 'Pedidos en cocina',
                                cantidadPedidos: '$_countPedidosEnPreparacion',
                                hasCounter: true,
                                svg: SvgPicture.asset('assets/svg/olla.svg'),
                              ),
                            ),
                          ),
                          const Gap(15),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                context.pushNamed(Routes.entregados);
                              },
                              child: EstadisticaMobileMinimalista(
                                descripcion: 'Entregados',
                                subDescripcion: 'Pedidos entregados',
                                cantidadPedidos: '$_countPedidosEntregados',
                                hasCounter: true,
                                svg: SvgPicture.asset('assets/svg/cheque.svg'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(15),
                      //Containers para ayuda y soporte
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await _launchUrlWeb();
                              },
                              child: EstadisticaMobileMinimalista(
                                descripcion: 'Ayuda',
                                subDescripcion: 'Sitio de ayuda',
                                iconIsOrange: true,
                                svg: SvgPicture.asset('assets/svg/ayuda.svg'),
                              ),
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await _launchURL();
                              },
                              child: EstadisticaMobileMinimalista(
                                descripcion: 'Soporte',
                                subDescripcion: 'vía WhatsApp',
                                iconIsOrange: true,
                                svg: SvgPicture.asset('assets/svg/soporte.svg'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<String> _obtenerNombreCliente(int clienteId) async {
    return await ref
        .read(supabaseManagementProvider.notifier)
        .getClienteName(clienteId);
  }

  Future<void> _launchURL() async {
    const phoneNumber = '50433905572';
    const message = 'Necesito ayuda con mi app';
    final url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    final Uri parsedUrl = Uri.parse(url);

    if (await canLaunchUrl(parsedUrl)) {
      await launchUrl(parsedUrl);
    } else {
      throw 'No se pudo abrir $url';
    }
  }

  Future<void> _launchUrlWeb() async {
    const url = 'https://docs.ezorderhn.com/ezorder';
    final Uri parsedUrl = Uri.parse(url);

    if (await canLaunchUrl(parsedUrl)) {
      await launchUrl(parsedUrl);
    } else {
      throw 'No se pudo abrir $url';
    }
  }

  Future<void> _tryBorrarPedido(String uuIdPedido) async {
    bool? res = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: BorrarPedidoModal(uuIdPedido: uuIdPedido),
      ),
    );

    if (res != null) {
      setState(() {});
    }
  }

  Future<void> _tryChangePedidoStatus(String uuIdPedido) async {
    await ref
        .read(supabaseManagementProvider.notifier)
        .changePedidoStatus(uuIdPedido)
        .then((message) {
      if (message != 'success') {
        if (!mounted) return;
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
          if (!mounted) return;
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
