import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final storage = const FlutterSecureStorage();
  final String _keyEmail = 'email';
  final String _keyNombre = 'nombre';
  final String _keyRol = 'rol';
  final String _keyIdrestaurante = 'id_restaurante';

  Future setUserEmail(String email) async {
    await storage.write(key: _keyEmail, value: email);
  }

  Future setUserNombre(String nombre) async {
    await storage.write(key: _keyNombre, value: nombre);
  }

  Future setUserRol(int rol) async {
    await storage.write(key: _keyRol, value: rol.toString());
  }

  Future setUserIdRestaurante(int idRestaurante) async {
    await storage.write(
        key: _keyIdrestaurante, value: idRestaurante.toString());
  }

  Future<String?> getEmail() async {
    return await storage.read(key: _keyEmail);
  }

  Future<String?> getNombre() async {
    return await storage.read(key: _keyNombre);
  }

  Future<String?> getRol() async {
    return await storage.read(key: _keyRol);
  }

  Future<String?> getIdRestaurante() async {
    return await storage.read(key: _keyIdrestaurante);
  }

  Future<Map<String, String>> getAllValues() async {
    return await storage.readAll();
  }

  Future<void> deleteAllValues() async {
    await storage.deleteAll();
  }
}
