import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class DatosActualesFacturaView extends StatelessWidget {
  const DatosActualesFacturaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 25,
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Actualizar datos',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const Gap(10),
              Text(
                'Datos de facturación actuales',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const Gap(15),
              //Nombre del negocio
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nombre del negocio:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Gap(10),
                  Expanded(
                    child: SizedBox(
                      child: Text(
                          'Nombre del negocio, tal como aparece en la factura'),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              //RTN
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RTN:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Gap(10),
                  Expanded(
                    child: SizedBox(
                      child: Text('XXXXXXXXXXXXXX'),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              //Dirección
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dirección:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Gap(10),
                  Expanded(
                    child: SizedBox(
                      child: Text(
                          'Dirección del negocio, tal como aparece en la factura'),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              //Correo
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Correo:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Gap(10),
                  Expanded(
                    child: SizedBox(
                      child: Text('ejemplo@ejemplo.com'),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              //Teléfono
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teléfono:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Gap(10),
                  Expanded(
                    child: SizedBox(
                      child: Text('(504) 1122-3344'),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              const Divider(
                color: AppColors.kGeneralFadedGray,
              ),
              const Gap(10),
              //CAI
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CAI:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Gap(10),
                  Expanded(
                    child: SizedBox(
                      child: Text('XXXXX-XXXXX-XXXXX-XXXXX-XXXXX-XX'),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              //Rango inicial
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rango Inicial:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Gap(10),
                  Expanded(
                    child: SizedBox(
                      child: Text('00000001'),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              //Rango final
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rango final:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Gap(10),
                  Expanded(
                    child: SizedBox(
                      child: Text('00000100'),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              //Fecha límite de emisión
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha límite de emisión:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Gap(10),
                  Expanded(
                    child: SizedBox(
                      child: Text('2024-12-31'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
