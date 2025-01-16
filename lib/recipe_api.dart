import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_key_manager.dart';

Future<List<dynamic>> fetchCategories() async {
  final applicationId = await loadApiId();

  if (applicationId == null) {
    throw Exception('applicationIdが設定されていません');
  }

  final url = Uri.parse(
      'https://app.rakuten.co.jp/services/api/Recipe/CategoryList/20170426'
          '?applicationId=$applicationId');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);

    // mediumカテゴリの親カテゴリを格納するマップ
    final parentDict = <String, String>{};

    // result から large, medium, small のカテゴリを取得
    final largeCategories = jsonData['result']['large'] as List;
    final mediumCategories = jsonData['result']['medium'] as List;
    final smallCategories = jsonData['result']['small'] as List;

    // 大カテゴリの categoryId を置換
    for (final category in largeCategories) {
      category['categoryId'] = category['categoryId'].toString();
    }

    // 中カテゴリの categoryId を置換
    for (final category in mediumCategories) {
      parentDict[category['categoryId'].toString()] =
        category['parentCategoryId'].toString();
      category['categoryId'] =
      '${category['parentCategoryId']}-${category['categoryId']}';
    }

    // 小カテゴリの categoryId を置換
    for (final category in smallCategories) {
      final parentCategoryId = category['parentCategoryId'].toString();
      category['categoryId'] =
      '${parentDict[parentCategoryId]}-$parentCategoryId-${category['categoryId']}';
    }

    // すべてのカテゴリを1つのリストにまとめる
    final allCategories = [
      ...largeCategories,
      ...mediumCategories,
      ...smallCategories,
    ];
    return allCategories; // すべてのカテゴリのリストを返す
  } else {
    throw Exception('Failed to load categories');
  }
}

// 楽天レシピAPIのカテゴリ別ランキングを取得
Future<List<dynamic>> fetchCategoryRanking(String categoryId) async {
  final applicationId = await loadApiId();

  if (applicationId == null) {

    throw Exception('applicationIdが設定されていません');

  }

  final url = Uri.parse(
      'https://app.rakuten.co.jp/services/api/Recipe/CategoryRanking/20170426'
          '?applicationId=$applicationId&categoryId=$categoryId' // api_key_manager.dart から applicationId を取得
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    return jsonData['result'] as List;
  } else {
    throw Exception('Failed to load category ranking');
  }
}
