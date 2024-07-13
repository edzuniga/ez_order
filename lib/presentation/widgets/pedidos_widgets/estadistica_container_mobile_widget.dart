import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class EstadisticaMobileContainer extends StatelessWidget {
  const EstadisticaMobileContainer({
    required this.estadistica,
    required this.descripcion,
    required this.icono,
    this.includesRibbon = false,
    this.cantidad,
    this.isIconBlack = false,
    super.key,
  });
  final String estadistica;
  final String descripcion;
  final IconData icono;
  final bool includesRibbon;
  final String? cantidad;
  final bool isIconBlack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          width: 148,
          height: 134,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE0E3E7),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  icono,
                  color: isIconBlack
                      ? Colors.black
                      : AppColors.kGeneralPrimaryOrange,
                ),
              ),
              Text(
                estadistica,
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                descripcion,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.1,
                  //fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        includesRibbon
            ? Positioned(
                right: 10,
                top: 0,
                child: Container(
                  width: 35,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: AppColors.kGeneralPrimaryOrange,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cantidad.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
