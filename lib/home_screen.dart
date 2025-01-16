import 'package:flutter/material.dart';
import 'refrigerator_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'recipe_search_screen.dart';
import 'api_key_input_screen.dart'; // api_key_input_screen.dart をインポート
import 'api_key_manager.dart'; // api_key_manager.dart をインポート

class HomeScreen extends StatelessWidget {
  final Database refrigeratorDatabase; // 冷蔵庫管理用データベース

  const HomeScreen(
      {Key? key,
        required this.refrigeratorDatabase})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム画面'),
        actions: [
          IconButton(
            onPressed: () async {
              // APIキーを削除
              await deleteApiKey();
              // リセット完了メッセージを表示
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('APIキーをリセットしました')),
              );
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
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
                    builder: (context) => RefrigeratorApp(database: refrigeratorDatabase),
                  ),
                );
              },
              child: const Text('冷蔵庫管理'),
            ),
            ElevatedButton(
              onPressed: () async {
                // APIキーが保存されているか確認
                final apiKey = await loadApiId();
                if (apiKey == null) {
                  // APIキーが未入力の場合はApiKeyInputScreenに遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ApiKeyInputScreen(),
                    ),
                  );
                } else {
                  // APIキーが保存されている場合はRecipeSearchScreenに遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecipeSearchScreen(),
                    ),
                  );
                }
              },
              child: const Text('レシピ検索'),
            ),
          ],
        ),
      ),
    );
  }
}