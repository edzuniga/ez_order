import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';

class BorrarGastoCajaModal extends ConsumerStatefulWidget {
  const BorrarGastoCajaModal({super.key, required this.idGastoCaja});

  final int idGastoCaja;

  @override
  ConsumerState<BorrarGastoCajaModal> createState() =>
      _BorrarGastoCajaModalState();
}

class _BorrarGastoCajaModalState extends ConsumerState<BorrarGastoCajaModal> {
  bool _isTryingDelete = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 160,
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _isTryingDelete
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text('Por favor espere'),
                ],
              ),
            )
          : Column(
              children: [
                const Text(
                  '¿Estás seguro?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.kTextPrimaryBlack,
                  ),
                ),
                const Gap(5),
                const Text(
                  'Si borras el gasto de caja NO podrás recuperarlo',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const Gap(30),
                //Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Gap(8),
                    ElevatedButton(
                      onPressed: () async {
                        await _tryBorrarGastoCaja();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kGeneralPrimaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Borrar gasto',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _tryBorrarGastoCaja() async {
    setState(() => _isTryingDelete = true);
    await ref
        .read(supabaseManagementProvider.notifier)
        .borrarGastoCajaPorId(widget.idGastoCaja)
        .then((message) {
      setState(() => _isTryingDelete = false);
      if (message == 'success') {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } else {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Ocurrió un error al intentar borrar el gasto de caja -> $message',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ));
      }
    });
  }
}