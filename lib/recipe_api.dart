import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_key_manager.dart';

// 楽天レシピAPIのカテゴリ一覧を取得
Future<List<dynamic>> fetchCategories() async {

  final applicationId = await loadApiId();

  if (applicationId == null) {

    throw Exception('applicationIdが設定されていません');

  }

  final url = Uri.parse(
      'https://app.rakuten.co.jp/services/api/Recipe/CategoryList/20170426'
          '?applicationId=$applicationId&categoryType=large' // api_key_manager.dart から applicationId を取得
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    return jsonData['result']['large'] as List;
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
