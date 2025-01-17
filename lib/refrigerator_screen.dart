import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'food_list_screen.dart';

class MyApp extends StatelessWidget {
  final Database database;

  const MyApp({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.orange[300],
        fontFamily: 'KosugiMaru',
      ),
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
  final _expiryDateController = TextEditingController();
  String? _selectedUnit = '個'; // 初期値を設定
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('冷蔵庫管理'),

      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange[100]!,
              Colors.white,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 一覧表示ボタン
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 16),
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodListScreen(database: widget.database),
                      ),
                    );
                  },
                  child: const Text(
                    '一覧',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32.0),
                // 食材名入力フィールド
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '食材名',
                    hintText: '例: 卵',
                    prefixIcon: Icon(Icons.fastfood),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '食材名を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                // 数量入力フィールド
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '数量',
                    hintText: '例: 10',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '数量を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                // 単位選択ドロップダウン
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: const InputDecoration(
                    labelText: '単位',
                    prefixIcon: Icon(Icons.scale),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '個', child: Text('個')),
                    DropdownMenuItem(value: 'g', child: Text('g')),
                    DropdownMenuItem(value: 'ml', child: Text('ml')),
                    DropdownMenuItem(value: '本', child: Text('本')),
                    DropdownMenuItem(value: '枚', child: Text('枚')),
                    // 必要に応じて他の単位を追加
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '単位を選択してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                // 消費期限入力フィールド
                TextFormField(
                  controller: _expiryDateController,
                  decoration: InputDecoration(
                    labelText: '消費期限 (yyyy/MM/dd)',
                    hintText: '例: 2025/01/20',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null && pickedDate != _selectedDate) {
                          setState(() {
                            _selectedDate = pickedDate;
                            _expiryDateController.text =
                            '${pickedDate.year}/${pickedDate.month}/${pickedDate.day}';
                          });
                        }
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '消費期限を入力してください';
                    }
                    // 日付の形式チェックなど、必要に応じて追加
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),
                // 登録ボタン
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[300],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 16),
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final messenger = ScaffoldMessenger.of(context);
                      await widget.database.insert(
                        'foods',
                        {
                          'name': _nameController.text,
                          'quantity': int.parse(_quantityController.text),
                          'unit': _selectedUnit,
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
                      _expiryDateController.clear();
                      setState(() {});
                    }
                  },
                  child: const Text(
                    '登録',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}