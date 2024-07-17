import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class EstadisticaMobileMinimalista extends StatelessWidget {
  const EstadisticaMobileMinimalista({
    required this.descripcion,
    required this.subDescripcion,
    this.icono,
    this.hasCounter = false,
    this.cantidadPedidos,
    this.iconIsOrange = false,
    this.svg,
    super.key,
  });
  final String descripcion;
  final String subDescripcion;
  final IconData? icono;
  final bool hasCounter;
  final String? cantidadPedidos;
  final bool iconIsOrange;
  final SvgPicture? svg;

  @override
  Widget build(BuildContext context) {
    String cantidad =
        cantidadPedidos == null ? '0' : cantidadPedidos.toString();
    return Container(
      padding: const EdgeInsets.all(8),
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          svg ??
              IconTheme(
                data: const IconThemeData(size: 60, weight: 0.5, grade: 0.5),
                child: Icon(
                  icono,
                  color: iconIsOrange
                      ? AppColors.kGeneralPrimaryOrange
                      : Colors.black,
                ),
              ),
          const Gap(10),
          Text(
            descripcion,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subDescripcion,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
          const Gap(10),
          hasCounter
              ? Container(
                  width: 110,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 8,
                      ),
                      const Gap(5),
                      Text(
                        '$cantidad pedidos',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
