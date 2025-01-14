import 'package:flutter/material.dart';
import 'package:recipe_manager/main.dart'; // main.dart をインポート
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatelessWidget {
  final Database database; // データベースを受け取る

  const HomeScreen({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム画面'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                // 冷蔵庫管理画面へのボタン
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RefrigeratorApp(database: database), // RefrigeratorApp に遷移
                  ),
                );
              },
              child: const Text('冷蔵庫管理'),
            ),
            // 他の機能へのボタンをここに追加していく
          ],
        ),
      ),
    );
  }
}