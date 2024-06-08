import 'dart:io';
import 'package:ez_order_ezr/presentation/providers/reportes/table_rows.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:random_string/random_string.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ez_order_ezr/data/restaurante_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/duenos_restaurantes/duenos_restaurantes_provider.dart';
import 'package:ez_order_ezr/data/pedido_detalle_model.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/cliente_actual_provider.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/menu_provider.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/metodo_pago_actual.dart';
import 'package:ez_order_ezr/data/pedido_model.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/pedido_actual_provider.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/pedido_detalles_provider.dart';
import 'package:ez_order_ezr/data/menu_item_model.dart';
import 'package:ez_order_ezr/data/cliente_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
part 'supabase_instance.g.dart';

@Riverpod(keepAlive: true)
class SupabaseManagement extends _$SupabaseManagement {
  @override
  SupabaseClient build() {
    final instance = Supabase.instance.client;
    return instance;
  }

  //MÉTODOS PARA EL MENÚ
  //Agregar un ítem para el menú
  Future<String> addMenuItem(MenuItemModel menuItemModel, File image) async {
    String nombreAleatorioParaImagen = randomAlphaNumeric(20);
    // Utiliza el paquete path para obtener la extensión
    String extension = p.extension(image.path);
    nombreAleatorioParaImagen += extension;

    try {
      //Cargar la foto del producto
      final String fotoPathFromSupa = await state.storage
          .from('menus')
          .upload(nombreAleatorioParaImagen, image,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ));
      String rutaCompletaImagen =
          'https://rgvfnyskploauwgnmzqf.supabase.co/storage/v1/object/public/$fotoPathFromSupa';
      //Asignarle el path de supa al menuItemModel recibido
      MenuItemModel modeloParaCargar =
          menuItemModel.copyWith(img: rutaCompletaImagen);
      Map menuItemMap = modeloParaCargar.toJson();
      await state.from('menus').insert(menuItemMap);
      return 'success';
    } on StorageException catch (s) {
      return s.message;
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Actualizar un ítem para el menú
  Future<String> updateMenuItem(
      MenuItemModel menuItemModel, File? image) async {
    //Cuando el image decidió NO cambiarlo
    if (image != null) {
      String nombreAleatorioParaImagen = randomAlphaNumeric(20);
      // Utiliza el paquete path para obtener la extensión
      String extension = p.extension(image.path);
      nombreAleatorioParaImagen += extension;

      try {
        //Cargar la foto del producto
        final String fotoPathFromSupa = await state.storage
            .from('menus')
            .upload(nombreAleatorioParaImagen, image,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: false,
                ));
        String rutaCompletaImagen =
            'https://rgvfnyskploauwgnmzqf.supabase.co/storage/v1/object/public/$fotoPathFromSupa';
        //Asignarle el path de supa al menuItemModel recibido
        MenuItemModel modeloParaCargar =
            menuItemModel.copyWith(img: rutaCompletaImagen);
        Map menuItemMap = modeloParaCargar.toJson();
        await state
            .from('menus')
            .update(menuItemMap)
            .eq('id_menu', menuItemModel.idMenu!);
        return 'success';
      } on StorageException catch (s) {
        return s.message;
      } on PostgrestException catch (e) {
        return e.message;
      }
    } else {
      Map menuItemMap = menuItemModel.toJson();
      try {
        await state
            .from('menus')
            .update(menuItemMap)
            .eq('id_menu', menuItemModel.idMenu!);
        return 'success';
      } on PostgrestException catch (e) {
        return e.message;
      }
    }
  }

  Future<String> deleteMenuItem(int menuItemId) async {
    try {
      await state.from('menus').delete().eq('id_menu', menuItemId);
      return 'success';
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Inactivar el ítem de menú para evitar borrar
  Future<String> inactivateMenuItem(int menuItemId) async {
    try {
      await state
          .from('menus')
          .update({'activo': false}).eq('id_menu', menuItemId);
      return 'success';
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Obtener todos los clientes - filtrados por el id del restaurante
  Future<List<ClienteModelo>> obtenerClientesPorIdRestaurante(
      String filtro) async {
    int currentIdRestaurante =
        int.parse(ref.read(userPublicDataProvider)['id_restaurante']!);
    try {
      List<Map<String, dynamic>> resMap = [];
      if (filtro.isEmpty) {
        resMap = await state
            .from('clientes')
            .select()
            .eq('id_restaurante', currentIdRestaurante)
            .order('nombre_cliente', ascending: true);
      } else {
        resMap = await state
            .from('clientes')
            .select()
            .eq('id_restaurante', currentIdRestaurante)
            .contains('nombre_cliente', filtro)
            .order('nombre_cliente', ascending: true);
      }

      List<ClienteModelo> listadoClientesModelo = [];
      ClienteModelo usuarioDefault = ClienteModelo(
        idCliente: 1,
        rtnCliente: '',
        nombreCliente: 'Consumidor final',
        correoCliente: '',
        descuentoCliente: 0.0,
        idRestaurante: currentIdRestaurante,
        exonerado: false,
      );
      listadoClientesModelo.add(usuarioDefault);
      for (var element in resMap) {
        listadoClientesModelo.add(ClienteModelo.fromJson(element));
      }
      return listadoClientesModelo;
    } on PostgrestException catch (e) {
      throw 'Error al querer cargar clientes: ${e.message}';
    }
  }

  //Agregar un cliente nuevo
  Future<String> agregarCliente(ClienteModelo cliente) async {
    Map<String, dynamic> mapaCliente = cliente.toJson();
    try {
      await state.from('clientes').insert(mapaCliente);
      return 'success';
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Agregar pedido
  Future<String> agregarPedido(PedidoModel pedido) async {
    Map<String, dynamic> mapaPedido = pedido.toJson();
    try {
      final resPedido = await state.from('pedidos').insert(mapaPedido).select();
      String pedidoUuid = resPedido.first['uuid_pedido'];

      //Guardar los detalles del pedido
      List<PedidoDetalleModel> listadoProviDetalles =
          ref.read(pedidoDetallesManagementProvider);
      for (PedidoDetalleModel element in listadoProviDetalles) {
        PedidoDetalleModel detalleModelFinal =
            element.copyWith(uuidPedido: pedidoUuid);
        Map<String, dynamic> detalleMap = detalleModelFinal.toJson();
        await state.from('pedidos_items').insert(detalleMap);
      }

      //Resetear el pedido actual y vacíar los detalles
      ref.read(pedidoActualProvider.notifier).resetearPedidoActual();
      //Resetear Menu Pedido (incluído el listado de detalles)
      ref.read(menuItemPedidoListProvider.notifier).resetMenuItem();
      //Regresar al cliente "Consumidor final"
      ref.read(clientePedidoActualProvider.notifier).resetClienteOriginal();
      //Regresar al método de pago "efectivo"
      ref.read(metodoPagoActualProvider.notifier).resetMetodoDePago();

      return 'success';
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  Future<String> getClienteName(int clienteId) async {
    try {
      final res =
          await state.from('clientes').select().eq('id_cliente', clienteId);
      String nombreCliente = res.first['nombre_cliente'];
      return nombreCliente;
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  Future<List<PedidoDetalleModel>> getDetallesPedido(String uuIdPedido) async {
    try {
      final res = await state
          .from('pedidos_items')
          .select()
          .eq('uuid_pedido', uuIdPedido);
      List<PedidoDetalleModel> listadoProvi = [];
      for (var element in res) {
        listadoProvi.add(PedidoDetalleModel.fromJson(element));
      }
      return listadoProvi;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> countMenuItems() async {
    try {
      int userIdRestaurante = int.parse(
          ref.read(userPublicDataProvider)['id_restaurante'].toString());
      final res = await state
          .from('menus')
          .select()
          .eq('id_restaurante', userIdRestaurante)
          .count(CountOption.exact);
      return res.count;
    } on PostgrestException catch (e) {
      throw Exception(
          'Error al contar los elementos del catálogo: ${e.message}');
    }
  }

  Future<int> countPedidosDelDia() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    try {
      int userIdRestaurante = int.parse(
          ref.read(userPublicDataProvider)['id_restaurante'].toString());
      final res = await state
          .from('pedidos')
          .select()
          .eq('id_restaurante', userIdRestaurante)
          .gte(
            'created_at',
            startOfDay,
          )
          .count(CountOption.exact);
      return res.count;
    } on PostgrestException catch (e) {
      throw Exception(
          'Error al contar los elementos del catálogo: ${e.message}');
    }
  }

  Future<String> getNombreMenuItem(int idMenu) async {
    try {
      final res = await state
          .from('menus')
          .select('nombre_item')
          .eq('id_menu', idMenu)
          .single();
      return res['nombre_item'];
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  Future<String> changePedidoStatus(String uuIdPedido) async {
    try {
      await state
          .from('pedidos')
          .update({'en_preparacion': false}).eq('uuid_pedido', uuIdPedido);
      return 'success';
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  Future<String> borrarPedido(String uuIdPedido) async {
    try {
      //Primero borrar los detalles
      await state.from('pedidos_items').delete().eq('uuid_pedido', uuIdPedido);
      await state.from('pedidos').delete().eq('uuid_pedido', uuIdPedido);
      return 'success';
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  Future<String> obtenerIdRestaurantesPorDueno(String uuIdDueno) async {
    try {
      List<Map<String, dynamic>> res = await state
          .from('dueno_restaurantes')
          .select()
          .eq('uuid_dueno', uuIdDueno);

      final duenosRes = ref.read(duenosResManagerProvider.notifier);
      duenosRes.resetLlistRestaurantes(); //Limpiar lista inicialmente
      for (Map<String, dynamic> element in res) {
        //Obtener sus datos de Supa para luego agregarlos al provider de restaurantes
        Map<String, dynamic> singleRes = await state
            .from('restaurantes')
            .select()
            .eq('id_restaurante', element['id_restaurante'])
            .single();
        duenosRes.addRestaurante(RestauranteModelo.fromJson(singleRes));
      }
      return 'success';
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  Future<List<double>> obtenerIngresosTotalesEntreFechas(
      DateTime initialDate, DateTime finalDate, int idRestaurante) async {
    List<Map<String, dynamic>> res = await state
        .from('pedidos')
        .select('created_at, total, id_restaurante')
        .gte('created_at', initialDate.toIso8601String())
        .lte('created_at', finalDate.toIso8601String())
        .eq('id_restaurante', idRestaurante)
        .order('created_at', ascending: true);

    //EXTRA - utilizar el mismo query para generar los rows de la TABLA
    ref.read(pedidosTableRowsProvider.notifier).addDataRows(res);

    Map<String, double> dailyTotals = {};

    // Generate a list of dates within the range
    List<DateTime> dateRange = [];
    for (DateTime date = initialDate;
        date.isBefore(finalDate) || date.isAtSameMomentAs(finalDate);
        date = date.add(const Duration(days: 1))) {
      dateRange.add(date);
    }

    // Initialize the dailyTotals map with 0.0 for each date in the range
    for (var date in dateRange) {
      String dateString = DateFormat('yyyy-MM-dd').format(date);
      dailyTotals[dateString] = 0.0;
    }

    // Sum the totals for each date
    for (Map<String, dynamic> entry in res) {
      String date =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(entry['created_at']));
      double total = entry['total'].toDouble();

      if (dailyTotals.containsKey(date)) {
        dailyTotals[date] = dailyTotals[date]! + total;
      }
    }

    List<double> dailyTotalsList = dailyTotals.values.toList();

    return dailyTotalsList;
  }
}
