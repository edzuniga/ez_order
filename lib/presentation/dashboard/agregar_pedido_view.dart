import 'package:auto_size_text/auto_size_text.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class AgregarPedidoView extends StatefulWidget {
  const AgregarPedidoView({super.key});

  @override
  State<AgregarPedidoView> createState() => _AgregarPedidoViewState();
}

class _AgregarPedidoViewState extends State<AgregarPedidoView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                //Título y Botón para agregar productos al menú
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Productos',
                      style: GoogleFonts.roboto(
                        color: AppColors.kTextPrimaryBlack,
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kTextPrimaryBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Agregar producto',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1.0,
                  color: Color(0xFFE0E3E7),
                ),
                Expanded(
                  child: GridView.builder(
                    itemCount: 8,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (ctx, index) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: const Color(0xFFC6C6C6),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: const AspectRatio(
                                aspectRatio: 2.15,
                                child: SizedBox(
                                  child: Placeholder(),
                                ),
                              ),
                            ),
                            const Gap(10),
                            Row(
                              children: [
                                Expanded(
                                  child: AutoSizeText(
                                    'Nombre del producto ',
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    style: GoogleFonts.inter(
                                      height: 1,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Gap(5),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.kTextSecondaryGray,
                                    borderRadius: BorderRadius.circular(8.0),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: const Text(
                                    '1',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(10),
        Expanded(
            flex: 1,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            )),
      ],
    );
  }
}
