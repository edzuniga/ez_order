import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:random_string/random_string.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
}
