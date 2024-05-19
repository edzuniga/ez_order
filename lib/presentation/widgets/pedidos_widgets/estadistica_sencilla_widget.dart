import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class EstadisticaContainer extends StatelessWidget {
  const EstadisticaContainer({
    required this.estadistica,
    required this.descripcion,
    required this.icono,
    super.key,
  });
  final String estadistica;
  final String descripcion;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: 150,
      height: 150,
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
          Icon(
            icono,
            color: AppColors.kGeneralPrimaryOrange,
          ),
          Text(
            estadistica,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            descripcion,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
