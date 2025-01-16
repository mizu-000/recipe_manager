import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // 冷蔵庫管理用データベースの初期化
  static Future<Database> initializeRefrigeratorDatabase() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'refrigerator.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE foods(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, quantity INTEGER, unit TEXT, expiryDate TEXT)',
        );
      },
      version: 1,
    );
    return database;
  }

  // カテゴリ用データベースのインスタンス
  static Database? _categoryDatabase;

// カテゴリ用データベースの初期化
  static Future<Database> initializeCategoryDatabase() async {
    _categoryDatabase = await openDatabase(
      join(await getDatabasesPath(), 'category.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE categories('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'categoryId TEXT, '
              'name TEXT, '
              'url TEXT, '
              'parent_id INTEGER' // parentCategoryId を parent_id に変更
              ')',
        );
      },
      version: 1,
    );
    return _categoryDatabase!;
  }

// カテゴリデータを保存する関数
  static Future<void> saveCategories(
      Database database, List<dynamic> categories) async { // 引数の型を List<dynamic> に変更
    final batch = database.batch();
    for (final category in categories) {
      batch.insert('categories', {
        'categoryId': category['categoryId'],
        'name': category['categoryName'],
        'url': category['categoryUrl'],
        'parent_id': category['parentCategoryId'] != null
            ? (category['parentCategoryId'] is int
            ? category['parentCategoryId']
            : int.parse(category['parentCategoryId']))
            : 0,
      });
    }
    try {
      await batch.commit();
    } catch (e) {
      print('batch.commit() でエラーが発生しました: $e');
    }
  }

  // 初期化済みのカテゴリ用データベースを取得するメソッド
  static Database getCategoryDatabase() {
    if (_categoryDatabase == null) {
      throw Exception('カテゴリデータベースが初期化されていません');
    }
    return _categoryDatabase!;
  }

}