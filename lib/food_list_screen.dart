import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class FoodListScreen extends StatefulWidget {
  final Database database;

  const FoodListScreen({Key? key, required this.database}) : super(key: key);

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  // データベースから食材データを取得する関数
  Future<List<Map<String, dynamic>>> getFoods() async {
    final db = widget.database;
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
                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) async {
                    final db = widget.database;
                    await db.delete(
                      'foods',
                      where: 'id = ?',
                      whereArgs: [food['id']],
                    );
                    setState(() {});
                  },
                  background: Container(
                    color: Colors.red,
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(food['name']),
                    subtitle: Text(
                      '数量: ${food['quantity']} ${food['unit']}, 消費期限: ${food['expiryDate']}',
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('エラーが発生しました: ${snapshot.error}'),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}