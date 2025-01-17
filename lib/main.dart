import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'food_list_screen.dart';
import 'home_screen.dart';
import 'database_helper.dart';

// グローバルキーを定義
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final refrigeratorDatabase =
    await DatabaseHelper.initializeRefrigeratorDatabase();
    runApp(MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primaryColor: Colors.orange[300],
        fontFamily: 'KosugiMaru',
      ),
      home: HomeScreen(
        refrigeratorDatabase: refrigeratorDatabase, // 冷蔵庫管理用データベースを渡す
      ),
    ));
  } catch (e) {
    // エラーダイアログを表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: navigatorKey.currentContext!, // グローバルキーでコンテキストを取得
        builder: (context) => AlertDialog(
          title: const Text('エラー'),
          content: Text('データベースの初期化に失敗しました。\n$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}