import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/providers/transaction_providers.dart';
import 'package:expense_tracker/views/home_screen.dart';

void main() {
  setUpAll(() async {
    Hive.init('./test_hive_widget');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    await Hive.openBox<Transaction>('transactions');
  });

  setUp(() async {
    final box = Hive.box<Transaction>('transactions');
    await box.clear();
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('transactions');
    await Hive.close();
  });

  testWidgets('Home screen shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionsProvider.overrideWithValue(const []),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chưa có giao dịch nào'), findsOneWidget);
    expect(find.text('Số dư hiện tại'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Home screen shows pre-seeded transaction and correct summary',
      (WidgetTester tester) async {
    final transactions = [
      Transaction(
        id: 'test-1',
        amount: 1000000,
        type: 'income',
        category: 'Salary',
        date: DateTime.now(),
        note: 'Test salary',
      ),
      Transaction(
        id: 'test-2',
        amount: 200000,
        type: 'expense',
        category: 'Food',
        date: DateTime.now(),
        note: 'Lunch',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionsProvider.overrideWithValue(transactions),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Transactions should be visible
    expect(find.text('Chưa có giao dịch nào'), findsNothing);
    expect(find.text('Salary'), findsWidgets); // tile + filter chip
    expect(find.text('Food'), findsWidgets);
    expect(find.text('2 giao dịch'), findsOneWidget);
  });
}
