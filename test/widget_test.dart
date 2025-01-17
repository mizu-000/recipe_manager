import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:recipe_manager/refrigerator_screen.dart'; // refrigerator_screen.dart をインポート

void main() {
  late Database database; // database オブジェクトを late で宣言

  setUp(() async {
    // setUp() 関数で database オブジェクトを初期化
    database = await openDatabase(
      join(await getDatabasesPath(), 'refrigerator.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE foods(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, quantity INTEGER, unit TEXT, expiryDate TEXT)',
        );
      },
      version: 1,
    );
  });

  tearDown(() async {
    // tearDown() 関数でデータベースを閉じる
    await database.close();
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(database: database));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}