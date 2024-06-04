import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  late SupabaseClient _supabase;
  late Stream<List<Map<String, dynamic>>> _stream;
  late Stream<List<Map<String, dynamic>>> _pedidosStreamPorEntregar;
  late Stream<List<Map<String, dynamic>>> _pedidosStreamEntregados;
  int _countPedidos = 0;
  int _countMenu = 0;
  late List<GlobalKey> _buttonKeys;

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
        .order('created_at', ascending: false);

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

    _pedidosStreamEntregados = _stream.map((data) {
      return data.where((pedido) {
        final createdAt = DateTime.parse(pedido['created_at']);
        return createdAt.isAfter(startOfDay) &&
            createdAt.isBefore(endOfDay) &&
            pedido['en_preparacion'] == false;
      }).toList();
    });
    countMenuItemsyPedidos();
  }

  Future<void> countMenuItemsyPedidos() async {
    _countMenu =
        await ref.read(supabaseManagementProvider.notifier).countMenuItems();
    _countPedidos = await ref
        .read(supabaseManagementProvider.notifier)
        .countPedidosDelDia();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                    //Containers con estadísticas senciilas del día
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
                    const Row(
                      children: [
                        Expanded(
                          child: EstadisticaContainerMinimalista(
                            descripcion: 'Ayuda',
                            icono: Icons.help_outline_rounded,
                          ),
                        ),
                        Gap(10),
                        Expanded(
                          child: EstadisticaContainerMinimalista(
                            descripcion: 'Soporte',
                            icono: Icons.record_voice_over_outlined,
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
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: ElevatedButton(
                                                key: _buttonKeys[index],
                                                onPressed: () {
                                                  //-----obtener la posición del botón
                                                  final RenderBox button =
                                                      _buttonKeys[index]
                                                              .currentContext!
                                                              .findRenderObject()
                                                          as RenderBox;
                                                  final RenderBox overlay =
                                                      Overlay.of(context)
                                                              .context
                                                              .findRenderObject()
                                                          as RenderBox;
                                                  final RelativeRect position =
                                                      RelativeRect.fromRect(
                                                    Rect.fromPoints(
                                                      button.localToGlobal(
                                                          Offset.zero,
                                                          ancestor: overlay),
                                                      button.localToGlobal(
                                                          button.size
                                                              .bottomRight(
                                                                  Offset.zero),
                                                          ancestor: overlay),
                                                    ),
                                                    Offset.zero & overlay.size,
                                                  );
                                                  //-----obtener la posición del botón

                                                  //Mostrar el PopupMenu
                                                  showMenu(
                                                    context: context,
                                                    position:
                                                        position, // Posición del menú
                                                    items: <PopupMenuEntry<
                                                        int>>[
                                                      PopupMenuItem(
                                                        value: 1,
                                                        onTap: () {},
                                                        child: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Icon(Icons.edit),
                                                            Gap(5),
                                                            Text('Editar'),
                                                          ],
                                                        ),
                                                      ),
                                                      const PopupMenuDivider(),
                                                      PopupMenuItem(
                                                        value: 2,
                                                        onTap: () {},
                                                        child: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Icon(Icons
                                                                .delete_forever),
                                                            Gap(5),
                                                            Text('Cancelar'),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ).then((value) {
                                                    // Manejar la selección
                                                    if (value != null) {
                                                      // Acción en base al valor seleccionado
                                                    }
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  elevation: 0.0,
                                                  backgroundColor:
                                                      const Color(0xFFFFDFD0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Opciones',
                                                  style: GoogleFonts.inter(
                                                    color: Colors.black,
                                                    fontSize: 12.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
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
              ),
            ],
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
}
