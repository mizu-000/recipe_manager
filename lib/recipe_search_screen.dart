// recipe_search_screen.dart
import 'package:flutter/material.dart';
import 'recipe_api.dart';
import 'database_helper.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({Key? key}) : super(key: key);

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  String? _selectedCategoryId; // 選択されたカテゴリID
  List<dynamic>? _categories; // カテゴリ一覧
  List<dynamic>? _ranking; // ランキング

  @override
  void initState() {
    super.initState();
    _loadCategories(); // 初期表示時にカテゴリ一覧を読み込む
  }

  // データベースからカテゴリ一覧を読み込む関数
  Future<void> _loadCategories() async {
    final db = await DatabaseHelper.getCategoryDatabase(); // 修正: 初期化処理を削除
    final List<Map<String, dynamic>> maps = await db.query('categories');
    setState(() {
      _categories = maps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レシピ検索'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'キーワードを入力',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'キーワードを入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // ジャンル絞り込み用ドロップダウン
                  DropdownButton<String>(
                    value: _selectedCategoryId,
                    hint: const Text('ジャンルを選択'),
                    items: _categories?.map((category) {
                      return DropdownMenuItem(
                        value: category['categoryId'].toString(),
                        child: Text(category['categoryName']),
                      );
                    }).toList() ?? [], // _categories が null の場合は空のリストを返す
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // ランキングを取得
                final ranking = await fetchCategoryRanking(
                  _selectedCategoryId!,
                );
                setState(() {
                  _ranking = ranking;
                });
              }
            },
            child: const Text('検索'),
          ),
          Expanded(
            child: _ranking == null
                ? const Center(
              child: Text('ランキングを取得してください'),
            )
                : ListView.builder(
              itemCount: _ranking!.length,
              itemBuilder: (context, index) {
                final recipe = _ranking![index];
                return ListTile(
                  leading: Image.network(recipe['foodImageUrl']),
                  title: Text(recipe['recipeTitle']),
                  // ... (必要な情報を表示)
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}