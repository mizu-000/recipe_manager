import 'package:flutter/material.dart';
import 'refrigerator_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'recipe_search_screen.dart';
import 'api_key_input_screen.dart';
import 'api_key_manager.dart';
import 'database_helper.dart';

class HomeScreen extends StatelessWidget {
  final Database refrigeratorDatabase;

  const HomeScreen({Key? key, required this.refrigeratorDatabase})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '食卓ヘルパー',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // AppBarのタイトルを中央寄せ
        actions: [
          IconButton(
            onPressed: () async {
              await deleteApiKey();
              await DatabaseHelper.deleteCategoryDatabase();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('APIキーをリセットしました')),
              );
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange[100]!,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 冷蔵庫管理ボタン
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[300],
                  padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RefrigeratorApp(database: refrigeratorDatabase),
                    ),
                  );
                },
                child: const Text(
                  '冷蔵庫管理',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              // レシピ検索ボタン
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[300],
                  padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final apiKey = await loadApiId();
                  if (apiKey == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ApiKeyInputScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecipeSearchScreen(),
                      ),
                    );
                  }
                },
                child: const Text(
                  'レシピ検索',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}