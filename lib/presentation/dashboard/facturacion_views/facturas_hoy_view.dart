import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class FacturasDeHoyView extends StatefulWidget {
  const FacturasDeHoyView({super.key});

  @override
  State<FacturasDeHoyView> createState() => _FacturasDeHoyViewState();
}

class _FacturasDeHoyViewState extends State<FacturasDeHoyView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      itemCount: 15,
      itemBuilder: (ctx, index) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
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
                  //Imagen genérica de pedido
                  const Icon(
                    Icons.receipt,
                    color: AppColors.kGeneralPrimaryOrange,
                  ),
                  const Gap(10),
                  //Fecha y hora
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Factura #',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Fecha y hora: ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Cliente y total
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cliente: Consumidor Final',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text('Total: L. 500.00'),
                      ],
                    ),
                  ),
                  const Gap(15),
                  //ENVIAR
                  IconButton(
                    onPressed: () {},
                    tooltip: 'Compartir',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.kGeneralPrimaryOrange,
                    ),
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                  ),
                  //IMPRIMIR
                  IconButton(
                    onPressed: () {},
                    tooltip: 'Imprimir',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    icon: const Icon(
                      Icons.print,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
          ],
        );
      },
    );
  }
}
