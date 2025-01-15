import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'food_list_screen.dart';
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

  const RefrigeratorApp({Key? key, required this.database}) : super(key: key);

  @override
  State<RefrigeratorApp> createState() => _RefrigeratorAppState();
}

class _RefrigeratorAppState extends State<RefrigeratorApp> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _expiryDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('冷蔵庫管理アプリ'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
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
                            messenger.showSnackBar(
                              const SnackBar(content: Text('データが保存されました')),
                            );
                            // 入力フィールドの値をクリア
                            _nameController.clear();
                            _quantityController.clear();
                            _unitController.clear();
                            _expiryDateController.clear();
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