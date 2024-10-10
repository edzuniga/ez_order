import 'dart:io';
import 'dart:typed_data';
import 'package:ez_order_ezr/data/inventario_modelo.dart';
import 'package:ez_order_ezr/domain/inventario.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:random_string/random_string.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ez_order_ezr/presentation/providers/reportes/rows_ventas_por_producto.dart';
import 'package:ez_order_ezr/data/registro_caja_modelo.dart';
import 'package:ez_order_ezr/data/caja_abierta_modelo.dart';
import 'package:ez_order_ezr/data/caja_apertura_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/facturacion/pedido_para_view.dart';
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

  //Agregar un ítem para el menú desde la WEB
  Future<String> addMenuItemFromWeb(MenuItemModel menuItemModel,
      String storagePath, Uint8List imageBytes, XFile? pickedImage) async {
    String mimeType = pickedImage!.mimeType.toString();
    // Determinar la extensión del archivo
    String extension = '';
    String contentType = 'image/jpeg';
    if (mimeType == 'image/jpeg') {
      extension = 'jpg';
      contentType = 'image/jpeg';
    } else if (mimeType == 'image/png') {
      extension = 'png';
      contentType = 'image/png';
    } else if (mimeType == 'image/webp') {
      extension = 'webp';
      contentType = 'image/webp';
    }

    String storagePathFinal = '$storagePath.$extension';
    try {
      //Cargar la foto del producto
      final String fotoPathFromSupa = await state.storage
          .from('menus')
          .uploadBinary(storagePathFinal, imageBytes,
              fileOptions: FileOptions(
                contentType: contentType,
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

  //Actualizar un ítem para el menú
  Future<String> updateMenuItemFromWeb(MenuItemModel menuItemModel,
      String storagePath, Uint8List? imageBytes, XFile? pickedImage) async {
    //Cuando el image decidió NO cambiarlo
    if (imageBytes != null) {
      String mimeType = pickedImage!.mimeType.toString();
      // Determinar la extensión del archivo
      String extension = '';
      String contentType = 'image/jpeg';
      if (mimeType == 'image/jpeg') {
        extension = 'jpg';
        contentType = 'image/jpeg';
      } else if (mimeType == 'image/png') {
        extension = 'png';
        contentType = 'image/png';
      } else if (mimeType == 'image/webp') {
        extension = 'webp';
        contentType = 'image/webp';
      }
      String storagePathFinal = '$storagePath.$extension';

      try {
        //Cargar la foto del producto
        final String fotoPathFromSupa = await state.storage
            .from('menus')
            .uploadBinary(storagePathFinal, imageBytes,
                fileOptions: FileOptions(
                  contentType: contentType,
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

  //Borrar un ítem del menú
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

  //Agregar un Gasto de Caja
  Future<String> agregarGastoCaja(RegistroCajaModelo registroCaja) async {
    Map<String, dynamic> mapa = registroCaja.toJson();
    try {
      await state.from('registros_caja').insert(mapa);
      return 'success';
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Actualizar un Gasto de Caja
  Future<String> actualizarGastoCaja(RegistroCajaModelo registroCaja) async {
    Map<String, dynamic> mapa = registroCaja.toJson();
    try {
      await state
          .from('registros_caja')
          .update(mapa)
          .eq('id', registroCaja.id!);
      return 'success';
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Borrar un Gasto de Caja
  Future<String> borrarGastoCajaPorId(int id) async {
    try {
      await state.from('registros_caja').delete().eq('id', id);
      return 'success';
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Borrar un Gasto de Caja
  Future<String> borrarGastoCajaPorUuidPedido(String uuid) async {
    try {
      await state.from('registros_caja').delete().eq('uuid_pedido', uuid);
      return 'success';
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Obtener Gastos de Caja por restaurante
  Future<RegistroCajaModelo> getGastosCajaPorId(int id) async {
    List<RegistroCajaModelo> listado = [];
    try {
      final res = await state.from('registros_caja').select().eq('id', id);

      for (var element in res) {
        RegistroCajaModelo modelo = RegistroCajaModelo.fromJson(element);
        listado.add(modelo);
      }
      return listado.first;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error: ${e.message}';
    }
  }

  //Obtener Gastos de Caja por restaurante
  Future<List<RegistroCajaModelo>> getGastosCajaPorRestaurante(
      int restauranteId) async {
    List<RegistroCajaModelo> listado = [];
    try {
      // Obtener la fecha actual
      final DateTime today = DateTime.now();
      final res = await state
          .from('registros_caja')
          .select()
          .eq('restaurante_id', restauranteId)
          .gte('created_at',
              today.toString().substring(0, 10)) // desde el inicio del día
          .lt(
              'created_at',
              today
                  .add(const Duration(days: 1))
                  .toString()
                  .substring(0, 10)) // antes del siguiente día
          .order('id', ascending: false);

      for (var element in res) {
        RegistroCajaModelo modelo = RegistroCajaModelo.fromJson(element);
        listado.add(modelo);
      }
      return listado;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error: ${e.message}';
    }
  }

  //Obtener un Gastos de Caja por uuid_pedido
  Future<bool> existeGastosCajaPorUuidPedido(String uuid) async {
    try {
      final res = await state
          .from('registros_caja')
          .select()
          .eq('uuid_pedido', uuid)
          .count(CountOption.exact);
      if (res.count > 0) {
        return true;
      }
      return false;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error: ${e.message}';
    }
  }

  //Aperturar caja de un restaurante
  Future<String> aperturarCaja(int restauranteId, double cantidad) async {
    try {
      await state.from('caja').insert({
        'created_at': DateTime.now().toIso8601String(),
        'restaurante_uid': restauranteId,
        'cantidad': cantidad,
      });
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

      //Guardar el ingreso en registro de CAJA (SOLO si fue en EFECTIVO)
      if (pedido.idMetodoPago == 1) {
        RegistroCajaModelo registroCaja = RegistroCajaModelo(
          createdAt: DateTime.now(),
          restauranteId: pedido.idRestaurante,
          ingreso: pedido.total,
          egreso: null,
          proveedor: null,
          descripcion: 'Compra en efectivo',
          uuidPedido: pedidoUuid,
        );
        await agregarGastoCaja(registroCaja);
      }

      //Guardar los detalles del pedido
      List<PedidoDetalleModel> listadoProviDetalles =
          ref.read(pedidoDetallesManagementProvider);
      for (PedidoDetalleModel element in listadoProviDetalles) {
        PedidoDetalleModel detalleModelFinal =
            element.copyWith(uuidPedido: pedidoUuid);
        Map<String, dynamic> detalleMap = detalleModelFinal.toJson();
        await state.from('pedidos_items').insert(detalleMap);
      }

      //Obtener el nombre del cliente (para idCliente != 1)
      String nombreCliente = 'Consumidor Final';
      if (pedido.idCliente != 1) {
        nombreCliente = await getClienteName(pedido.idCliente);
      }

      //*NUEVO - INSERTAR FACTURA
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
        nombreNegocio: datosFactura.nombreNegocio,
        nombreCliente:
            pedido.idCliente == 1 ? 'Consumidor final' : nombreCliente,
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

      return pedidoUuid;
      // ignore: unused_catch_clause
    } on PostgrestException catch (e) {
      return 'error';
    }
  }

  //Obtener el nombre del cliente por id
  Future<String> getClienteName(int clienteId) async {
    try {
      final res = await state
          .from('clientes')
          .select()
          .eq('id_cliente', clienteId)
          .limit(1)
          .single();
      String nombreCliente = res['nombre_cliente'];
      return nombreCliente;
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Obtener el nombre y RTN por id
  Future<List<String>> getClienteNameRtn(int clienteId) async {
    try {
      final res =
          await state.from('clientes').select().eq('id_cliente', clienteId);
      List<String> listadoString = [];
      String nombreCliente = res.first['nombre_cliente'];
      String rtnCliente = res.first['rtn_cliente'] ?? '';
      listadoString.add(nombreCliente);
      listadoString.add(rtnCliente);
      return listadoString;
    } on PostgrestException catch (e) {
      return [e.message];
    }
  }

  //Obtener pedido por Uuid
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

  //Obtener detalles del pedido
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

  //Contar la cantidad de productos en el menú
  Future<int> countMenuItems() async {
    try {
      if (ref.read(userPublicDataProvider)['id_restaurante'] != null) {
        int userIdRestaurante = int.parse(
            ref.read(userPublicDataProvider)['id_restaurante'].toString());
        final res = await state
            .from('menus')
            .select()
            .eq('id_restaurante', userIdRestaurante)
            .count(CountOption.exact);
        return res.count;
      }
      return 0;
    } on PostgrestException catch (e) {
      throw Exception(
          'Error al contar los elementos del catálogo: ${e.message}');
    }
  }

  //Contar los clientes
  Future<int> countClientes() async {
    try {
      if (ref.read(userPublicDataProvider)['id_restaurante'] != null) {
        int userIdRestaurante = int.parse(
            ref.read(userPublicDataProvider)['id_restaurante'].toString());
        final res = await state
            .from('clientes')
            .select()
            .eq('id_restaurante', userIdRestaurante)
            .count(CountOption.exact);
        return res.count;
      }
      return 0;
    } on PostgrestException catch (e) {
      throw Exception(
          'Error al contar los elementos del catálogo: ${e.message}');
    }
  }

  //Contar los pedidos del día
  Future<int> countPedidosDelDia() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    try {
      if (ref.read(userPublicDataProvider)['id_restaurante'] != null) {
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
      }
      return 0;
    } on PostgrestException catch (e) {
      throw Exception(
          'Error al contar los elementos del catálogo: ${e.message}');
    }
  }

  //Contar los pedidos en preparación del día
  Future<int> countPedidosDelDiaEnPreparacion() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    try {
      if (ref.read(userPublicDataProvider)['id_restaurante'] != null) {
        int userIdRestaurante = int.parse(
            ref.read(userPublicDataProvider)['id_restaurante'].toString());
        List<Map<String, dynamic>> res = await state
            .from('pedidos')
            .select()
            .eq('id_restaurante', userIdRestaurante)
            .gte(
              'created_at',
              startOfDay,
            );
        if (res.isNotEmpty) {
          List<int> cuentaEnPreparacion = [];
          for (var element in res) {
            if (element['en_preparacion'] == true) {
              cuentaEnPreparacion.add(1);
            }
          }
          return cuentaEnPreparacion.length;
        }
        return 0;
      }
      return 0;
    } on PostgrestException catch (e) {
      throw Exception(
          'Error al contar los elementos del catálogo: ${e.message}');
    }
  }

  //Contar los pedidos del día entregados
  Future<int> countPedidosDelDiaEntregados() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    try {
      if (ref.read(userPublicDataProvider)['id_restaurante'] != null) {
        int userIdRestaurante = int.parse(
            ref.read(userPublicDataProvider)['id_restaurante'].toString());
        List<Map<String, dynamic>> res = await state
            .from('pedidos')
            .select()
            .eq('id_restaurante', userIdRestaurante)
            .gte(
              'created_at',
              startOfDay,
            );
        if (res.isNotEmpty) {
          List<int> cuentaEnPreparacion = [];
          for (var element in res) {
            if (element['en_preparacion'] == false) {
              cuentaEnPreparacion.add(1);
            }
          }
          return cuentaEnPreparacion.length;
        }
        return 0;
      }
      return 0;
    } on PostgrestException catch (e) {
      throw Exception(
          'Error al contar los elementos del catálogo: ${e.message}');
    }
  }

  //Obtener el nombre del ítem del menú
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

  //Obtener el nombre del ítem del menú para cocina
  Future<String> getNombreMenuItemParaCocina(int idMenu) async {
    try {
      final res = await state
          .from('menus')
          .select('nombre_item, va_para_cocina')
          .eq('id_menu', idMenu)
          .limit(1)
          .single();
      if (res['va_para_cocina']) {
        return res['nombre_item'];
      } else {
        return '';
      }
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Cambiar el estatus del pedido
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

  //Borrar el pedido
  Future<String> borrarPedido(String uuIdPedido) async {
    try {
      //Primero borrar los detalles
      await state.from('pedidos_items').delete().eq('uuid_pedido', uuIdPedido);
      //Luego borrar la factura asociada a ese pedido
      await state.from('facturas').delete().eq('uuid_pedido', uuIdPedido);
      //Borrar el ingreso en caja (solo si fue en efectivo y si existiera)
      bool registroCajaExiste = await existeGastosCajaPorUuidPedido(uuIdPedido);
      if (registroCajaExiste) {
        await borrarGastoCajaPorUuidPedido(uuIdPedido);
      }
      //por último borrar el pedido
      await state.from('pedidos').delete().eq('uuid_pedido', uuIdPedido);
      return 'success';
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Obtener los restaurantes por dueño
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

  //Obtener el restaurante (RestauranteModelo)
  Future<RestauranteModelo> obtenerRestaurantePorId(int idRestaurante) async {
    Map<String, dynamic> singleRes = await state
        .from('restaurantes')
        .select()
        .eq('id_restaurante', idRestaurante)
        .single();
    return RestauranteModelo.fromJson(singleRes);
  }

  //Obtener los ingresos totales entre fechas
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

    //EXTRA - utilizar el mismo query para generar los rows de las TABLAS
    await ref.read(pedidosTableRowsProvider.notifier).addDataRows(res);
    await ref.read(rowsVentasPorProductoProvider.notifier).addDataRows(res);

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

  //Obtener las categorías del restaurante
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

  //Obtener una categoría
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

  //Agregar categoría
  Future<String> agregarCategoria(CategoriaModelo cat) async {
    Map<String, dynamic> mapa = cat.toJson();
    try {
      await state.from('categorias').insert(mapa);
      return 'success';
    } on PostgrestException catch (e) {
      return 'Ocurrió un error al querer agregar la categoría -> ${e.message}';
    }
  }

  //Actualizar categoría
  Future<String> actualizarCategoria(CategoriaModelo cat) async {
    Map<String, dynamic> mapa = cat.toJson();
    try {
      await state
          .from('categorias')
          .update(mapa)
          .eq('id_categoria', cat.idCategoria!);
      return 'success';
    } on PostgrestException catch (e) {
      return 'Ocurrió un error al querer actualizar la categoría -> ${e.message}';
    }
  }

  //Actualizar la apertura/cierre de la caja
  Future<String> actualizarCajaApertura(CajaAperturaModelo cajaApertura) async {
    Map<String, dynamic> mapa = cajaApertura.toJson();
    try {
      await state.from('caja').update(mapa).eq('id', cajaApertura.id!);
      return 'success';
    } on PostgrestException catch (e) {
      return 'Ocurrió un error al querer actualizar la categoría -> ${e.message}';
    }
  }

  //Cambiar el estatus de la caja (abierta/cerrada)
  Future<String> statusCaja(int restauranteId, bool status) async {
    try {
      await state.from('caja_abierta').update({
        'abierto': status,
      }).eq('restaurante_uid', restauranteId);
      return 'success';
    } on PostgrestException catch (e) {
      return 'Ocurrió un error al querer actualizar el registro -> ${e.message}';
    }
  }

  //Revisar si la caja está abierta o cerrada
  Future<bool> cajaCerradaoAbierta(int restauranteId) async {
    try {
      final res = await state
          .from('caja_abierta')
          .select('abierto')
          .eq('restaurante_uid', restauranteId);
      bool statusDeCaja = res.first['abierto'];
      return statusDeCaja;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error al querer actualizar el registro -> ${e.message}';
    }
  }

  //Obtener los datos de la factura
  Future<String> getDatosFactura() async {
    Map<String, String> datosPublicos = ref.read(userPublicDataProvider);
    int idRes = 0;
    if (datosPublicos['id_restaurante'] != null) {
      idRes = int.parse(datosPublicos['id_restaurante'].toString());
    }

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

  //Crear datos de la factura
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

  //Actualizar los datos de la factura
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

  //Obtener las facturas y los detalles del pedido realizado
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
        //Obtener el nombre y RTN del cliente
        List<String> datosDelCliente =
            await getClienteNameRtn(modelo.idCliente!);
        String nombreCliente = datosDelCliente.first;
        String rtnCliente = datosDelCliente.last;
        modelo = modelo.copyWith(nombreCliente: nombreCliente, rtn: rtnCliente);
        listado.add(modelo);
      }
      return listado;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error -> ${e.message}';
    }
  }

  //Obtener UNA apertura y/o cierres de caja
  Future<CajaAbiertaModelo> getCajaAbierta(int restauranteId) async {
    try {
      List<Map<String, dynamic>> res = await state
          .from('caja_abierta')
          .select()
          .eq('restaurante_uid', restauranteId);
      List<CajaAbiertaModelo> listado = [];
      for (var element in res) {
        CajaAbiertaModelo modelo = CajaAbiertaModelo.fromJson(element);
        listado.add(modelo);
      }
      return listado.first;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error -> ${e.message}';
    }
  }

  //Obtener el histórico de apertura/cierre de caja
  Future<List<CajaAperturaModelo>> getCajaAperturasPorRestaurante(
      int restauranteId) async {
    try {
      List<Map<String, dynamic>> res = await state
          .from('caja')
          .select()
          .eq('restaurante_uid', restauranteId)
          .order('id', ascending: false);
      List<CajaAperturaModelo> listado = [];
      for (var element in res) {
        CajaAperturaModelo modelo = CajaAperturaModelo.fromJson(element);
        listado.add(modelo);
      }
      return listado;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error -> ${e.message}';
    }
  }

  //Obtener la última apertura/cierre
  Future<CajaAperturaModelo> getCajaApertura(int id) async {
    try {
      List<Map<String, dynamic>> res =
          await state.from('caja').select().eq('id', id);
      List<CajaAperturaModelo> listado = [];
      for (var element in res) {
        CajaAperturaModelo modelo = CajaAperturaModelo.fromJson(element);
        listado.add(modelo);
      }
      return listado.first;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error -> ${e.message}';
    }
  }

  //Obtener las facturas y detalles por fecha
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

  //Agregar una factura
  Future<String> addFactura(FacturaModelo modelo) async {
    Map<String, dynamic> mapa = modelo.toJson();
    try {
      await state.from('facturas').insert(mapa);
      return 'success';
    } on PostgrestException catch (e) {
      return 'Ocurrió un error -> ${e.message}';
    }
  }

  //Calcular el total en el cierre de caja
  Future<double> calcularTotalCierreCaja(int resId) async {
    //Obtener el dato de la última apertura de la caja
    try {
      final res = await getCajaAperturasPorRestaurante(resId);
      double cantidadInicioCaja =
          res.first.cantidad; //Cantidad de inicio de caja

      //Obtener los gastos del día
      List<RegistroCajaModelo> listado =
          await getGastosCajaPorRestaurante(resId);

      for (RegistroCajaModelo element in listado) {
        if (element.egreso != null) {
          cantidadInicioCaja -= element.egreso!;
        } else {
          cantidadInicioCaja += element.ingreso!;
        }
      }

      return cantidadInicioCaja;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error al querer hacer la consulta -> ${e.message}';
    }
  }

  //Obtener el inventario de un restaurante
  Future<List<Inventario>> obtenerInventarioPorRestaurante(
      int idRestaurante) async {
    List<Inventario> listado = [];
    try {
      final List<Map<String, dynamic>> res = await state
          .from('inventario')
          .select()
          .eq('id_restaurante', idRestaurante);

      for (var element in res) {
        InventarioModelo modelo = InventarioModelo.fromJson(element);
        listado.add(modelo);
      }

      return listado;
    } on PostgrestException catch (e) {
      throw 'Ocurrió un error al intentar obtener los datos -> ${e.message}';
    }
  }

  //Agregar producto al inventario
  Future<String> addInventario(InventarioModelo inventario) async {
    Map<String, dynamic> mapa = inventario.toJson();
    try {
      await state.from('inventario').insert(mapa);
      return 'success';
    } on PostgrestException catch (e) {
      return 'Ocurrió un error -> ${e.message}';
    }
  }

  //Borrar un producto del inventario
  Future<String> borrarInventario(int id) async {
    try {
      await state.from('inventario').delete().eq('id', id);
      return 'success';
    } on PostgrestException catch (e) {
      return e.message;
    }
  }

  //Actualizar Inventario
  Future<String> actualizarInventario(InventarioModelo inventario) async {
    Map<String, dynamic> mapa = inventario.toJson();
    try {
      await state.from('inventario').update(mapa).eq('id', inventario.id!);
      return 'success';
    } on PostgrestException catch (e) {
      return 'Ocurrió un error al querer actualizar el producto -> ${e.message}';
    }
  }
}
