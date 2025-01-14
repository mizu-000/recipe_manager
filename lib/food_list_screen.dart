import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class FoodListScreen extends StatelessWidget {
  final Database database;

  const FoodListScreen({Key? key, required this.database}) : super(key: key);

  // データベースから食材データを取得する関数
  Future<List<Map<String, dynamic>>> getFoods() async {
    final db = database;
    final List<Map<String, dynamic>> maps = await db.query('foods');
    return maps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('材料一覧'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getFoods(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final foods = snapshot.data!;
            return ListView.builder(
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final food = foods[index];
                return ListTile(
                  title: Text(food['name']),
                  subtitle: Text(
                      '数量: ${food['quantity']} ${food['unit']}, 消費期限: ${food['expiryDate']}'),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text('エラーが発生しました: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}