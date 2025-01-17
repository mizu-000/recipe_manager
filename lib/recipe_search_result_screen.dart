import 'package:flutter/material.dart';
import 'recipe_detail_screen.dart';

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(recipe: recipe),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}