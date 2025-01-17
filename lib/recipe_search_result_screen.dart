import 'package:flutter/material.dart';

class RecipeSearchResultScreen extends StatelessWidget {
  final List<dynamic> ranking;

  const RecipeSearchResultScreen({Key? key, required this.ranking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('検索結果'),
      ),
      body: ListView.builder(
        itemCount: ranking.length,
        itemBuilder: (context, index) {
          final recipe = ranking[index];
          return Card( // カードを追加
            child: ListTile(
              leading: recipe['foodImageUrl'] != null
                  ? Image.network(recipe['foodImageUrl'])
                  : Container(),
              title: Text(recipe['recipeTitle'] ?? '無題'),
              subtitle: Text('レシピID: ${recipe['recipeId']}'),
              onTap: () {
                // TODO: レシピ詳細画面に遷移する処理を追加
                // レシピIDを使って詳細情報を取得し、新しい画面に遷移する
              },
            ),
          );
        },
      ),
    );
  }
}