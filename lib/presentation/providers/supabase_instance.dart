import 'dart:io';
import 'package:ez_order_ezr/presentation/providers/facturacion/pedido_para_view.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:random_string/random_string.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ez_order_ezr/data/factura_modelo.dart';
import 'package:ez_order_ezr/data/categoria_modelo.dart';
import 'package:ez_order_ezr/data/datos_factura_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/facturacion/datos_factura_provider.dart';
import 'package:ez_order_ezr/presentation/providers/reportes/table_rows.dart';
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

      //*NUEVO - INESRTAR FACTURA
      final datosFactura = ref.read(datosFacturaManagerProvider);
      FacturaModelo factura = FacturaModelo(
        idFactura: 0,
        idRestaurante: pedido.idRestaurante,
        uuidPedido: pedidoUuid,
        rtn: datosFactura.rtn,
        direccion: datosFactura.direccion,
        correo: datosFactura.correo,
        telefono: datosFactura.telefono,
        cai: datosFactura.cai,
        numFactura: 0,
        fechaFactura: pedido.createdAt,
        idCliente: pedido.idCliente,
        total: pedido.total,
      );
      if (datosFactura.idDatosFactura != 0) {
        //----revisar si hay datos de factura
        //Revisar si hay factura para saber qué numFactura asignarle
        List<Map<String, dynamic>> lastNumFactura = await state
            .from('facturas')
            .select('num_factura')
            .eq('id_restaurante', pedido.idRestaurante)
            .order('num_factura', ascending: false)
            .limit(1);

        if (lastNumFactura.isNotEmpty) {
          int ultimoNumeroMasUno =
              int.parse(lastNumFactura.first['num_factura'].toString()) + 1;
          factura = factura.copyWith(numFactura: ultimoNumeroMasUno);
        }
      }
      await addFactura(factura);

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

  Future<void> getPedidoPorUuid(String uuidRecibido) async {
    try {
      Map<String, dynamic> singlePedido = await state
          .from('pedidos')
          .select()
          .eq('uuid_pedido', uuidRecibido)
          .limit(1)
          .single();
      PedidoModel pedido = PedidoModel.fromJson(singlePedido);

      //Alimentar el provider de lectura del pedido que se está viendo
      ref.read(pedidoParaViewProvider.notifier).setPedidoParaView(pedido);
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error -> ${e.message}';
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
          .limit(1)
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
      //Luego borrar la factura asociada a ese pedido
      await state.from('facturas').delete().eq('uuid_pedido', uuIdPedido);
      //por último borrar el pedido
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
    // Ajusta finalDate para que sea el final del día
    DateTime adjustedFinalDate = DateTime(
      finalDate.year,
      finalDate.month,
      finalDate.day,
      23,
      59,
      59,
    );

    List<Map<String, dynamic>> res = await state
        .from('pedidos')
        .select()
        .gte('created_at', initialDate.toIso8601String())
        .lte('created_at', adjustedFinalDate.toIso8601String())
        .eq('id_restaurante', idRestaurante)
        .order('created_at', ascending: true);

    //EXTRA - utilizar el mismo query para generar los rows de la TABLA
    await ref.read(pedidosTableRowsProvider.notifier).addDataRows(res);

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

  Future<List<CategoriaModelo>> obtenerCategorias() async {
    Map<String, String> datosPublicos = ref.read(userPublicDataProvider);
    int idRes = int.parse(datosPublicos['id_restaurante'].toString());
    try {
      List<Map<String, dynamic>> res =
          await state.from('categorias').select().eq('id_restaurante', idRes);

      List<CategoriaModelo> listado = [];
      for (var element in res) {
        listado.add(CategoriaModelo.fromJson(element));
      }
      return listado;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error al querer cargar las categorias -> ${e.message}';
    }
  }

  Future<CategoriaModelo> obtenerCategoriaPorId(int idCat) async {
    try {
      Map<String, dynamic> res = await state
          .from('categorias')
          .select()
          .eq('id_categoria', idCat)
          .single();

      CategoriaModelo cat = CategoriaModelo.fromJson(res);

      return cat;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error al querer cargar las categorias -> ${e.message}';
    }
  }

  Future<String> agregarCategoria(CategoriaModelo cat) async {
    Map<String, dynamic> mapa = cat.toJson();
    try {
      await state.from('categorias').insert(mapa);
      return 'success';
    } on PostgrestException catch (e) {
      return 'Ocurrió un error al querer agregar la categoría -> ${e.message}';
    }
  }

  Future<String> actualizarCategoria(CategoriaModelo cat) async {
    Map<String, dynamic> mapa = cat.toJson();
    try {
      await state
          .from('categorias')
          .update(mapa)
          .eq('id_categoria', cat.idCategoria!);
      return 'success';
    } on PostgrestException catch (e) {
      return 'Ocurrió un error al querer agregar la categoría -> ${e.message}';
    }
  }

  Future<String> getDatosFactura() async {
    Map<String, String> datosPublicos = ref.read(userPublicDataProvider);
    int idRes = int.parse(datosPublicos['id_restaurante'].toString());

    try {
      final res = await state
          .from('datos_factura')
          .select()
          .eq('id_restaurante', idRes)
          .count(CountOption.exact);

      if (res.count > 0) {
        DatosFacturaModelo modelo = DatosFacturaModelo.fromJson(res.data.first);
        //asignar los datos al provider de datos de facturación
        ref.read(datosFacturaManagerProvider.notifier).setDatosFactura(modelo);
        return 'success';
      } else {
        return 'vacio';
      }
    } on PostgrestException catch (e) {
      return 'Ocurrió un error al intentar obtener los datos -> ${e.message}';
    }
  }

  Future<String> addDatosFactura(DatosFacturaModelo datos) async {
    Map<String, dynamic> mapa = datos.toJson();
    try {
      await state.from('datos_factura').insert(mapa);
      getDatosFactura();
      return 'success';
    } on PostgrestException catch (e) {
      return 'Ocurrió un error -> ${e.message}';
    }
  }

  Future<String> actualizarDatosFactura(DatosFacturaModelo datos) async {
    Map<String, dynamic> mapa = datos.toJson();
    try {
      await state
          .from('datos_factura')
          .update(mapa)
          .eq('id_datos_factura', datos.idDatosFactura);
      getDatosFactura();
      return 'success';
    } on PostgrestException catch (e) {
      return 'Ocurrió un error -> ${e.message}';
    }
  }

  Future<List<FacturaModelo>> getFacturasYDetalles() async {
    Map<String, String> datosPublicos = ref.read(userPublicDataProvider);
    int idRes = int.parse(datosPublicos['id_restaurante'].toString());
    DateTime startOfDay =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    try {
      List<Map<String, dynamic>> res = await state
          .from('facturas')
          .select()
          .eq('id_restaurante', idRes)
          .gte('fecha_factura', startOfDay.toIso8601String())
          .order('id_factura', ascending: false);
      List<FacturaModelo> listado = [];
      for (var element in res) {
        FacturaModelo modelo = FacturaModelo.fromJson(element);
        //Obtener el nombre del cliente
        String nombreCliente = await getClienteName(modelo.idCliente!);
        modelo = modelo.copyWith(nombreCliente: nombreCliente);
        listado.add(modelo);
      }
      return listado;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error -> ${e.message}';
    }
  }

  Future<List<FacturaModelo>> getFacturasYDetallesPorFecha(
      DateTime fecha) async {
    Map<String, String> datosPublicos = ref.read(userPublicDataProvider);
    int idRes = int.parse(datosPublicos['id_restaurante'].toString());

    // Calcular el inicio y el fin del día para la fecha proporcionada
    DateTime startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
    DateTime endOfDay =
        DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59);

    try {
      List<Map<String, dynamic>> res = await state
          .from('facturas')
          .select()
          .eq('id_restaurante', idRes)
          .gte('fecha_factura', startOfDay.toIso8601String())
          .lte('fecha_factura', endOfDay.toIso8601String())
          .order('id_factura', ascending: false);
      List<FacturaModelo> listado = [];
      for (var element in res) {
        FacturaModelo modelo = FacturaModelo.fromJson(element);
        // Obtener el nombre del cliente
        String nombreCliente = await getClienteName(modelo.idCliente!);
        modelo = modelo.copyWith(nombreCliente: nombreCliente);
        listado.add(modelo);
      }
      return listado;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error -> ${e.message}';
    }
  }

  Future<String> addFactura(FacturaModelo modelo) async {
    Map<String, dynamic> mapa = modelo.toJson();
    try {
      await state.from('facturas').insert(mapa);
      return 'success';
    } on PostgrestException catch (e) {
      return 'Ocurrió un error -> ${e.message}';
    }
  }
}
