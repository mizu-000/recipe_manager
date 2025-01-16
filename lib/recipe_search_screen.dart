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
  List<Map<String, dynamic>> _categories = []; // フィルタリングされたカテゴリ一覧
  List<dynamic>? _ranking; // ランキング
  List<Map<String, dynamic>> _allCategories = []; // すべてのカテゴリ

  @override
  void initState() {
    super.initState();
    _initialize(); // データベースの初期化とカテゴリのロード
  }

  Future<void> _initialize() async {
    await DatabaseHelper.initializeCategoryDatabase(); // データベースの初期化を待つ
    _loadAllCategories(); // すべてのカテゴリをロード
  }
  // すべてのカテゴリをロードしてデータベースに保存
  Future<void> _loadAllCategories() async {
    final db = await DatabaseHelper.getCategoryDatabase();
    final List<Map<String, dynamic>> maps = await db.query('categories');
    setState(() {
      _allCategories = maps;
      _categories = maps; // 初期状態ではすべてのカテゴリを表示
    });
    print('_categories: $_categories');
  }

  // キーワードからカテゴリを絞り込む
  void _filterCategories(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        // キーワードが空の場合はすべてのカテゴリを表示
        _categories = _allCategories;
      } else {
        // キーワードが入力されている場合は、その文字列を含むカテゴリのみを抽出
        _categories = _allCategories
            .where((category) =>
            (category['name'] as String)
                .toLowerCase()
                .contains(keyword.toLowerCase()))
            .toList();
      }
    });
  }

  // カテゴリIDを使用してランキングを取得
  Future<void> _searchRanking() async {
    if (_selectedCategoryId == null) return;

    try {
      final ranking = await fetchCategoryRanking(_selectedCategoryId!);
      setState(() {
        _ranking = ranking;
      });
    } catch (e) {
      // エラー時の処理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ランキングの取得に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レシピ検索'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // キーワード入力フォーム
              TextFormField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'キーワードを入力',
                ),
                onChanged: _filterCategories, // 入力時にカテゴリを絞り込む
              ),
              const SizedBox(height: 16.0),
              // ドロップダウンリスト
              DropdownButton<String>(
                value: _selectedCategoryId,
                isExpanded: true,
                // ドロップダウンの幅を最大化
                hint: const Text('ジャンルを選択'),
                items: _categories.isEmpty
                    ? [] // 空リストの場合でもエラーを回避
                    : _categories.map((category) {
                  return DropdownMenuItem(
                    value: category['categoryId'].toString(),
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              // 検索ボタン
              ElevatedButton(
                onPressed: () {
                  if (_selectedCategoryId != null) {
                    _searchRanking();
                  } else if (_selectedCategoryId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('ジャンルを選択してください')),
                    );
                  }
                },
                child: const Text('検索'),
              ),
              const SizedBox(height: 16.0),
              // ランキング結果表示
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
                      leading: recipe['foodImageUrl'] != null
                          ? Image.network(recipe['foodImageUrl'])
                          : null,
                      title: Text(recipe['recipeTitle'] ?? '無題'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}