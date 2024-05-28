import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:ez_order_ezr/data/menu_item_model.dart';
import 'package:random_string/random_string.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
}
