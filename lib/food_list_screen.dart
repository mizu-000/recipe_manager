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

    // 新しいリストを作成
    final newMaps = maps.map((food) {
      final expiryDate = food['expiryDate'] as String;
      final formattedExpiryDate = expiryDate.replaceAll('/', '-');
      final finalExpiryDate = formattedExpiryDate.replaceAllMapped(
        RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})'),
            (match) => '${match.group(1)}-${match.group(2)!.padLeft(2, '0')}-${match.group(3)!.padLeft(2, '0')}',
      );
      return {
        ...food, // 他のプロパティはそのままコピー
        'expiryDate': finalExpiryDate, // expiryDate を置換
      };
    }).toList();

    return newMaps; // 新しいリストを返す
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('材料一覧'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[100]!, Colors.white],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getFoods(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final foods = snapshot.data!;
              return ListView.builder(
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final food = foods[index];
                  // 消費期限が近い場合は赤色で表示
                  final expiryDate = DateTime.parse(food['expiryDate']);
                  final today = DateTime.now();
                  final difference = expiryDate.difference(today).inDays;
                  final isNearExpiry = difference <= 3; // 3日以内を近いと判定

                  return Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Dismissible(
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
                        leading: const Icon(Icons.food_bank),
                        title: Text(
                          food['name'],
                          style: TextStyle(
                            fontWeight: isNearExpiry ? FontWeight.bold : FontWeight.normal,
                            color: isNearExpiry ? Colors.red : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          '数量: ${food['quantity']} ${food['unit']}, 消費期限: ${food['expiryDate']}',
                          style: TextStyle(
                            color: isNearExpiry ? Colors.red : Colors.grey,
                          ),
                        ),
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
      ),
    );
  }
}