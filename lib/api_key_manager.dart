import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// applicationIdを保存する関数
Future<void> saveApiKey(String applicationId) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: 'applicationId', value: applicationId);
}

// applicationIdを読み込む関数
Future<String?> loadApiId() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'applicationId');
}