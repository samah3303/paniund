import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  Future<void> saveToken(String token) async {
    await _storage.write(key: StorageKeys.jwtToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: StorageKeys.jwtToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: StorageKeys.jwtToken);
  }

  Future<void> saveUserData({
    required String id,
    required String email,
    String? name,
    String? role,
  }) async {
    await _storage.write(key: StorageKeys.userId, value: id);
    await _storage.write(key: StorageKeys.userEmail, value: email);
    if (name != null) await _storage.write(key: StorageKeys.userName, value: name);
    if (role != null) await _storage.write(key: StorageKeys.userRole, value: role);
  }

  Future<Map<String, String?>> getUserData() async {
    final id = await _storage.read(key: StorageKeys.userId);
    final email = await _storage.read(key: StorageKeys.userEmail);
    final name = await _storage.read(key: StorageKeys.userName);
    final role = await _storage.read(key: StorageKeys.userRole);
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }

  Future<void> cacheApplications(String jsonString) async {
    await _storage.write(key: StorageKeys.cachedApplications, value: jsonString);
  }

  Future<String?> getCachedApplications() async {
    return await _storage.read(key: StorageKeys.cachedApplications);
  }

  Future<void> cacheProfile(String jsonString) async {
    await _storage.write(key: StorageKeys.cachedProfile, value: jsonString);
  }

  Future<String?> getCachedProfile() async {
    return await _storage.read(key: StorageKeys.cachedProfile);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
