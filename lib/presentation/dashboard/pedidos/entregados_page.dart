import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';

class EntregadosPage extends ConsumerStatefulWidget {
  const EntregadosPage({super.key});

  @override
  ConsumerState<EntregadosPage> createState() => _EntregadosPageState();
}

class _EntregadosPageState extends ConsumerState<EntregadosPage> {
  late SupabaseClient _supabase;
  late Stream<List<Map<String, dynamic>>> _stream;
  late Stream<List<Map<String, dynamic>>> _pedidosStreamEntregados;

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
    _pedidosStreamEntregados = _stream.map((data) {
      return data.where((pedido) {
        final createdAt = DateTime.parse(pedido['created_at']);
        return createdAt.isAfter(startOfDay) &&
            createdAt.isBefore(endOfDay) &&
            pedido['en_preparacion'] == false;
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
            'Entregados',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder(
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: Container(
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
                                SizedBox(
                                  width: 90.0,
                                  height: 70.0,
                                  child:
                                      SvgPicture.asset('assets/svg/olla.svg'),
                                ),
                                const Gap(5),
                                //Información del pedido
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
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
}
