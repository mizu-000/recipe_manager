import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['recipeTitle']),
      ),
      body: Container( // 背景色を設定
        color: Colors.orange[100], // オレンジ系の色
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // レシピ画像を大きく表示
                SizedBox(
                  height: 200,
                  child: Image.network(
                    recipe['foodImageUrl'],
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16.0),
                // カードレイアウトで情報をまとめる
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['recipeTitle'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(), // 区切り線を追加
                        ListTile(
                          leading: const Icon(Icons.money), // アイコンを追加
                          title: Text('費用: ${recipe['recipeCost']}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.description), // アイコンを追加
                          title: Text('説明: ${recipe['recipeDescription']}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.timer), // アイコンを追加
                          title: Text('目安時間: ${recipe['recipeIndication']}'),
                        ),
                        const ListTile(
                          leading: Icon(Icons.kitchen), // アイコンを追加
                          title: Text('材料:'),
                        ),
                        ...recipe['recipeMaterial'].map<Widget>((material) =>
                            ListTile(
                              title: Text('・$material'),
                            )
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final url = Uri.parse(recipe['recipeUrl']);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('URLを開けませんでした: ${recipe['recipeUrl']}')),
                      );
                    }
                  },
                  child: const Text('手順はこちら'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}