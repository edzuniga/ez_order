import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/data/menu_item_model.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';

class DeleteMenuItemModal extends ConsumerStatefulWidget {
  const DeleteMenuItemModal({required this.menuItem, super.key});

  final MenuItemModel menuItem;

  @override
  ConsumerState<DeleteMenuItemModal> createState() =>
      _DeleteMenuItemModalState();
}

class _DeleteMenuItemModalState extends ConsumerState<DeleteMenuItemModal> {
  bool _isTryingDelete = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 250,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: _isTryingDelete
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.kGeneralPrimaryOrange,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Estás seguro que deseas borrar este ítem?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(10),
                  Text('Nombre del producto: ${widget.menuItem.nombreItem}'),
                  const Gap(45),
                  const Text(
                    '* No se puede recuperar si lo borras',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const Gap(5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                          await _tryInactivateMenuItem();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kGeneralPrimaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Borrar producto',
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
            ),
    );
  }

  Future<void> _tryInactivateMenuItem() async {
    //llamar la única instancia de supabase
    final supabaseClient = ref.read(supabaseManagementProvider.notifier);
    setState(() => _isTryingDelete = true);
    await supabaseClient
        .inactivateMenuItem(widget.menuItem.idMenu!)
        .then((message) {
      setState(() => _isTryingDelete = false);
      if (message == 'success') {
        if (!mounted) return;
        Navigator.of(context).pop();
      } else {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Ocurrió un error al intentar borrar el ítem de menú -> $message',
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
