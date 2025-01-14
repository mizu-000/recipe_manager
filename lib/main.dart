import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'food_list_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openDatabase(
    join(await getDatabasesPath(), 'refrigerator.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE foods(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, quantity INTEGER, unit TEXT, expiryDate TEXT)',
      );
    },
    version: 1,
  );

  runApp(MaterialApp(
    home: HomeScreen(database: database), // HomeScreen を表示
  ));
}

class MyApp extends StatelessWidget {
  final Database database;

  const MyApp({Key? key, required this.database}) : super(key: key); // key を super に渡す

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RefrigeratorApp(database: database),
    );
  }
}

class RefrigeratorApp extends StatefulWidget {
  final Database database;

  const RefrigeratorApp({Key? key, required this.database}) : super(key: key); // key を super に渡す

  @override
  State<RefrigeratorApp> createState() => _RefrigeratorAppState();
}

class _RefrigeratorAppState extends State<RefrigeratorApp> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _expiryDateController = TextEditingController();
// データベースから食材データを取得する関数
  Future<List<Map<String, dynamic>>> getFoods() async {
    final db = await widget.database;
    final List<Map<String, dynamic>> maps = await db.query('foods');
    return maps;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('冷蔵庫管理アプリ'),
      ),
      body: Center( // Centerで中央寄せ
        child: Column(
          mainAxisSize: MainAxisSize.min, // Columnのサイズを最小限にする
          children: [
            ElevatedButton(
              onPressed: () {
                // 一覧ボタンが押されたらFoodListScreenに遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodListScreen(database: widget.database),
                  ),
                );
              },
              child: const Text('一覧'),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: '食材名'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '食材名を入力してください';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: '数量'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '数量を入力してください';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(labelText: '単位'),
                    ),
                    TextFormField(
                      controller: _expiryDateController,
                      decoration: const InputDecoration(labelText: '消費期限 (yyyy/MM/dd)'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // ここで BuildContext を変数に保存
                            final messenger = ScaffoldMessenger.of(context);
                            await widget.database.insert(
                              'foods',
                              {
                                'name': _nameController.text,
                                'quantity': int.parse(_quantityController.text),
                                'unit': _unitController.text,
                                'expiryDate': _expiryDateController.text,
                              },
                              conflictAlgorithm: ConflictAlgorithm.replace,
                            );
                            // 保存した変数を使って SnackBar を表示
                            messenger.showSnackBar(
                              const SnackBar(content: Text('データが保存されました')),
                            );
                          }
                        },
                        child: const Text('保存'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}