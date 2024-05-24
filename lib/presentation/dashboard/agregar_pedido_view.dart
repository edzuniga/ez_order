import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ez_order_ezr/presentation/providers/menus_providers/pedido_detalles_provider.dart';
import 'package:ez_order_ezr/data/pedido_detalle_model.dart';
import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/menu_provider.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/pedido_actual_provider.dart';
import 'package:ez_order_ezr/data/menu_item_model.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/add_menu_modal.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class AgregarPedidoView extends ConsumerStatefulWidget {
  const AgregarPedidoView({super.key});

  @override
  ConsumerState<AgregarPedidoView> createState() => _AgregarPedidoViewState();
}

class _AgregarPedidoViewState extends ConsumerState<AgregarPedidoView> {
  late SupabaseClient _supabase;
  late SupabaseStreamBuilder _stream;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _pedidoListController = ScrollController();

  @override
  void initState() {
    super.initState();
    //Ejecutar los siguiente después que se haya montado el árbol de widgets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //ref.read(menuItemPedidoListProvider.notifier).resetMenuItem();
      ref.read(menuItemPedidoListProvider.notifier).hacerCalculosDelPedido();
    });
    _supabase = ref.read(supabaseManagementProvider);
    _stream = _supabase
        .from('menus')
        .stream(primaryKey: ['id_menu'])
        .eq('id_restaurante', 1)
        .order('nombre_item', ascending: true);
  }

  @override
  Widget build(BuildContext context) {
    final listadoPedido = ref.watch(menuItemPedidoListProvider);
    PedidoModel pedidoActualInfo = ref.watch(pedidoActualProvider);
    List<PedidoDetalleModel> pedidoDetallesList =
        ref.watch(pedidoDetallesManagementProvider);
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
                  child: StreamBuilder(
                    stream: _stream,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              Text('Cargando datos, por favor espere.'),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                              'Ocurrió un error al querer cargar el menú!!'),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child:
                              Text('Aún no hay pedidos para el día de hoy!!'),
                        );
                      } else {
                        List<Map<String, dynamic>> listadoMap = snapshot.data!;
                        List<MenuItemModel> listadoMenuItems = [];
                        for (var element in listadoMap) {
                          listadoMenuItems.add(MenuItemModel.fromJson(element));
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            await Future.delayed(const Duration(seconds: 2))
                                .then((value) => setState(() {}));
                          },
                          child: GridView.builder(
                            itemCount: listadoMenuItems.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 0.85,
                            ),
                            itemBuilder: (ctx, index) {
                              MenuItemModel itemMenu = listadoMenuItems[index];
                              return InkWell(
                                onTap: () {
                                  if (_tryToAddPedidoItem(itemMenu)) {
                                    //Desplazarse hasta el final
                                    _pedidoListController.animateTo(
                                      _pedidoListController
                                              .position.maxScrollExtent +
                                          100,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                },
                                child: Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //Imagen del plato
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: AspectRatio(
                                          aspectRatio: 2.15,
                                          child: SizedBox(
                                            child: Image.network(
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                } else {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              (loadingProgress
                                                                      .expectedTotalBytes ??
                                                                  1)
                                                          : null,
                                                    ),
                                                  );
                                                }
                                              },
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Center(
                                                child: Text(
                                                    'Error al querer cargar imagen'),
                                              ),
                                              itemMenu.img.toString(),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Gap(10),
                                      //Nombre del producto y correlativo
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AutoSizeText(
                                              '${itemMenu.nombreItem} ',
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
                                              color: const Color(0xFFE0E3E7),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: Text(
                                              itemMenu.numMenu,
                                              style: const TextStyle(
                                                  color: AppColors
                                                      .kTextSecondaryGray),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(5),
                                      //Descripción del producto
                                      Text(
                                        'Descripción del producto:',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Expanded(
                                        child: AutoSizeText(
                                          itemMenu.descripcion,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.kTextSecondaryGray,
                                          ),
                                        ),
                                      ),
                                      //Otra información relevante del producto
                                      Text(
                                        itemMenu.otraInfo,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color:
                                              AppColors.kGeneralPrimaryOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
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
                  //Área de orden de cliente
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Orden Actual',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                      Text('# ${pedidoActualInfo.orden}'),
                    ],
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                  //Área para agregar producto al pedido
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      controller: _pedidoListController,
                      itemCount: listadoPedido.length,
                      itemBuilder: (ctx, index) {
                        MenuItemModel itemPedido = listadoPedido[index];
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
                                    child: SizedBox(
                                      width: 80,
                                      height: 40,
                                      child: Image.network(
                                        itemPedido.img!,
                                        fit: BoxFit.cover,
                                      ),
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
                                          itemPedido.nombreItem,
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
                                            Text(itemPedido.precio.toString(),
                                                style: GoogleFonts.inter(
                                                    fontSize: 10)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(3),
                              //Botones de remover, cantidad de producto
                              Row(
                                children: [
                                  Transform.scale(
                                    scale: 0.8,
                                    child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            ref
                                                .read(menuItemPedidoListProvider
                                                    .notifier)
                                                .removeMenuItem(itemPedido);
                                          });
                                        },
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              AppColors.kGeneralErrorColor,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
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
                                        onPressed: () {
                                          if (pedidoDetallesList
                                                  .firstWhere((element) =>
                                                      element.idMenu ==
                                                      itemPedido.idMenu!)
                                                  .cantidad >
                                              1) {
                                            ref
                                                .read(
                                                    pedidoDetallesManagementProvider
                                                        .notifier)
                                                .decrementarCantidad(
                                                    itemPedido.idMenu!);
                                          } else {
                                            Fluttertoast.cancel();
                                            Fluttertoast.showToast(
                                              msg:
                                                  'No puede dejar en 0 el producto!!',
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 3,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                              webPosition: 'center',
                                              webBgColor: 'red',
                                            );
                                          }
                                        },
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFEE8A64),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        icon: const Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                        )),
                                  ),
                                  const Gap(8),
                                  Text((pedidoDetallesList.isNotEmpty)
                                      ? '${pedidoDetallesList.firstWhere((element) => element.idMenu == itemPedido.idMenu!).cantidad}'
                                      : '0'),
                                  const Gap(8),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: IconButton(
                                        onPressed: () {
                                          ref
                                              .read(
                                                  pedidoDetallesManagementProvider
                                                      .notifier)
                                              .incrementarCantidad(
                                                  itemPedido.idMenu!);
                                        },
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFEE8A64),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        )),
                                  ),
                                ],
                              ),
                              const Gap(1),
                              const Divider(
                                color: Color(0xFFE0E3E7),
                              ),
                              const Gap(3),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                  //Área de Subtotal
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
                        'Subtotal:',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'L ${pedidoActualInfo.subtotal}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  //Área de Exonerado
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
                        'Importe exonerado:',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'L ${pedidoActualInfo.importeExonerado}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  //Área de Exento
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
                        'Importe exento:',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'L ${pedidoActualInfo.importeExento}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  //Área de Gravado
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
                        'Importe gravado:',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'L ${pedidoActualInfo.importeGravado}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  //Área de descuento
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
                      Transform.scale(
                        scale: 0.5,
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: IconButton(
                            onPressed: () {},
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'L ${pedidoActualInfo.descuento}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  //Área de ISV
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
                      Text(
                        'L ${pedidoActualInfo.impuestos}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
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
                        'Confirmar orden por L ${pedidoActualInfo.total}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
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
    _pedidoListController.dispose();
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

  bool _tryToAddPedidoItem(MenuItemModel itemMenu) {
    final listadoPedido = ref.read(menuItemPedidoListProvider);
    bool containsWhere =
        listadoPedido.any((element) => element.idMenu == itemMenu.idMenu);
    if (!containsWhere) {
      ref.read(menuItemPedidoListProvider.notifier).addMenuItem(itemMenu);
      return true;
    } else {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: 'Este producto ya está agregado!!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
        webPosition: 'center',
        webBgColor: 'red',
      );
      return false;
    }
  }
}
