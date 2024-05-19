import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class EstadisticaContainerMinimalista extends StatelessWidget {
  const EstadisticaContainerMinimalista({
    required this.descripcion,
    required this.icono,
    super.key,
  });
  final String descripcion;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0D3),
        border: Border.all(
          color: const Color(0xFFE0E3E7),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icono,
            color: AppColors.kGeneralPrimaryOrange,
            size: 30,
          ),
          const Gap(10),
          Text(
            descripcion,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
