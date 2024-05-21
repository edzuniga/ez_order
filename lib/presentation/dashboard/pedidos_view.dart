import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
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
                    const Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        EstadisticaContainer(
                          estadistica: '1000',
                          descripcion: 'Opciones del menú',
                          icono: Icons.restaurant_outlined,
                        ),
                        EstadisticaContainer(
                          estadistica: '1000',
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
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (ctx, index) {
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '# 000${index + 1}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Total: L 280.50',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Gap(10),
                                RichText(
                                  text: TextSpan(
                                    text: 'Fecha: ',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 8.0,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'mayo 19, 2024',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey,
                                          fontSize: 8.0,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '\nHora: ',
                                        style: GoogleFonts.inter(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 8.0,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '5:15pm',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey,
                                          fontSize: 8.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //Botón para las acciones del pedido
                          Align(
                            alignment: Alignment.topRight,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                elevation: 0.0,
                                backgroundColor: const Color(0xFFFFDFD0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
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
              },
            ),
          ),
        ),
      ],
    );
  }
}
