import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/widgets/cocina/app_bar_cocina.dart';

class CocinaPage extends StatefulWidget {
  const CocinaPage({super.key});

  @override
  State<CocinaPage> createState() => _CocinaPageState();
}

class _CocinaPageState extends State<CocinaPage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
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
                //Título para las de cocina
                Container(
                  height: 46,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Pedidos por entregar',
                    style: GoogleFonts.roboto(
                      color: AppColors.kTextPrimaryBlack,
                      fontSize: 18.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 100.0,
                                      height: 81.0,
                                      child: Image.asset(
                                        'images/pedidos.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const Gap(5),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          'Descripción:\n2 fajitas con carne / chorizo / 1 chuleta con tajadas / 1 Hernán y 1 Onán.',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        elevation: 0.0,
                                        backgroundColor:
                                            const Color(0xFFFFDFD0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      child: Text(
                                        'Entregar',
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
            ),
          ),
        ),
      ),
    );
  }
}
