import 'package:flutter/material.dart';
import 'package:recipe_manager/api_key_manager.dart'; // api_key_manager.dart をインポート
import 'package:recipe_manager/recipe_search_screen.dart'; // recipe_search_screen.dart をインポート
import 'package:url_launcher/url_launcher.dart';
import 'database_helper.dart';
import 'recipe_api.dart';

class ApiKeyInputScreen extends StatefulWidget {
  const ApiKeyInputScreen({Key? key}) : super(key: key);

  @override
  State<ApiKeyInputScreen> createState() => _ApiKeyInputScreenState();
}

class _ApiKeyInputScreenState extends State<ApiKeyInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APIキー入力'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // APIキー入力フィールド
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'APIキー',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'APIキーを入力してください';
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 24.0),
              // 保存ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // APIキーを保存
                      await saveApiKey(_apiKeyController.text);
                      // カテゴリデータベースの初期化
                      final categoryDatabase =
                      await DatabaseHelper.initializeCategoryDatabase();
                      // カテゴリ一覧を取得してデータベースに保存
                      try {
                        final categories = await fetchCategories();
                        await DatabaseHelper.saveCategories(
                            categoryDatabase, categories);
                        // RecipeSearchScreenに遷移
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecipeSearchScreen(),
                          ),
                        );
                      } catch (e) {
                        // エラー時の処理
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('カテゴリの取得に失敗しました: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('保存'),
                ),
              ),
              const SizedBox(height: 32.0),
              const Text(
                'APIキーは、Rakuten RapidAPIで取得できます。\n取得してからこの機能を使えます',
              ),
              const SizedBox(height: 8.0),
              InkWell(
                onTap: () => launchUrl(Uri.parse(
                    'https://login.account.rakuten.com/sso/authorize?client_id=rae_jid_web&redirect_uri=https://webservice.rakuten.co.jp/code&scope=openid%20profile&response_type=code&ui_locales=ja-JP#/sign_in')),
                child: const Text(
                  'Rakuten RapidAPI',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}