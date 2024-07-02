import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ez_order_ezr/presentation/dashboard/modals/update_menu_from_web_modal.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/add_menu_from_web_modal.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/add_categoria_modal.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/update_categoria_modal.dart';
import 'package:ez_order_ezr/data/categoria_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/categorias/listado_categorias.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/nota_adicional_modal.dart';
import 'package:ez_order_ezr/data/cliente_modelo.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/metodo_pago_modal.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/cliente_modal.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/descuento_modal.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/update_menu_modal.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/cliente_actual_provider.dart';
import 'package:ez_order_ezr/presentation/dashboard/modals/delete_menu_modal.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
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
  late List<CategoriaModelo> categorias;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _pedidoListController = ScrollController();
  int idCat = 0;
  final ScrollController _categoriasController = ScrollController();

  //Navegación con el controlador de las categorías
  void _scrollLeft() {
    _categoriasController.animateTo(
      _categoriasController.offset - 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _scrollRight() {
    _categoriasController.animateTo(
      _categoriasController.offset + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
  //Navegación con el controlador de las categorías

  @override
  void initState() {
    super.initState();
    //Ejecutar los siguiente después que se haya montado el árbol de widgets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //ref.read(menuItemPedidoListProvider.notifier).resetMenuItem();
      ref.read(menuItemPedidoListProvider.notifier).hacerCalculosDelPedido();
    });
    _supabase = ref.read(supabaseManagementProvider);
    _iniciarStream();
    _getClientesForDropdown('');
    setCategoriasButtons();
  }

  void _iniciarStream() {
    int userIdRestaurante = int.parse(
        ref.read(userPublicDataProvider)['id_restaurante'].toString());
    _stream = _supabase
        .from('menus')
        .stream(primaryKey: ['id_menu'])
        .eq('id_restaurante', userIdRestaurante)
        .order('nombre_item', ascending: true);
  }

  void _filtrarPorCategoria(int? idCategoria) {
    setState(() {
      idCat = idCategoria ?? 0;
    });
  }

  Future<List<ClienteModelo>> _getClientesForDropdown(String filter) async {
    return await ref
        .read(supabaseManagementProvider.notifier)
        .obtenerClientesPorIdRestaurante('');
  }

  Future<void> setCategoriasButtons() async {
    List<CategoriaModelo> listadoCats =
        await ref.read(supabaseManagementProvider.notifier).obtenerCategorias();
    ref.read(listadoCategoriasProvider.notifier).setCategorias(listadoCats);
  }

  @override
  Widget build(BuildContext context) {
    //Obtener tamaño de la pantalla
    Size screenSize = MediaQuery.of(context).size;
    ClienteModelo clienteActual = ref.watch(clientePedidoActualProvider);
    List<MenuItemModel> listadoPedido = ref.watch(menuItemPedidoListProvider);
    PedidoModel pedidoActualInfo = ref.watch(pedidoActualProvider);
    List<PedidoDetalleModel> pedidoDetallesList =
        ref.watch(pedidoDetallesManagementProvider);
    List<CategoriaModelo> listadoCategorias =
        ref.watch(listadoCategoriasProvider);

    //-------generar los botones de categorías
    List<Widget> listadoBotones = [];
    for (var element in listadoCategorias) {
      listadoBotones.add(Row(
        children: [
          ElevatedButton(
              onPressed: () {
                _filtrarPorCategoria(element.idCategoria);
              },
              onLongPress: () {
                _updateCategoriaModal(element);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: idCat == element.idCategoria
                    ? AppColors.kGeneralPrimaryOrange
                    : null,
              ),
              child: Text(
                element.nombreCategoria,
                style: TextStyle(
                  color: idCat == element.idCategoria
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              )),
          const Gap(10),
        ],
      ));
    }
    //-------generar los botones de categorías

    return screenSize.width >= 1000
        ? bigBody(listadoBotones, clienteActual, listadoPedido,
            pedidoDetallesList, pedidoActualInfo)
        : smallBody(listadoBotones, clienteActual, listadoPedido,
            pedidoDetallesList, pedidoActualInfo);
  }

  //For WEB displays ABOVE 1000 px (width) and Tablets
  Row bigBody(
    List<Widget> listadoBotones,
    ClienteModelo clienteActual,
    List<MenuItemModel> listadoPedido,
    List<PedidoDetalleModel> pedidoDetallesList,
    PedidoModel pedidoActualInfo,
  ) {
    return Row(
      children: [
        //Área de menú
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Título y Botón para agregar productos al menú
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Productos',
                      style: GoogleFonts.roboto(
                        color: AppColors.kTextPrimaryBlack,
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (kIsWeb) {
                          await _addMenuFromWebModal();
                        } else {
                          await _addMenuModal();
                        }
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
                //Listado de categorías
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 45,
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              controller: _categoriasController,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _filtrarPorCategoria(
                                          null); //Mostrar todos los productos
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: idCat == 0
                                          ? AppColors.kGeneralPrimaryOrange
                                          : null,
                                    ),
                                    child: Text(
                                      'Todo',
                                      style: TextStyle(
                                        color: idCat == 0
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Gap(10),
                                  ...listadoBotones,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: IconButton(
                                onPressed: _scrollLeft,
                                style: IconButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.kGeneralPrimaryOrange),
                                  backgroundColor: const Color(0xFFF6F6F6),
                                ),
                                icon: const Icon(
                                  Icons.arrow_left,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: IconButton(
                                onPressed: _scrollRight,
                                style: IconButton.styleFrom(
                                    side: const BorderSide(
                                        color: AppColors.kGeneralPrimaryOrange),
                                    backgroundColor: const Color(0xFFF6F6F6)),
                                icon: const Icon(
                                  Icons.arrow_right,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(5),
                    ElevatedButton.icon(
                      onPressed: () {
                        _addCategoriaModal();
                      },
                      label: const Text(
                        'categoría',
                        style: TextStyle(
                          color: AppColors.kGeneralPrimaryOrange,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: AppColors.kGeneralPrimaryOrange,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      icon: const Icon(
                        Icons.add,
                        color: AppColors.kGeneralPrimaryOrange,
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                //ÁREA DE MENÚ DINÁMICO
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
                              'Ocurrió un error al querer cargar el catálogo de productos!!'),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text('Aún no ha agregado productos!!'),
                        );
                      } else {
                        List<Map<String, dynamic>> listadoMap = snapshot.data!;
                        List<MenuItemModel> listadoMenuItems = [];

                        for (var element in listadoMap) {
                          //* Filtrar solamente para los activos
                          if (element['activo'] == true) {
                            var menuItem = MenuItemModel.fromJson(element);
                            // Aplicar filtro de categoría si está seleccionado
                            if (idCat == 0 || menuItem.idCategoria == idCat) {
                              listadoMenuItems.add(menuItem);
                            }
                          }
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
                              childAspectRatio: 0.80,
                            ),
                            itemBuilder: (ctx, index) {
                              MenuItemModel itemMenu = listadoMenuItems[index];
                              return Stack(
                                children: [
                                  InkWell(
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
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .kGeneralPrimaryOrange,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Text(
                                                  itemMenu.numMenu,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Gap(5),
                                          //Descripción del producto
                                          AutoSizeText(
                                            itemMenu.descripcion,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color:
                                                  AppColors.kTextSecondaryGray,
                                            ),
                                          ),
                                          //Otra información relevante del producto
                                          Text(
                                            itemMenu.otraInfo,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: AppColors
                                                  .kGeneralPrimaryOrange,
                                            ),
                                          ),
                                          const Spacer(),
                                          //Precio de VENTA
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 12),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color:
                                                        const Color(0xFFFFDFCF),
                                                  ),
                                                  child: Text(
                                                    'L ${itemMenu.precioConIsv}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0.0,
                                    top: 20.0,
                                    child: Container(
                                      height: 25,
                                      width: 45,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          bottomLeft: Radius.circular(4),
                                        ),
                                      ),
                                      child: PopupMenuButton<int>(
                                        color: Colors.white,
                                        surfaceTintColor: Colors.white,
                                        onSelected: (v) async {
                                          switch (v) {
                                            //Caso editar
                                            case 1:
                                              if (kIsWeb) {
                                                await _updateMenuFromWebModal(
                                                    itemMenu);
                                              } else {
                                                await _updateMenuModal(
                                                    itemMenu);
                                              }
                                              break;

                                            //Caso borrar
                                            case 2:
                                              await _deleteMenuItemModal(
                                                  itemMenu);
                                              break;
                                          }
                                        },
                                        itemBuilder: (ctx) {
                                          return <PopupMenuEntry<int>>[
                                            const PopupMenuItem(
                                                value: 1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Icon(Icons.edit),
                                                    Gap(5),
                                                    Text('Editar'),
                                                  ],
                                                )),
                                            const PopupMenuDivider(),
                                            const PopupMenuItem(
                                                value: 2,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Icon(Icons.delete_forever),
                                                    Gap(5),
                                                    Text('Borrar'),
                                                  ],
                                                )),
                                          ];
                                        },
                                        child: const Icon(
                                          Icons.more_horiz,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Cliente:',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                      const Gap(10),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: DropdownSearch<ClienteModelo>(
                            asyncItems: (filter) async {
                              return await _getClientesForDropdown(filter);
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              baseStyle: const TextStyle(
                                fontSize: 13,
                              ),
                              dropdownSearchDecoration: InputDecoration(
                                hintText: 'Búsqueda por nombre...',
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
                            ),
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                            ),
                            itemAsString: (ClienteModelo c) =>
                                c.clienteAsString(),
                            onChanged: (ClienteModelo? data) {
                              //Asignar el cliente selecto al provider
                              if (data != null) {
                                ref
                                    .read(clientePedidoActualProvider.notifier)
                                    .actualizarInfoCliente(
                                      idCliente: data.idCliente ?? 1,
                                      rtnCliente: data.rtnCliente ?? '',
                                      nombreCliente: data.nombreCliente,
                                      correoCliente: data.correoCliente ?? '',
                                      descuentoCliente:
                                          data.descuentoCliente ?? 0.0,
                                      exonerado: data.exonerado,
                                    );
                              }
                            },
                            selectedItem: clienteActual,
                          ),
                        ),
                      ),
                      //Text(clienteActual.nombreCliente),
                      Transform.scale(
                        scale: 0.8,
                        child: IconButton(
                            onPressed: () async {
                              await _showAgregarClienteModal();
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.kTextPrimaryBlack,
                            ),
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            )),
                      ),
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
                        String precioDetalle = pedidoDetallesList
                            .firstWhere((element) =>
                                element.idMenu == itemPedido.idMenu!)
                            .importeCobrado
                            .toStringAsFixed(2);
                        return SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              //Imagen, nombre, precio
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
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
                                            Text('Precio a cobrarse:',
                                                style: GoogleFonts.inter(
                                                    fontSize: 10)),
                                            Text('L $precioDetalle',
                                                //'L ${itemPedido.precioSinIsv}',
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
                                    scale: 0.7,
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
                                    scale: 0.7,
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
                                            if (kIsWeb) {
                                              ScaffoldMessenger.of(context)
                                                  .clearSnackBars();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                        'No puede dejar en 0 el producto!!',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      )));
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
                                    scale: 0.7,
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
                              const Divider(
                                color: Color(0xFFE0E3E7),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  //Área de NOTA ADICIONAL y Agregar descuento del pedido
                  Row(
                    children: [
                      //Agregar descuento
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await _addDescuentoModal();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: AppColors.kGeneralPrimaryOrange,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Descuento',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              AppColors.kGeneralPrimaryOrange,
                                        ),
                                      ),
                                      Icon(
                                        Icons.add_circle,
                                        color: AppColors.kGeneralPrimaryOrange,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Gap(4),
                            ],
                          ),
                        ),
                      ),
                      const Gap(5),
                      //Agregar nota adicional
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              InkWell(
                                onTap: () async {
                                  _addNotaAdicional();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: AppColors.kGeneralPrimaryOrange,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Nota adicional',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              AppColors.kGeneralPrimaryOrange,
                                        ),
                                      ),
                                      Icon(
                                        Icons.add_circle,
                                        color: AppColors.kGeneralPrimaryOrange,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Gap(4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      children: [
                        //Detalles de factura (subtotal, impuesto, importe..., etc..)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.kInputLiteGray,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ExpansionTile(
                            dense: true,
                            title: const Text(
                              'Detalles de facturación',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            trailing:
                                const Icon(Icons.arrow_drop_down_outlined),
                            children: [
                              //Área de Subtotal
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Gap(15),
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
                                  const Gap(15),
                                ],
                              ),
                              //Área de Exonerado
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Gap(15),
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
                                  const Gap(15),
                                ],
                              ),
                              //Área de Exento
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Gap(15),
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
                                  const Gap(15),
                                ],
                              ),
                              //Área de Gravado
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Gap(15),
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
                                  const Gap(15),
                                ],
                              ),
                              //Área de descuento
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Gap(15),
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
                                  Text(
                                    'L ${pedidoActualInfo.descuento}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  const Gap(15),
                                ],
                              ),
                              //Área de ISV
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Gap(15),
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
                                  const Gap(15),
                                ],
                              ),
                              const Gap(5),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Botón para enviar orden
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _metodoPagoModal();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kGeneralPrimaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                      child: RichText(
                        text: TextSpan(
                          text: 'Enviar orden por ',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                                text: 'L ${pedidoActualInfo.total}',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                )),
                          ],
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

  //For WEB displays BELOW 1000 px (width)
  Column smallBody(
      List<Widget> listadoBotones,
      ClienteModelo clienteActual,
      List<MenuItemModel> listadoPedido,
      List<PedidoDetalleModel> pedidoDetallesList,
      PedidoModel pedidoActualInfo) {
    return Column(
      children: [
        //Área de menú
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Título y Botón para agregar productos al menú
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Productos',
                      style: GoogleFonts.roboto(
                        color: AppColors.kTextPrimaryBlack,
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (kIsWeb) {
                          await _addMenuFromWebModal();
                        } else {
                          await _addMenuModal();
                        }
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
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _filtrarPorCategoria(
                                    null); //Mostrar todos los productos
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: idCat == 0
                                    ? AppColors.kGeneralPrimaryOrange
                                    : null,
                              ),
                              child: Text(
                                'Todo',
                                style: TextStyle(
                                  color:
                                      idCat == 0 ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Gap(10),
                            ...listadoBotones,
                          ],
                        ),
                      ),
                    ),
                    const Gap(5),
                    ElevatedButton.icon(
                      onPressed: () {
                        _addCategoriaModal();
                      },
                      label: const Text(
                        'categoría',
                        style: TextStyle(
                          color: AppColors.kGeneralPrimaryOrange,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: AppColors.kGeneralPrimaryOrange,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      icon: const Icon(
                        Icons.add,
                        color: AppColors.kGeneralPrimaryOrange,
                      ),
                    ),
                  ],
                ),
                const Gap(5),
                //ÁREA DE MENÚ DINÁMICO
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
                              'Ocurrió un error al querer cargar el catálogo de productos!!'),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text('Aún no ha agregado productos!!'),
                        );
                      } else {
                        List<Map<String, dynamic>> listadoMap = snapshot.data!;
                        List<MenuItemModel> listadoMenuItems = [];

                        for (var element in listadoMap) {
                          //* Filtrar solamente para los activos
                          if (element['activo'] == true) {
                            var menuItem = MenuItemModel.fromJson(element);
                            // Aplicar filtro de categoría si está seleccionado
                            if (idCat == 0 || menuItem.idCategoria == idCat) {
                              listadoMenuItems.add(menuItem);
                            }
                          }
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
                              childAspectRatio: 0.80,
                            ),
                            itemBuilder: (ctx, index) {
                              MenuItemModel itemMenu = listadoMenuItems[index];
                              return Stack(
                                children: [
                                  InkWell(
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
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .kGeneralPrimaryOrange,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Text(
                                                  itemMenu.numMenu,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Gap(5),
                                          //Descripción del producto
                                          AutoSizeText(
                                            itemMenu.descripcion,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color:
                                                  AppColors.kTextSecondaryGray,
                                            ),
                                          ),
                                          //Otra información relevante del producto
                                          Text(
                                            itemMenu.otraInfo,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: AppColors
                                                  .kGeneralPrimaryOrange,
                                            ),
                                          ),
                                          const Spacer(),
                                          //Precio de VENTA
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 12),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color:
                                                        const Color(0xFFFFDFCF),
                                                  ),
                                                  child: Text(
                                                    'L ${itemMenu.precioConIsv}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0.0,
                                    top: 20.0,
                                    child: Container(
                                      height: 25,
                                      width: 45,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          bottomLeft: Radius.circular(4),
                                        ),
                                      ),
                                      child: PopupMenuButton<int>(
                                        color: Colors.white,
                                        surfaceTintColor: Colors.white,
                                        onSelected: (v) async {
                                          switch (v) {
                                            //Caso editar
                                            case 1:
                                              if (kIsWeb) {
                                                await _updateMenuFromWebModal(
                                                    itemMenu);
                                              } else {
                                                await _updateMenuModal(
                                                    itemMenu);
                                              }
                                              break;

                                            //Caso borrar
                                            case 2:
                                              await _deleteMenuItemModal(
                                                  itemMenu);
                                              break;
                                          }
                                        },
                                        itemBuilder: (ctx) {
                                          return <PopupMenuEntry<int>>[
                                            const PopupMenuItem(
                                                value: 1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Icon(Icons.edit),
                                                    Gap(5),
                                                    Text('Editar'),
                                                  ],
                                                )),
                                            const PopupMenuDivider(),
                                            const PopupMenuItem(
                                                value: 2,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Icon(Icons.delete_forever),
                                                    Gap(5),
                                                    Text('Borrar'),
                                                  ],
                                                )),
                                          ];
                                        },
                                        child: const Icon(
                                          Icons.more_horiz,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
          flex: 5,
          child: Container(
            width: double.infinity,
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Cliente:',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                      const Gap(10),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: DropdownSearch<ClienteModelo>(
                            asyncItems: (filter) async {
                              return await _getClientesForDropdown(filter);
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              baseStyle: const TextStyle(
                                fontSize: 13,
                              ),
                              dropdownSearchDecoration: InputDecoration(
                                hintText: 'Búsqueda por nombre...',
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
                            ),
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                            ),
                            itemAsString: (ClienteModelo c) =>
                                c.clienteAsString(),
                            onChanged: (ClienteModelo? data) {
                              //Asignar el cliente selecto al provider
                              if (data != null) {
                                ref
                                    .read(clientePedidoActualProvider.notifier)
                                    .actualizarInfoCliente(
                                      idCliente: data.idCliente ?? 1,
                                      rtnCliente: data.rtnCliente ?? '',
                                      nombreCliente: data.nombreCliente,
                                      correoCliente: data.correoCliente ?? '',
                                      descuentoCliente:
                                          data.descuentoCliente ?? 0.0,
                                      exonerado: data.exonerado,
                                    );
                              }
                            },
                            selectedItem: clienteActual,
                          ),
                        ),
                      ),
                      //Text(clienteActual.nombreCliente),
                      Transform.scale(
                        scale: 0.8,
                        child: IconButton(
                            onPressed: () async {
                              await _showAgregarClienteModal();
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.kTextPrimaryBlack,
                            ),
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            )),
                      ),
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
                        String precioDetalle = pedidoDetallesList
                            .firstWhere((element) =>
                                element.idMenu == itemPedido.idMenu!)
                            .importeCobrado
                            .toStringAsFixed(2);
                        return SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              //Imagen, nombre, precio
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
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
                                            Text('Precio a cobrarse:',
                                                style: GoogleFonts.inter(
                                                    fontSize: 10)),
                                            Text('L $precioDetalle',
                                                //'L ${itemPedido.precioSinIsv}',
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
                                    scale: 0.7,
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
                                    scale: 0.7,
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
                                            if (kIsWeb) {
                                              ScaffoldMessenger.of(context)
                                                  .clearSnackBars();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                        'No puede dejar en 0 el producto!!',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      )));
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
                                    scale: 0.7,
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
                              const Divider(
                                color: Color(0xFFE0E3E7),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  //Área de NOTA ADICIONAL y Descuento del pedido
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await _addDescuentoModal();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: AppColors.kGeneralPrimaryOrange,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Descuento',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              AppColors.kGeneralPrimaryOrange,
                                        ),
                                      ),
                                      Icon(
                                        Icons.add_circle,
                                        color: AppColors.kGeneralPrimaryOrange,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Gap(4),
                            ],
                          ),
                        ),
                      ),
                      const Gap(5),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              InkWell(
                                onTap: () async {
                                  _addNotaAdicional();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: AppColors.kGeneralPrimaryOrange,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Nota adicional',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              AppColors.kGeneralPrimaryOrange,
                                        ),
                                      ),
                                      Icon(
                                        Icons.add_circle,
                                        color: AppColors.kGeneralPrimaryOrange,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Gap(4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  //Detalles de factura (subtotal, impuesto, importe..., etc..)
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.2), // Color de la sombra
                          spreadRadius: 1, // Radio de expansión
                          blurRadius: 8, // Radio de desenfoque
                          offset: const Offset(0, 4), // Desplazamiento en X y Y
                        ),
                      ],
                    ),
                    child: ListView(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.kInputLiteGray,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ExpansionTile(
                            dense: true,
                            title: const Text(
                              'Detalles de facturación',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            trailing:
                                const Icon(Icons.arrow_drop_down_outlined),
                            children: [
                              //Área de Subtotal
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Gap(15),
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
                                  const Gap(15),
                                ],
                              ),
                              //Área de Exonerado
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Gap(15),
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
                                  const Gap(15),
                                ],
                              ),
                              //Área de Exento
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Gap(15),
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
                                  const Gap(15),
                                ],
                              ),
                              //Área de Gravado
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Gap(15),
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
                                  const Gap(15),
                                ],
                              ),
                              //Área de descuento
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Gap(15),
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
                                  Text(
                                    'L ${pedidoActualInfo.descuento}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  const Gap(15),
                                ],
                              ),
                              //Área de ISV
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Gap(15),
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
                                  const Gap(15),
                                ],
                              ),
                              const Gap(5),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Botón para enviar orden
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _metodoPagoModal();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kGeneralPrimaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                      child: RichText(
                        text: TextSpan(
                          text: 'Enviar orden por ',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                                text: 'L ${pedidoActualInfo.total}',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                )),
                          ],
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
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: AgregarMenuModal(),
      ),
    );
  }

  Future<void> _addMenuFromWebModal() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: AgregarMenuFromWebModal(),
      ),
    );
  }

  Future<void> _addNotaAdicional() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: NotaAdicionalModal(),
      ),
    );
  }

  Future<void> _addDescuentoModal() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: DescuentoModal(),
      ),
    );
  }

  Future<void> _metodoPagoModal() async {
    final listadoPedido = ref.watch(menuItemPedidoListProvider);
    if (listadoPedido.isNotEmpty) {
      bool? res = await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (_) => const Dialog(
          elevation: 8,
          backgroundColor: Colors.transparent,
          child: MetodoPagoModal(),
        ),
      );

      if (res != null && res == true) {
        setState(() {
          ref
              .read(pedidoDetallesManagementProvider.notifier)
              .resetPedidosDetallesList();
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Pedido agregado con éxito!!',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ));
      }
    } else {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'No puede enviar una orden vacía!!',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ));
      } else {
        Fluttertoast.cancel();
        Fluttertoast.showToast(
          msg: 'No puede enviar una orden vacía!!',
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
    }
  }

  Future<void> _updateMenuModal(MenuItemModel itemMenu) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: UpdateMenuModal(itemMenu: itemMenu),
      ),
    );
  }

  Future<void> _updateMenuFromWebModal(MenuItemModel itemMenu) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: UpdateMenuFromWebModal(itemMenu: itemMenu),
      ),
    );
  }

  Future<void> _deleteMenuItemModal(MenuItemModel itemMenu) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: DeleteMenuItemModal(menuItem: itemMenu),
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
      if (kIsWeb) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Este producto ya está agregado!!',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ));
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
      }
      return false;
    }
  }

  Future<void> _showAgregarClienteModal() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: ClienteModal(),
      ),
    );
  }

  void _addCategoriaModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: AddCategoriaModal(),
      ),
    );
  }

  void _updateCategoriaModal(CategoriaModelo cat) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: UpdateCategoriaModal(
          catRecibida: cat,
        ),
      ),
    );
  }
}
