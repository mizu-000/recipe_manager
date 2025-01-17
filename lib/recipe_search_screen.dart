import 'package:flutter/material.dart';
import 'recipe_api.dart';
import 'database_helper.dart';
import 'recipe_search_result_screen.dart'; // recipe_search_result_screen.dart をインポート

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({Key? key}) : super(key: key);
  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  String? _selectedCategoryId; // 選択されたカテゴリID
  String? _selectedCategoryName; // 選択されたカテゴリ名
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
      _categories = List.from(_allCategories);
      _selectedCategoryName = null;
      _selectedCategoryId = null;
    });
  }

  String getCategoryIdFromName(String categoryName) {
    final category = _categories.firstWhere(
            (category) => category['name'] == categoryName,
        orElse: () => {}); // 空のマップを返す
    return category['categoryId'].toString();
  }

  // キーワードからカテゴリを絞り込む
  void _filterCategories(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        // キーワードが空の場合はすべてのカテゴリを表示
        _categories = List.from(_allCategories);
      } else {
        // キーワードが入力されている場合は、その文字列を含むカテゴリのみを抽出
        _categories = _allCategories
            .where((category) =>
            (category['name'] as String)
                .toLowerCase()
                .contains(keyword.toLowerCase()))
            .toList();
      }
      // 重複を排除（カテゴリ名で一意にする）
      _categories = _categories.fold<Map<String, Map<String, dynamic>>>(
        {},
            (map, category) {
          map[category['name']] = category;
          return map;
        },
      ).values.toList();
      // 選択済みジャンルがリスト内に存在しない場合、リセット
      if (!_categories
          .any((category) => category['name'] == _selectedCategoryName)) {
        _selectedCategoryName = null;
        _selectedCategoryId = null;
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
                  border: OutlineInputBorder(),
                ),
                onChanged: _filterCategories, // 入力時にカテゴリを絞り込む
              ),
              const SizedBox(height: 16.0),
              // ドロップダウンリスト
              DropdownButtonFormField<String>(
                value: _categories
                    .any((category) => category['name'] == _selectedCategoryName)
                    ? _selectedCategoryName
                    : null, // 一致しない場合はnullを設定
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'ジャンルを選択',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  final categoryName = category['name'] as String;
                  return DropdownMenuItem(
                    value: categoryName,
                    child: Text(categoryName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryName = value;
                    _selectedCategoryId = getCategoryIdFromName(value!);
                  });
                },
              ),
              const SizedBox(height: 24.0),
              // 検索ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    if (_selectedCategoryId != null) {
                      _searchRanking().then((_) {
                        // 検索結果を新しい画面に渡す
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeSearchResultScreen(ranking: _ranking!),
                          ),
                        );
                      });
                    } else if (_selectedCategoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ジャンルを選択してください')),
                      );
                    }
                  },
                  child: const Text('検索'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}