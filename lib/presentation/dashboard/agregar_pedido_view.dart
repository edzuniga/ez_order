import 'package:auto_size_text/auto_size_text.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/add_menu_modal.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class AgregarPedidoView extends StatefulWidget {
  const AgregarPedidoView({super.key});

  @override
  State<AgregarPedidoView> createState() => _AgregarPedidoViewState();
}

class _AgregarPedidoViewState extends State<AgregarPedidoView> {
  final TextEditingController _searchController = TextEditingController();
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
                      'Menú',
                      style: GoogleFonts.roboto(
                        color: AppColors.kTextPrimaryBlack,
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _addMenuModal();
                      },
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
                const Gap(5),
                Center(
                  child: TextFormField(
                    controller: _searchController,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {}, icon: const Icon(Icons.search)),
                      hintText:
                          'Búsqueda por nombre, correlativo o descripción...',
                      hintStyle: GoogleFonts.inter(
                        color: AppColors.kTextSecondaryGray,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppColors.kGeneralPrimaryOrange,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppColors.kGeneralErrorColor,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppColors.kGeneralErrorColor,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: AppColors.kInputLiteGray,
                    ),
                    style: GoogleFonts.inter(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo no puede estar vacío';
                      }

                      return null;
                    },
                  ),
                ),
                const Gap(5),
                Expanded(
                  child: GridView.builder(
                    itemCount: 25,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.75,
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
                        child: ListView(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Imagen del plato
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
                            //Nombre del producto y correlativo
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
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(5),
                            //Descripción del producto
                            const Text('Descripción del producto:'),
                            Expanded(
                              child: AutoSizeText(
                                '1 Chuleta con tajadas de plátano, salsa agridulce, chismol, 1 chorizo barbacoa y 3 tortillas.\n*Viene con refresco incluido.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.kTextSecondaryGray,
                                ),
                              ),
                            ),
                            //Otra información relevante del producto
                            Text(
                              'Otra información opcional',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.kGeneralPrimaryOrange,
                              ),
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
        //Área de cálculos del pedido
        Expanded(
          flex: 1,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Orden Actual',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                      const Text('#00233'),
                    ],
                  ),
                  const Gap(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cliente:',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                      const Text('Juan Carlos Jiménez'),
                    ],
                  ),
                  const Gap(15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.circle_outlined,
                        color: AppColors.kTextSecondaryGray,
                        size: 8,
                      ),
                      const Gap(5),
                      Text(
                        'Descuento:',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      const Text('L 240.00'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.circle_outlined,
                        color: AppColors.kTextSecondaryGray,
                        size: 8,
                      ),
                      const Gap(5),
                      Text(
                        'ISV (15%):',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      const Text('L 240.00'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check,
                        color: AppColors.kTextSecondaryGray,
                        size: 20,
                      ),
                      const Gap(5),
                      Text(
                        'Subtotal:',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      const Text('L 240.00'),
                    ],
                  ),
                  const Divider(
                    color: AppColors.kTextSecondaryGray,
                  ),
                  const Gap(10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kGeneralPrimaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                      child: Text(
                        'Confirmar orden',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const Gap(10),
                  const Divider(
                    color: AppColors.kTextSecondaryGray,
                  ),
                  const Gap(10),
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (ctx, index) {
                        return SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              //Imagen, nombre, precio
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    clipBehavior: Clip.hardEdge,
                                    borderRadius: BorderRadius.circular(8),
                                    child: const SizedBox(
                                      width: 80,
                                      height: 40,
                                      child: Placeholder(),
                                    ),
                                  ),
                                  const Gap(5),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nombre del producto',
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Precio:',
                                                style: GoogleFonts.inter(
                                                    fontSize: 10)),
                                            Text('L 250.00',
                                                style: GoogleFonts.inter(
                                                    fontSize: 10)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(8),
                              //Botones de remover, cantidad de producto
                              Row(
                                children: [
                                  Transform.scale(
                                    scale: 0.8,
                                    child: IconButton(
                                        onPressed: () {},
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              AppColors.kGeneralErrorColor,
                                        ),
                                        icon: const Icon(
                                          Icons.delete_forever,
                                          color: Colors.white,
                                        )),
                                  ),
                                  const Spacer(),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: IconButton(
                                        onPressed: () {},
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFEE8A64),
                                        ),
                                        icon: const Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                        )),
                                  ),
                                  const Gap(8),
                                  const Text('1'),
                                  const Gap(8),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: IconButton(
                                        onPressed: () {},
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFEE8A64),
                                        ),
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        )),
                                  ),
                                ],
                              ),
                              const Gap(8),
                              const Divider(
                                color: AppColors.kTextSecondaryGray,
                              ),
                              const Gap(8),
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
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addMenuModal() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(0),
      builder: (_) => const Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: AgregarMenuModal(),
      ),
    );
  }
}
